`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/30 10:42:53
// Design Name: 
// Module Name: timer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 定时器
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module timer(
	i_clk,
	i_rstn,
	i_we,
	i_re,
	i_op,
//	i_inta0,
//	i_inta1,
	i_data,
//	o_ir0,
//	o_ir1,
	o_data,
	o_out0,
	o_out1
	);
	
	/////////////////////////////////////////////////////////////////////////////
	// 含有两个定时计数器 每个定时计数器各有四个寄存器 定义及地址如下
	// op取地址线[3:1]
	// 方式寄存器		[0]op:000(0xfffffc20)	[1]op:001(0xfffffc22)
	// 状态寄存器		[0]op:010(0xfffffc24)	[1]op:011(0xfffffc26)
	// 初始值寄存器		[0]op:100(0xfffffc28)	[1]op:101(0xfffffc2a)
	// 当前值寄存器		[0]op:110(0xfffffc2c)	[1]op:111(0xfffffc2e)
	/////////////////////////////////////////////////////////////////////////////

	/////////////////////////////////////////////////////////////////////////////
	// 中断请求信号为一个脉冲
	/////////////////////////////////////////////////////////////////////////////

	input	i_clk;
	input	i_rstn;
	input	i_we;				// 写使能
	input	i_re;				// 读使能
//	input	i_inta0;			// 中断响应0
//	input	i_inta1;			// 中断响应1
	
	input	[ 2:0] i_op;
	input	[15:0] i_data;
	output	[15:0] o_data;
	
//	output	o_ir0;				// 中断请求0
//	output	o_ir1;				// 中断请求1
	output	o_out0;				// 定时输出
	output	o_out1;				// 定时输出

	wire	[15:0] data0, data1;
	// wire	out0, out1;
	wire	cnt_clk;

	assign	o_data	= i_re ? (i_op[0] ? data1 : data0) : 16'b0;
	// assign	o_out	= i_op[0] ? out1 : out0;
	
	//分频到23kHz
	clk_div #(.COUNT(500)) CLK_DIV(
		.i_clk(i_clk),
		.i_rstn(i_rstn),
		.o_clk(cnt_clk)
		);
			
	// 定时计数器0
	cnt CNT0(
		.i_clk(i_clk),
		.i_timer_clk(cnt_clk),
//		.i_timer_clk(i_clk),
		.i_rstn(i_rstn),
		.i_we(i_we & ~i_op[0]),
		.i_re(i_re & ~i_op[0]),
		.i_op(i_op[2:1]),
//		.i_inta(i_inta0),
		.i_data(i_data),
		.o_data(data0),
//		.o_ir(o_ir0),
		.o_out(o_out0)
		);

	// 定时计数器1
	cnt CNT1(
		.i_clk(i_clk),
		.i_timer_clk(cnt_clk),
//		.i_timer_clk(i_clk),	// sim
		.i_rstn(i_rstn),
		.i_we(i_we & i_op[0]),
		.i_re(i_re & i_op[0]),
		.i_op(i_op[2:1]),
//		.i_inta(i_inta1),
		.i_data(i_data),
		.o_data(data1),
//		.o_ir(o_ir1),
		.o_out(o_out1)
		);

endmodule

// 定时器模块
module cnt(
	i_clk,
	i_timer_clk,
	i_rstn,
	i_we,
	i_re,
	i_op,
//	i_inta,
	i_data,
	o_data,
//	o_ir,
	o_out
	);
	
	/////////////////////////////////////////////////////////////////////////////
	// 每个定时计数器各有四个寄存器 定义及地址如下
	// op取地址线[3:2]
	// 方式寄存器	op:00	reg[15:2] 闲置	reg[1] 重复/非重复	reg[0] 定时/计数
	// 状态寄存器	op:01	reg[15] 有效/无效	reg[14:2] 闲置	reg[1] 计数到	reg[0] 定时到
	// 初始值寄存器	op:10	定时/计数初始值
	// 当前值寄存器	op:11	定时/计数当前值
	/////////////////////////////////////////////////////////////////////////////

	input	i_clk;
	input	i_timer_clk;
	input	i_rstn;
	input	i_we;
	input	i_re;
//	input	i_inta;
	
	input	[ 1:0] i_op;
	input	[15:0] i_data;
	
	// output	reg [15:0] o_data;
	output	[15:0] o_data;

	output	o_out;
//	output	reg o_ir;
	
//	reg		r_ontimer;
	
	reg		[15:0] count;	// 计数值
	
	reg		[ 1:0] state;	// 写状态 [00] 默认 [01]写了方式字 [10]写了初始值 定时计数正在工作

	reg		read_status;	// 读status  用于read_reset的一个周期的延迟
	reg		read_reset;		// 读status后 status寄存器清零
	
	reg		start;			// 写初始字后状态 定时 计数开始
	reg		get_first;		// 定时器 计数寄存器获得了第一个计数值

	wire	[15:0] way;
	wire	[15:0] status;
	wire	[15:0] ini_val;
	wire	[15:0] now_val;
	
	wire	way_we, ini_we, sta_re, now_re;
	wire	is_count, is_repeat;

	wire	first_count;	// 写初始值后的第一次计数

	wire	count_valid;	// 是否有效
	wire	on_timer;		// 定时到
	wire	on_count;		// 计数到

	// 方式寄存器 初始值寄存器 写使能
	assign	way_we = i_we & !i_op;
	assign	ini_we = i_we & i_op[1] & ~i_op[0];
	
	// 状态寄存器 当前值寄存器 读使能	
	assign 	sta_re = i_re & ~i_op[1] & i_op[0];
	assign 	now_re = i_re & i_op[1] & i_op[0];

	assign	is_count	= way[0];
	assign	is_repeat	= way[1];

	// 在写了初始值 以及定时计数器工作时有效
	// 读状态寄存器后无效
	assign	count_valid = read_reset ? 1'b0 : state[1];

	// 定时 计数完成时的信号
	assign	on_timer = count_valid & ~is_count & count == 1;
	assign	on_count = count_valid & is_count & count == 0;

	// 定时到1时输出一个时钟的低电平
	assign	o_out = on_timer ? 1'b0 : 1'b1;

	assign	first_count = state[1] & ~state[0] | start & ~get_first;

	// // 选择正确的输出结果
	// always @(posedge i_clk or negedge i_rstn) begin
	// 	if (~i_rstn) begin
	// 		// reset
	// 		o_data	<= 0;
	// 	end
	// 	else if (sta_re) begin
	// 		o_data	<= status;
	// 	end
	// 	else if (now_re) begin
	// 		o_data	<= now_val;
	// 	end
	// 	else begin
	// 		o_data	<= 0;
	// 	end
	// end
	
	// // 对定时器的下降沿信号进行触发
	// always @(posedge o_out or negedge o_out) begin
	// 	if (o_out)
	// 		r_ontimer	<= 1'b1;
	// 	else
	// 		r_ontimer	<= 1'b0;
	// end
	
	// // 在时钟下降沿产生中断请求信号
	// always @(negedge i_clk or posedge i_rstn) begin
	// 	if (~i_rstn) begin
	// 		// reset
	// 		o_ir	<= 1'b0;
	// 	end
	// 	// 定时器产生定时到信号
	// 	else begin 
	// 		if (i_inta) begin
	// 			o_ir	<= 1'b0;
	// 		end
	// 		else if (r_ontimer) begin
	// 			o_ir	<= 1'b1;
	// 		end
			
	// 	end
	// end

	mux4in1 #(.WIDTH(16)) OUT_OP(
		.i_data0(way),
		.i_data1(status),
		.i_data2(ini_val),
		.i_data3(now_val),
		.i_ctrl(i_op),
		.o_data(o_data)
		);

	// 方式寄存器
	dffe16	WAY_REG(
		.i_clk(~i_clk),
		.i_rstn(i_rstn),
		.i_we(way_we),
		.i_data(i_data),
		.o_data(way)
		);

	// 产生状态寄存器读后清零信号
	always @(posedge i_clk or negedge i_rstn) begin
		if (~i_rstn) begin
			// reset
			read_reset	<= 1'b0;
			read_status	<= 1'b0;
		end
		else if (sta_re) begin
			read_status	<= 1'b1;
			read_reset	<= read_status;
		end
		else begin
			read_status	<= 1'b0;
			read_reset	<= read_status;
		end
	end
	
	// 状态寄存器
	// 只读 读后清零
	// 状态寄存器输出值
	assign	status = {count_valid, 13'b0, on_count, on_timer};
	// always @(posedge i_clk or negedge i_rstn) begin
	// 	if (~i_rstn) begin
	// 		// reset
	// 		status		<= 0;
	// 		status_read	<= 0;
	// 	end
	// 	else begin
	// 		status		<= i_re & ~i_op[1] & i_op[0] 
	// 					? 0 : {count_valid, 13'b0, on_count, on_timer};
	// 		status_read	<= status;
	// 	end
	// end
	// dffe16	STA_REG(
	// 	.i_clk(i_clk),
	// 	.i_rstn(i_rstn),
	// 	.i_we(1'b1),
	// 	.i_data({count_valid, 13'b0, on_count, on_timer}),
	// 	.o_data(status)
	// 	);

	// 初始值寄存器 只写
	dffe16	INI_REG(
		.i_clk(~i_clk),
		.i_rstn(i_rstn),
		.i_we(ini_we),
		.i_data(i_data),
		.o_data(ini_val)
		);
	
	// 当前值寄存器 只读
	assign	now_val = first_count ? ini_val : count;
	// dffe16	NOW_REG(
	// 	.i_clk(i_clk),
	// 	.i_rstn(i_rstn),
	// 	.i_we(1'b1),
	// 	.i_data(count),
	// 	.o_data(now_val)
	// 	);

	// 先写方式字 再写初始值 之后计数才开始
	always @(posedge ~i_clk or negedge i_rstn) begin
		if (~i_rstn) begin
			state		<= 2'b00;
		end 
		else begin
			case(state)
				2'b00:	state	<= way_we ? 2'b01 : 2'b00;
				2'b01:	state	<= ini_we ? 2'b10 : 2'b01;
				2'b10:	state	<= ini_we ? 2'b10 : 2'b11;
				2'b11:	state	<= way_we ? 2'b01 : 
								   (ini_we ? 2'b10 : 
								   (read_reset ? 2'b00 : 2'b11));
			endcase
		end
	end
	// 写初始值后的第一个计数周期判定
	always @(posedge ~i_clk or negedge i_rstn) begin
		if (~i_rstn) begin
			start	<= 1'b0;
		end 
		else begin
			if (state == 2'b10) begin
				start	<= 1'b1;
			end
			else if(get_first) begin
				start	<= 1'b0;
			end
		end	
	end
	
	// 计数 定时
	always @(posedge i_timer_clk or negedge i_rstn) begin
		if (~i_rstn) begin
			// reset
			count		<= 0;
			get_first	<= 0;
		end
		else if (first_count) begin
//		else if (ini_we) begin
				count	<= ini_val-1;		// 初始值减1送入计数寄存器
				get_first	<= 1'b1;
		end 
		else if (count_valid) begin
			get_first	<= 1'b0;			// 已经取得初始计数值开始工作
			if (!count) begin
				if (is_repeat)
					count	<= ini_val;		// 计数完成 并且重复计数 则重新计数
			end
			else begin
				count	<= count - 1;		// 计数 计数值减1
			end
		end
	end
endmodule