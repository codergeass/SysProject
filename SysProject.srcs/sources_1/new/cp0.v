`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/30 20:46:32
// Design Name: 
// Module Name: cp0
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 协处理器cp0
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cp0(
	i_clk, 
	i_rstn,
	i_overflow,
	i_divzero,
	i_unknown_command,
	i_unknown_func,
	i_interrupt_request,
	i_interrupt_source,
	i_syscall,
	i_break,
	i_data,
	i_address,
	i_if_pc,
	i_if_id_pc,
	i_id_exe_pc,
	i_exe_mem_pc,
	i_next_is_dslot,
	i_id_exe_is_dslot,
	i_exe_mem_is_dslot,
	i_mtc0,
	i_mfc0,
	i_eret,
	i_mult_div,
	i_id_exe_mult_div,
	i_ready,
	o_interrupt_answer,
	o_interrupt_source,
	o_exception,
	o_id_continue,
	o_mult_div_cancel,
	o_eret_pc,
	o_excep_pc,
	o_cp0_data
	);

	localparam STATUS_ADDR	= 12;		// 状态寄存器STATUS编号
	localparam CAUSE_ADDR	= 13;		// 异常中断原因寄存器CAUSE编号
	localparam EPC_ADDR		= 14;		// 异常程序计数器EPC编号

	/////////////////////////////////////////////////////////////////////////////
	// ip[7:0]	: cause[15:8]	exc_code[4:0]	: cause[6:2]
	// im[7:0]	: status[15:8]	ksu[1:0]		: status[4:3]	
	// exl 		: status[1]		ie 				: status[0]
	// bd		: status[31]
	/////////////////////////////////////////////////////////////////////////////


	/////////////////////////////////////////////////////////////////////////////
	// CP0寄存器相关: mtc0 直接在ID级完成 不存在相关
	/////////////////////////////////////////////////////////////////////////////

	input	i_clk, i_rstn;
	input	i_overflow;
	input	i_divzero;
	input	i_unknown_command; 
	input	i_unknown_func;
	input	i_interrupt_request;		// 中断请求信号
	input	i_syscall;
	input	i_break;
	input	i_mtc0;
	input	i_mfc0;
	input	i_eret;
	input	i_mult_div;					// 译码阶段为乘除法信号
	input	i_id_exe_mult_div;			// 执行阶段为乘除法信号
	input	i_ready;					// 执行阶段为乘除法信号
	input	i_next_is_dslot;			// 转移指令判断信号 用于ID级
	input	i_id_exe_is_dslot;			// 延迟槽判断信号 用于ID级
	input	i_exe_mem_is_dslot;			// 延迟槽判断信号 用于EXE级

	input	[31:0]	i_if_pc;
	input	[31:0]	i_if_id_pc;
	input	[31:0]	i_id_exe_pc;
	input	[31:0]	i_exe_mem_pc;
	input	[31:0]	i_data;				// 写C0寄存器数据
	input	[ 4:0]	i_address;			// 寄存器地址
	input	[ 5:0]	i_interrupt_source;	// 中断源信号

	output	o_exception;				// 中断 异常信号
	
	output	reg	o_interrupt_answer;		// 中断响应信号
	output	reg	o_id_continue;			// 中断时指令继续执行
	output	reg	o_mult_div_cancel;		// 中断时执行阶段的乘除法指令取消

	output	reg [ 5:0] o_interrupt_source;	// 经过屏蔽后的中断源

	output	[31:0]	o_eret_pc;			// 中断异常返回地址
	output	[31:0]	o_excep_pc;			// 中断入口地址
	output	[31:0]	o_cp0_data;			// 读C0寄存器数据
	
	reg	[31:0]	pc_to_epc;				// 写入EPC的pc地址
	// reg	[31:0]	excep_entry;		// 中断处理程序地址

	localparam EXCEPTION_ENTRY = 32'h00000008;
	
	// reg	interrupt_processing;			// 中断状态寄存器

	reg [4:0]	exc_code;				// CAUSE寄存器Exc Code字段 异常编码
	reg [7:0]	ip;						// CAUSE寄存器IP字段
	reg [7:0]	im;						// STATUS寄存器中断屏蔽字段
	reg [1:0]	ksu_reg;				// 锁存STATUS寄存器KSU字段
	reg ie_reg;							// 锁存STATUS寄存器中断使能字段
	reg exl_reg;							// 锁存STATUS寄存器EXL字段
	// reg last_ie;						// 暂存中断异常处理前的 STATUS寄存器中断使能字段
	reg bd;								// CAUSE字段BD位 如果BD位位1则代表异常指令发生在延迟槽

	reg ir_reg;							// 记录中断信号上升沿

	reg r_interrupt_request;			// 使用寄存器产生一个稳定的中断请求信号

	wire [1:0]	ksu;					// STATUS寄存器KSU字段
	wire ie;								// STATUS寄存器中断使能字段
	wire exl;							// STATUS寄存器EXL字段

	wire status_we;						// 状态寄存器STATUS写使能
	wire cause_we;						// 异常中断原因寄存器CAUSE写使能
	wire epc_we;							// 异常程序计数器EPC写使能

	// wire ie_from_status;				// 从STATUS寄存器读出的ie值
	// wire exl_from_status;				// 从STATUS寄存器读出的exl值

	wire accept_exception;				// 可接受中断或异常状态

	wire interrupt_request;				// 结合中断描述位和中断屏蔽位判断后的有效中断请求信号
	wire exception;						// 产生中断或异常
	
	wire is_kernel;						// 工作在核心态

	wire [31:0]	epc, cause, status;		// EPC CAUSE STATUS寄存器读出结果
	wire [31:0] status_data;				// 写STATUS寄存器数据
	wire [31:0] cause_data;				// 写CAUSE寄存器数据

	// wire [ 5:0] int_source;
	// assign int_source = i_interrupt_source;

	assign status_data = {16'b0, im[7:0], 3'b0, ksu, 1'b0, exl, ie};
	assign cause_data = {bd, 15'b0, ip[7:0], 1'b0, exc_code[4:0], 2'b00};

	// assign status_data = {16'b0, im[7:0], 7'b0, ie};
	// assign cause_data = {16'b0, ip[7:0], 1'b0, exc_code[4:0], 2'b00};

	assign status_we	 = (i_mtc0 & i_address == STATUS_ADDR & is_kernel) | i_eret | epc_we;
	// 中断返回时不重写CAUSE寄存器
	assign cause_we	= (i_mtc0 & i_address == CAUSE_ADDR  & is_kernel) | epc_we; // | i_eret
	// 
	assign epc_we = (i_overflow & (im[1:0] == 2'b01) |
					(i_syscall | i_break | i_unknown_command | i_unknown_func | i_divzero) & (im[1:0] == 2'b10) |
					r_interrupt_request & (im[1:0] == 2'b00)) & accept_exception;
					// & ie_from_status & ~exl_from_status;

	// assign ie_from_status	= status[0];
	// assign exl_from_status	= status[1];

	// assign o_interrupt_source = (im[7:2] & ip[7:2]);

	assign accept_exception = ~exl_reg & ie_reg;

	// 注意这里使用的是单独的IP而不是CAUSE 原因是硬件中断源无法直接促使CAUSE可写?
	assign interrupt_request = (|(status[15:10] & i_interrupt_source[5:0])) & i_interrupt_request;
	// always @(posedge i_clk or negedge i_rstn) begin
	// 	if (~i_rstn) begin
	// 		// reset
	// 		interrupt_request <= 1'b0;
	// 	end
	// 	else begin
	// 		interrupt_request <= (|i_interrupt_source & status[15:8]) & i_interrupt_request;
	// 	end
	// end
	
	// assign interrupt_request = (|o_interrupt_source) & ir_reg;

	assign is_kernel = ~ksu_reg[1] & ~ksu_reg[0];

	assign exception = epc_we;

	// 开中断 关中断
	// 通过对exl进行置位 清零操作实现 STATUS其他位不做处理
	assign ie = status[0];
	assign exl = exception ? 1'b1 : (i_eret ? 1'b0 : status[1]);
	assign ksu = exception ? 2'b00 : (i_eret ? 2'b10 : status[4:3]);
	
	assign o_exception	= exception;
	assign o_eret_pc	= epc;
	assign o_excep_pc	= EXCEPTION_ENTRY;

	wire [31:0] status_in;	
	wire [31:0] cause_in;
	wire [31:0] epc_in;

	// always @(posedge i_interrupt_request or edge i_rstn) begin
	// 	if (~rst) begin
	// 		// reset
	// 		ir_reg <= 1'b0;
	// 	end
	// 	else begin
	// 		ir_reg <= 1'b1;
	// 	end
	// end

	mux2in1 STATUS_OP(
		.i_data0(status_data),
		.i_data1(i_data),
		.i_ctrl(i_mtc0 & i_address == STATUS_ADDR),
		.o_data(status_in)
		);

	mux2in1 CAUSE_OP(
		.i_data0(cause_data),
		.i_data1(i_data),
		.i_ctrl(i_mtc0 & i_address == CAUSE_ADDR),
		.o_data(cause_in)
		);

	mux2in1 EPC_OP(
		.i_data0(pc_to_epc),
		.i_data1(i_data),
		.i_ctrl(i_mtc0 & i_address == EPC_ADDR),
		.o_data(epc_in)
		);

	// 写Status寄存器
	dffe32 STATUS(
		.i_clk(~i_clk),
		.i_rstn(i_rstn),
		.i_we(status_we),
		.i_data(status_in),
		.o_data(status)
		);
 
	// 写Cause寄存器
	dffe32 CAUSE(
		.i_clk(~i_clk),
		.i_rstn(i_rstn),
		.i_we(cause_we),
		.i_data(cause_in),
		.o_data(cause)
		);
	
	// 写EPC寄存器
	dffe32 EPC(
		.i_clk(~i_clk),
		.i_rstn(i_rstn),
		.i_we(epc_we | (i_mtc0 & i_address == EPC_ADDR & is_kernel)),
		.i_data(epc_in),
		.o_data(epc)
		);

	// 处理中断与异常
	// 异常不可屏蔽
	// bd位为1 代表异常指令为EPC+4处 
	// 实现精确中断处理方式
	// 异常时流水线取指、译码部件的指令会被取消
	// 中断时若译码部件为转移指令 则取消译码部件指令 其他情况译码部件指令会执行完毕
	always @(*) begin
//		if (~i_rstn) begin
			pc_to_epc	= 32'b0;
			exc_code	= 5'b0;
			im[1:0]		= 2'b0;
			ip[1:0]		= 2'b0;
			bd			= 1'b0;
			o_id_continue = 1'b1;
			o_mult_div_cancel = 1'b0;
//		end else begin
			// 溢出
			if (i_overflow & accept_exception) begin 	// 溢出异常 执行时检测到发生 优先级最高
				if (i_exe_mem_is_dslot) begin		// 如果溢出发生在延迟槽指令
					pc_to_epc = i_exe_mem_pc;		// 异常返回地址为即上条指令(转移指令)的地址
					bd = 1'b1;						// BD位置1 表示异常指令地址为EPC+4
					o_id_continue = 1'b0;			// 取消下一条指令和下下一条指令
				end									// 即译码部件当前指令和取指部件指令
				else begin 							// 其他情况
					pc_to_epc = i_id_exe_pc;			// 异常返回地址来自执行部件 即当前指令
					o_id_continue = 1'b0;			// 取消当前指令和下一条指令
				end									// 即译码部件当前指令和取指部件指令
				im[1:0]		= 2'b01;					// 修改中断屏蔽位
				ip[1:0]		= 2'b01;
				exc_code	= 5'b01100;				// 记录类型代码
			end	
			// 除零 译码阶段检测到
			else if (i_divzero & accept_exception) begin 			
													// 除零异常 译码时检测到发生
				if (i_id_exe_is_dslot) begin			// 如果当前指令是延迟槽指令(指未知指令异常 
													// 系统调用指令不能出现在延迟槽)
					pc_to_epc = i_id_exe_pc;			// 异常返回地址为上条指令(转移指令)的地址
					bd = 1'b1;						// BD位置1 表示异常指令地址为EPC+4
					o_id_continue = 1'b0;			// 取消当前指令
				end 
				else if (!i_ready | i_id_exe_mult_div) begin	// 如果EXE阶段是乘除法指令
					pc_to_epc = i_id_exe_pc;			// 异常返回指令为前一条乘除法指令
					bd = 1'b1;						// BD位置1 表示异常指令地址为EPC+4
					o_id_continue = 1'b0;			// 当前指令取消
					o_mult_div_cancel = 1'b1;		// EXE阶段乘除法指令取消
				end
				else begin							// 取消下一条指令(转移指令执行后得到的指令)
					pc_to_epc = i_if_id_pc;			// 其他情况 异常返回地址来自译码部件(当前指令)
					o_id_continue = 1'b0;			// 取消当前指令
				end									// 取消下一条指令(取指部件取出指令)
				im[1:0]		= 2'b01;					// 修改中断屏蔽位
				ip[1:0]		= 2'b01;
				exc_code	= 5'b01101;				// 记录类型代码
			end	
			// 用户态访问了特权指令异常
			else if ((i_mtc0 | i_eret | i_mfc0) & ~is_kernel & accept_exception) begin
				if (!i_ready | i_id_exe_mult_div) begin	// 如果EXE阶段是乘除法指令
					pc_to_epc = i_id_exe_pc;			// 异常返回指令为前一条乘除法指令
					bd = 1'b1;						// BD位置1 表示异常指令地址为EPC+4
					o_id_continue = 1'b0;			// 当前指令取消
					o_mult_div_cancel = 1'b1;		// EXE阶段乘除法指令取消
				end
				else if (i_id_exe_is_dslot) begin	// 如果当前指令是延迟槽指令(指未知指令异常 
													// 系统调用指令不能出现在延迟槽)
					pc_to_epc = i_id_exe_pc;			// 异常返回地址为上条指令(转移指令)的地址
					bd = 1'b1;						// BD位置1 表示异常指令地址为EPC+4
					o_id_continue = 1'b0;			// 取消当前指令
				end else begin						// 取消下一条指令(转移指令执行后得到的指令)
					pc_to_epc = i_if_id_pc;			// 其他情况 异常返回地址来自译码部件(当前指令)
					o_id_continue = 1'b0;			// 取消当前指令
				end									// 取消下一条指令(取指部件取出指令)
				im[1:0]		= 2'b10;					// 修改中断屏蔽位
				ip[1:0]		= 2'b10;
				exc_code	= 5'b01011;				// 用户态访问特权指令异常
			end
			// 保留指令 syscall break异常 译码时检测到发生
			else if ((i_syscall | i_break | i_unknown_func | i_unknown_command) 
					& accept_exception) begin
				if (!i_ready | i_id_exe_mult_div) begin	// 如果EXE阶段是乘除法指令
					pc_to_epc = i_id_exe_pc;			// 异常返回指令为前一条乘除法指令
					bd = 1'b1;						// BD位置1 表示异常指令地址为EPC+4
					o_id_continue = 1'b0;			// 当前指令取消
					o_mult_div_cancel = 1'b1;		// EXE阶段乘除法指令取消
				end
				else if (i_id_exe_is_dslot) begin	// 如果当前指令是延迟槽指令(指未知指令异常 
													// 系统调用指令不能出现在延迟槽)
					pc_to_epc = i_id_exe_pc;			// 异常返回地址为上条指令(转移指令)的地址
					bd = 1'b1;						// BD位置1 表示异常指令地址为EPC+4
					o_id_continue = 1'b0;			// 取消当前指令
				end else begin						// 取消下一条指令(转移指令执行后得到的指令)
					pc_to_epc = i_if_id_pc;			// 其他情况 异常返回地址来自译码部件(当前指令)
				end									// 取消下一条指令(取指部件取出指令)
				im[1:0]		= 2'b10;					// 修改中断屏蔽位
				ip[1:0]		= 2'b10;
				exc_code	= (i_syscall == 1'b1 ? 5'b01000 : (i_break == 1'b1 ? 5'b01001 : 5'b01010));
			end	
			// 外部中断									
			else if(r_interrupt_request & accept_exception) begin			
													// 处理外部中断 立即响应中断 取消部分流水线已取出指令
				if (i_mult_div) begin				// 如果中断发生时 ID阶段是乘除法指令
					pc_to_epc = i_if_id_pc;			// 中断返回地址仍为此乘除法指令
					o_id_continue = 1'b0;			// 乘除法指令取消
				end 
				else if (!i_ready | i_id_exe_mult_div) begin // 如果中断发生时 EXE阶段是乘除法指令
					pc_to_epc = i_id_exe_pc;			// 中断返回指令仍为此乘除法指令 乘除法指令取消
					o_id_continue = 1'b0;			// ID指令取消
					o_mult_div_cancel = 1'b1;		// EXE阶段乘除法指令取消
					// bd = 1'b1;					// bd位置1 表示
				end
				else if (i_next_is_dslot) begin		// 如果中断发生时 ID阶段指令是转移指令(延迟)
					pc_to_epc = i_if_id_pc;			// 中断返回地址仍为此转移指令 下一条指令(延迟槽)取消
					o_id_continue = 1'b0;			// 取消译码部件指令 避免链接指令写寄存器
				end									// 延迟槽指令不能同时是转移指令!!!!!!!
				else if (i_id_exe_is_dslot) begin	// 如果中断发生时 ID阶段指令是延迟槽指令
					pc_to_epc = i_if_pc;				// 中断返回地址 为转移指令执行后得到的指令
					o_id_continue = 1'b1;			// 不取消延迟槽指令(译码部件当前指令)		
				end									// 下一条指令(转移指令执行后得到的指令)取消
				else begin							// 一般情况
					pc_to_epc = i_if_pc;				// 中断返回地址来自取指部件
					o_id_continue = 1'b1;			// 译码部件指令继续执行
				end									// 下一条指令(取指部件取出指令)取消
				im[1:0]		= 2'b00;					// 修改中断屏蔽位
				ip[1:0]		= 2'b00;
				exc_code	= 5'b00000;				// 记录类型代码
			end 
//			else begin
//				o_id_continue		= 1'b1;
//				o_mult_div_cancel	= 1'b0;		
//			end	
			// else if (i_clk) begin
			// 	pc_to_epc	= 32'b0;
			// 	exc_code	= 5'b0;
			// 	im[1:0]		= 2'b0;
			// 	ip[1:0]		= 2'b0;
			// 	bd			= 1'b0;
			// 	o_id_continue = 1'b1;
			// 	o_mult_div_cancel = 1'b0;
			// end
//		end
	end

	// 开中断 关中断
	// 通过对exl进行置位 清零操作实现 STATUS其他位不做处理
	// assign ie = status[0];
	// assign exl = exception ? 1'b1 : (i_eret ? 1'b0 : status[1]);
	// assign ksu = exception ? 2'b00 : (i_eret ? 2'b10 : status[4:3]);
	always @(posedge i_clk or negedge i_rstn) begin
		if (~i_rstn) begin
			// reset
			ie_reg		<= 1'b0;		// 默认关中断
			exl_reg		<= 1'b0;
			ksu_reg		<= 2'b0;
			o_interrupt_answer	<= 1'b0;
		end
		// else if (i_eret & last_ie) begin
		// 	exl		<= 1'b0;			// 清除exl
		// 	ksu		<= 2'b10;			// 恢复用户态
		// end
		// else if (epc_we) begin
		// 	exl		<= 1'b1;			// 置exl
		// 	ksu		<= 2'b0;			// 进入内核态
		// end
		else begin
			ie_reg		<= status[0];	
			exl_reg		<= status[1];
			ksu_reg		<= status[4:3];
			if (epc_we & interrupt_request) begin
				o_interrupt_answer	<= 1'b1;
			end
			else begin
				o_interrupt_answer	<= 1'b0;
			end
		end
	end
	// always @(*) begin
	// 	if (~i_rstn) begin
	// 		// reset
	// 		ie		= 1'b0;			// 默认关中断
	// 		exl		= 1'b0;
	// 		ksu		= 2'b0;
	// 	end
	// 	else if (i_eret & last_ie) begin
	// 		exl		= 1'b0;			// 清除exl
	// 		ksu		= 2'b10;			// 恢复用户态
	// 	end
	// 	else if (epc_we) begin
	// 		exl		= 1'b1;			// 置exl
	// 		ksu		= 2'b0;			// 进入内核态
	// 	end
	// 	else begin
	// 		ie		= status[0];	
	// 		exl		= status[1];
	// 		ksu		= status[4:3];
	// 	end
	// end

	// // 中断异常状态切换
	// always @(posedge i_clk or negedge i_rstn) begin
	// 	if (~i_rstn) begin
	// 		interrupt_processing <= 1'b0;			// 中断状态 非中断
	// 		excep_entry <= EXCEPTION_ENTRY;			// 中断处理程序入口地址初始化
	// 		o_interrupt_answer <= 1'b0;				// 中断应答信号	
	// 	end 
	// 	else begin
	// 		if (epc_we) begin
	// 			interrupt_processing <= 1'b1;		// 中断状态 中断
	// 			o_interrupt_answer <= interrupt_request == 1'b1 ? 1'b1 : 1'b0;// 中断响应
	// 		end else begin
	// 			o_interrupt_answer <= 1'b0;
	// 		end
	// 		// if(i_eret & last_ie) begin
	// 		if(i_eret) begin
	// 			interrupt_processing <= 1'b0;		// 中断状态 非中断
	// 		end
	// 	end
	// end

	// 暂存中断 异常处理前的status状态寄存器数据
	always @(posedge i_clk or negedge i_rstn) begin
		if (~i_rstn) begin
			// last_ie <= 0;
			// ksu		<= 0;
			im[7:2]	<= 0;
			ip[7:2]	<= 0;
			r_interrupt_request	<= 0;
			o_interrupt_source 	<= 0;
		end
		else begin
			// ksu			<= status[4:3];
			im[7:2]		<= status[15:10];
			ip[7:2]		<= i_interrupt_source[5:0];
			r_interrupt_request			<= (|(status[15:10] & i_interrupt_source[5:0])) & i_interrupt_request;
			o_interrupt_source[5:0] 	<= status[15:10] & i_interrupt_source[5:0];
			// if (exception) begin
			// 	last_ie	<= status[0];
			// end
		end
	end

	// always @(posedge i_clk or negedge i_rstn) begin
	// 	if (i_rstn) begin
	// 		// reset
	// 		o_exception	<= 1'b0;
	// 	end
	// 	else if (exception) begin
	// 		o_exception	<= 1'b1;
	// 	end
	// 	else begin
	// 		o_exception	<= 1'b0;
	// 	end
	// end

	// 读cp0输出
	mux4in1 CP0_DATA(
		.i_data0(status),
		.i_data1(cause),
		.i_data2(epc),
		.i_data3(32'b0),
		.i_ctrl(i_address[1:0]),
		.o_data(o_cp0_data)
		);
	
	// always @(*) begin 
	// 	case(i_address)
	// 		STATUS_ADDR:	o_cp0_data = status;
	// 		CAUSE_ADDR:		o_cp0_data = cause;
	// 		EPC_ADDR:		o_cp0_data = epc;
	// 		default:		o_cp0_data = 32'b0;
	// 	endcase 

	// 	o_eret_pc	= epc;
	// 	o_exception	= epc_we & ~exl_from_status & ie_from_status;
	// 	o_excep_pc	= excep_entry;
	// end

	

endmodule
