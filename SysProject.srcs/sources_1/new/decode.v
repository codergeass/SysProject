`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/20 13:49:20
// Design Name: 
// Module Name: decode
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 译码单元
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module decode(
	i_clk, 
	i_rstn,
	i_reg_write,  
	i_reg_data, 
	i_pc_plus4, 
	i_instr,
	i_alu_res, 
	i_mem_data,
	i_id_exe_reg_dst,
	i_exe_mem_reg_dst,
	i_mem_wb_reg_dst,
	i_id_exe_reg_write,
	i_exe_mem_reg_write,
	i_mem_wb_reg_write,
	i_id_exe_mem_read,
	i_overflow,
	i_interrupt_request,
	i_interrupt_source,
	i_if_pc,
	i_if_id_pc,
	i_id_exe_pc,
	i_exe_mem_pc,
	i_id_exe_is_dslot,
	i_exe_mem_is_dslot,
	i_wb_hi,
	// i_wb_lo,
	i_exe_hi,
	// i_exe_lo,
	i_mem_hi,
	// i_mem_lo,
	i_id_exe_hi_lo_write,
	i_exe_mem_hi_lo_write,
	i_mem_wb_hi_lo_write,
	i_id_exe_mult_div,
	i_ready,
	o_alu_ctrl, 
	o_pc_store,
	o_next_pc, 
	o_eret_pc,
	o_excep_pc,
	o_pc_src,
	// o_alu_src1, 
	// o_alu_src2,
	o_decode_src1,
	o_decode_src2,
	o_alu_src_op1,
	o_alu_src_op2,
	o_extend_op,
	o_reg_dst,
	o_reg_write,
	o_data_width,
	o_mem_read,
	o_mem_write,
	o_mem2reg,
	o_unsign,
	o_pc_write,
	o_ir_write,
	o_interrupt_answer,
	o_interrupt_source,
	o_mtc0,
	o_mfc0,
	o_eret,
	o_next_is_dslot,
	o_exception,
	o_id_continue,
	o_mult_div_cancel,
	o_stall,
	o_mfhi_lo,
	o_mult_div,
	o_divide,
	o_sign
	);

	input	i_clk;
	input	i_rstn;
	input	i_reg_write; 

	input	[31:0] i_reg_data; 

	input	[31:0] i_pc_plus4;
	input	[31:0] i_instr;

	input	[31:0] i_alu_res;				// alu结果
	input	[31:0] i_mem_data;				// 存储器数

	input	[ 4:0] i_id_exe_reg_dst;			// id-exe寄存器保存的目的操作数寄存器地址 用于上条指令exe阶段
	input	[ 4:0] i_exe_mem_reg_dst;		// exe-mem寄存器保存的目的操作数寄存器地址 用于上上条指令mem阶段
	input	[ 4:0] i_mem_wb_reg_dst;			// mem-wb寄存器保存的目的操作数寄存器地址 用于上上上条指令wb阶段 
											// 用于流水线控制信号产生

	input	i_id_exe_reg_write;				// id-exe寄存器保存的寄存器写使能信号 用于上条指令
	input	i_exe_mem_reg_write;			// exe-mem寄存器保存的寄存器写使能信号 用于上上条指令
	input	i_mem_wb_reg_write;				// mem-wb寄存器保存的寄存器写使能信号 用于上上上条指令
	input	i_id_exe_mem_read;				// id-exe寄存器保存的存储器读信号 代表上条指令为取数指令

	input	i_id_exe_hi_lo_write;			// id-exe寄存器保存的HI LO寄存器写使能信号 用于上条指令
	input	i_exe_mem_hi_lo_write;			// exe-mem寄存器保存的HI LO寄存器写使能信号 用于上上条指令
	input	i_mem_wb_hi_lo_write;			// mem-wb寄存器保存的HI LO寄存器写使能信号 用于上上上条指令

	input	i_overflow;						// 溢出标识
	input	i_interrupt_request;			// 外部中断信号
	input	i_id_exe_is_dslot;				// 执行部件延迟槽信号
	input	i_exe_mem_is_dslot;				// 存储器部件延迟槽信号
	
	input	i_id_exe_mult_div;				// 执行部件乘除法运算信号
	input	i_ready;						// 乘除法运算完成信号
	
	input	[31:0] i_if_pc;					// 取指部件pc
	input	[31:0] i_if_id_pc;				// 译码部件pc
	input	[31:0] i_id_exe_pc;				// 执行部件pc
	input	[31:0] i_exe_mem_pc;				// 存储器部件pc
	
	input	[ 5:0] i_interrupt_source;		// 中断源

	input	[31:0] i_exe_hi;					// 乘除法运算HI寄存器执行部件转发数据
	// input	[31:0] i_exe_lo;					// 乘除法运算LO寄存器执行部件转发数据
	input	[31:0] i_mem_hi;					// 乘除法运算HI寄存器存储器部件转发数据
	// input	[31:0] i_mem_lo;					// 乘除法运算LO寄存器存储器部件转发数据
	input	[31:0] i_wb_hi;					// 乘除法运算HI寄存器回写数据
	// input	[31:0] i_wb_lo;					// 乘除法运算LO寄存器回写数据
	
	output	[ 5:0] o_interrupt_source;		// 经过屏蔽后的中断源
	
	output	[31:0] o_decode_src1;			// 译码阶段得到源操作数1
	output	[31:0] o_decode_src2;			// 译码阶段得到源操作数2

	// output	[31:0] o_alu_src1;				// ALU源操作数1
	// output	[31:0] o_alu_src2;				// ALU源操作数2

	output	[ 4:0] o_reg_dst;				// 目的操作数寄存器地址
	output	[ 1:0] o_data_width;				// 存数取数指令数据宽度

	output	[31:0] o_next_pc;				// 转移 跳转 pc地址
	output	[31:0] o_eret_pc;				// 中断异常返回 pc地址
	output	[31:0] o_excep_pc;				// 中断处理 pc地址
	output	[ 1:0] o_pc_src;					// pc新地址来源
	output	[ 5:0] o_alu_ctrl;				// alu控制信号
	
	output	o_alu_src_op1;					// alu源操作数1 选择
	output	o_alu_src_op2;					// alu源操作数2 选择
	output	o_extend_op;					// 扩展方式选择
	
	output	o_reg_write;					// 寄存器写信号
	output	o_mem_read;						// 存储器读信号
	output	o_mem_write;					// 存储器写信号
	output	o_mem2reg;						// 存储器取数到寄存器信号
	output	o_unsign;						// 取数方式 字节 半字 是否进行符号扩展
	output	o_pc_write;						// pc写信号 用于流水线暂停
	output	o_ir_write;						// ir写信号 用于流水线暂停
	output	o_interrupt_answer;				// 中断响应信号
	output	o_pc_store;						// 跳转指令是否对pc进行存储
	output	o_mtc0;							// mtc0指令信号
	output	o_mfc0;							// mfc0指令信号
	output	o_eret;							// eret指令信号
	output	o_next_is_dslot;				// 下一条指令是延迟槽中的指令
	output	o_exception;					// 中断 异常指令信号
	output	o_id_continue;					// 中断时指令继续执行
	output	o_stall;						// 流水线暂停信号
	
	output	o_mfhi_lo;						// 读HI或LO寄存器数据指令信号
											// 不会发生同时读HI或LO

	output	o_mult_div;						// 乘除法运算信号
	output	o_mult_div_cancel;				// 中断时乘除法运算取消信号
	output	o_divide;						// 除法运算信号
	output	o_sign;							// 有符号乘除法信号

	// 内部信号
	wire	extend_op;						// 立即数扩展方式
	wire	alu_src_op1;					// alu源操作数1选择 [0]寄存器数 [1]指令shamt字段
	wire	alu_src_op2;					// alu源操作数2选择 [0]寄存器数 [1]来自imme扩展

	wire	mult;
	wire	multu;
	wire	div;
	wire	divu;
	wire	mfhi;
	wire	mflo;
	wire	mthi;
	wire	mtlo;
	wire	j;
	wire	jr;
	wire	jal; 
	wire	jalr; 
	wire	beq; 
	wire	bne;
	wire	bgez;
	wire	bgtz;
	wire	blez;
	wire	bltz;
	wire	bgezal;
	wire	bltzal; 

	wire	reg_dst_op;
	wire	reg_write;
	wire	mem_write;

	wire	syscall;
	wire	break_wire;
	
	wire	unknown_func;
	wire	unknown_command;

	wire	divzero;

	wire	[ 4:0] rs;					// rs字段
	wire	[ 4:0] rt;					// rt字段
	wire	[ 4:0] rd;					// rd字段
	wire	[ 5:0] op;					// op字段
	wire	[ 5:0] func;					// func字段
	wire	[15:0] imm;					// immediate字段
	wire	[25:0] addr;					// address字段

	// wire	[ 4:0] rt_or_r31;			// rt 或 $31的选择结果

	assign rs	= i_instr[25:21];
	assign rt	= i_instr[20:16];
	assign rd	= i_instr[15:11];
	assign op	= i_instr[31:26];
	assign func	= i_instr[ 5: 0];
	assign imm	= i_instr[15: 0];
	assign addr	= i_instr[25: 0];

	wire	[31:0] rs_data, rt_data;		// rs rt寄存器数

	wire	[31:0] decode_src1;			// 源操作数1的内部选择数据
	// wire	[31:0] decode_src2_in;		// 源操作数2的内部选择数据
	wire	[31:0] decode_src2;			// 源操作数2的内部选择数据
	wire	[31:0] cp0_data;				// 读cp0寄存器数数据 源操作数2的内部选择数据

	// wire	[31:0] byte_data;
	// wire	[31:0] half_data;
	// wire	[31:0] word_data;
	
	// wire	[31:0] extended_data;		// 扩展立即数

	wire	[31:0] exe_lo, mem_lo, wb_lo;
	
	wire	[31:0] hi, hi_in;
	wire	[31:0] lo, lo_in;
	wire	[31:0] hi_lo, hi_lo_in;
	wire	[31:0] exe_hi_lo, mem_hi_lo, wb_hi_lo;

	// wire	[23:0] sign_ext_byte;
	// wire	[15:0] sign_ext_half;
	
	wire	[ 1:0] forward_src_op1;
	wire	[ 1:0] forward_src_op2;
	wire	[ 1:0] forward_hi_lo;
	
	wire	[ 2:0] src2_ctrl;

	//////////////////////////////////////////////////////////////////////////////////////////////
	// 这部分转移到MEM阶段取数数据选择
	// assign sign_ext_byte = {24{i_reg_data[7]}};
	// assign sign_ext_half = {16{i_reg_data[15]}};
	// 
	// 根据是否进行符号扩展对数据进行扩展
	// assign byte_data = i_unsign ? {24'b0, i_reg_data[ 7:0]} : {sign_ext_byte, i_reg_data[ 7:0]};
	// assign half_data = i_unsign ? {16'b0, i_reg_data[15:0]} : {sign_ext_half, i_reg_data[15:0]};
	// 
	// 根据取数数据宽度选择正确的数据
	// mux4in1 REG_DATA_OP(
	// 	.i_data0(byte_data),
	// 	.i_data1(half_data),
	// 	.i_data2(i_reg_data),
	// 	.i_data3(i_reg_data),
	// 	.i_ctrl(i_data_width),
	// 	.o_data(word_data)
	// 	);
	//////////////////////////////////////////////////////////////////////////////////////////////
	assign exe_lo = i_alu_res;
	assign mem_lo = i_mem_data;
	assign wb_lo = i_reg_data;

	// 如果条件转移指令成立 写寄存器才有效
	// mult multu div divu 不写寄存器
	assign o_reg_write = ((bgezal | bltzal) & (o_pc_src == 2'b01)) ? 1'b1 : reg_write & ~o_mult_div;
	assign o_mem_write = mem_write;

	// 如果是跳转或者转移指令 则下一条指令是延迟槽中的指令
	assign o_next_is_dslot = j | jal | jr | jalr | beq | bne | bgez | bgtz | blez | bltz | bgezal | bltzal;

	// 确定HI LO寄存器的输入
	assign hi_in = mthi ? decode_src1 : i_wb_hi;
	assign lo_in = mtlo ? decode_src1 : wb_lo;

	// 确定HI LO寄存器的输出
	assign o_mfhi_lo = mfhi | mflo;
	
	assign hi_lo_in = mfhi ? hi : lo;
	assign exe_hi_lo = mfhi ? i_exe_hi : exe_lo;
	assign mem_hi_lo = mfhi ? i_mem_hi : mem_lo;
	assign wb_hi_lo = mfhi ? i_wb_hi : wb_lo;
	
	// assign src2_ctrl[0] = o_mfc0 ? 1'b1 : 1'b0;
	assign src2_ctrl = 	o_mfhi_lo ? 3'b111 : 
						{o_mfc0, forward_src_op2};

	// 与乘除法运算相关输出
	assign o_mult_div = mult | multu | div | divu;
	assign o_divide = div | divu;
	assign o_sign = mult | div;

	assign o_decode_src1 = decode_src1;
	assign o_decode_src2 = decode_src2;
	assign o_alu_src_op1 = alu_src_op1;
	assign o_alu_src_op2 = alu_src_op2;
	assign o_extend_op = extend_op;
	
	assign divzero = o_divide & !decode_src2;

	// // 确定目的操作数地址 [0]rt [1]$31
	// // assign rt_or_r31 = (jal | bgezal | bltzal) ? 31 : rt;
	// mux2in1 #(.WIDTH(5)) REG_DST_OP1( 
	// 	.i_data0(rt), 
	// 	.i_data1({5'b11111}),				// $31
	// 	.i_ctrl(jal | bgezal | bltzal), 
	// 	.o_data(rt_or_r31)
	// 	);

	// // 确定目的操作数地址 [0]rt [1]rd
	// // assign o_reg_dst = reg_dst_op & ~o_mfc0 ? rd : rt_or_r31;
	// mux2in1 #(.WIDTH(5)) REG_DST_OP2( 
	// 	.i_data0(rt_or_r31), 
	// 	.i_data1(rd), 
	// 	.i_ctrl(reg_dst_op & ~o_mfc0),	//  如果是mfc0指令则以rt作为目的操作数
	// 	.o_data(o_reg_dst)
	// 	);

	// 目的操作数地址
	mux4in1 #(.WIDTH(5)) REG_DST_OP(
		.i_data0(rt), 
		.i_data1(5'b11111),				// $31
		.i_data2(rd),
		.i_data3(5'b00000), 
		.i_ctrl({reg_dst_op & ~o_mfc0, jal | bgezal | bltzal}), 
		.o_data(o_reg_dst)
		);

	// HI LO读数据来源
	mux4in1 HI_LO_OP( 
		.i_data0(hi_lo_in),			// [00] 默认HI LO数据 无数据相关
		.i_data1(exe_hi_lo),		// [01] exe结果 流水线数据转发
		.i_data2(mem_hi_lo),		// [10] 存储器数据 流水线数据转发
		.i_data3(wb_hi_lo),			// [11] 写回数据 流水线数据转发
		.i_ctrl(forward_hi_lo), 
		.o_data(hi_lo)
		);

	// 源操作数来源1
	mux4in1 SRC1_OP(  
		.i_data0(rs_data),			// [00] 默认rs数据 无数据相关
		.i_data1(i_alu_res),		// [01] alu结果 流水线数据转发
		.i_data2(i_mem_data),		// [10] 存储器数据 流水线数据转发
		.i_data3(i_reg_data),		// [11] 寄存器写回数据 流水线数据转发
		.i_ctrl(forward_src_op1), 
		.o_data(decode_src1)
		);

	// 源操作数来源2
	mux8in1 SRC2_OP(
		.i_data0(rt_data),
		.i_data1(i_alu_res),
		.i_data2(i_mem_data),
		.i_data3(i_reg_data),
		.i_data4(cp0_data),
		.i_data5(32'b0),
		.i_data6(32'b0),
		.i_data7(hi_lo),
		.i_ctrl(src2_ctrl),
		.o_data(decode_src2)
		);
	
	// mux4in1 SRC2_OP1( 
	// 	.i_data0(rt_data),			// [00] 默认rt数据 无数据相关
	// 	.i_data1(i_alu_res),		// [01] alu结果 流水线数据转发
	// 	.i_data2(i_mem_data),		// [10] 存储器数据 流水线数据转发
	// 	.i_data3(i_reg_data),		// [11] 寄存器写回数据 流水线数据转发
	// 	.i_ctrl(forward_src_op2), 
	// 	.o_data(decode_src2_in)
	// 	);

	// // 将mfhi mflo mfc0的数据均通过源操作数src2进行传递
	// mux4in1 SRC2_OP2(
	// 	.i_data0(decode_src2_in),		
	// 	.i_data1(cp0_data),			// mfc0指令 数据来自cp0寄存器
	// 	.i_data2(hi_lo),			// mfhi指令 mflo指令 数据来自HI LO寄存器
	// 	.i_data3(hi_lo),			// mflo指令 mflo指令 数据来自LO Lo寄存器
	// 	.i_ctrl(src2_ctrl),
	// 	.o_data(decode_src2)
	// 	);

	// // 扩展器
	// sign_extend EXTENDER ( 
	// 	.i_data(imm), 
	// 	.i_ctrl(extend_op), 
	// 	.o_data(extended_data)
	// );

	// // 源操作数1的选择 [0]rs [1]shamt
	// mux2in1 ALU_SRC_OP1 ( 
	// 	.i_data0(decode_src1),
	// 	.i_data1({27'b0, imm[10:6]}),
	// 	.i_ctrl(alu_src_op1),
	// 	.o_data(o_alu_src1)
	// 	);

	// // 源操作数2的选择 [0]rt/c0/hi/lo [1]extended-immediate
	// mux2in1 ALU_SRC_OP2 ( 
	// 	.i_data0(decode_src2), 
	// 	.i_data1(extended_data), 
	// 	.i_ctrl(alu_src_op2), 
	// 	.o_data(o_alu_src2)
	// 	);

	// 寄存器组
	reg_file REGISTERS( 
		.i_clk(i_clk),
		.i_rstn(i_rstn), 
		.i_raddr1(rs), 
		.i_raddr2(rt), 
		.i_waddr(i_mem_wb_reg_dst),
		.i_wdata(i_reg_data), 
		.i_we(i_reg_write), 
		.o_rdata1(rs_data),
		.o_rdata2(rt_data)
		);

	// 乘除法运算与其他指令类似在写回阶段将数据写回到寄存器
	// 由于mthi mtlo指令的存在 译码阶段也可能会直接写HI LO寄存器
	// 这两者遇到冲突时 取后来的指令 即mthi mtlo
	// 为了保证能够在ID阶段写HI LO 将时钟反相
	// HI寄存器
	dffe32 HI(
		.i_clk(~i_clk),
		.i_rstn(i_rstn),
		.i_we(i_mem_wb_hi_lo_write | mthi),
		.i_data(hi_in),
		.o_data(hi)
		);

	// LO寄存器
	dffe32 LO(
		.i_clk(~i_clk),
		.i_rstn(i_rstn),
		.i_we(i_mem_wb_hi_lo_write | mtlo),
		.i_data(lo_in),
		.o_data(lo)
		);
	
	// 获得转移 跳转地址
	// 将EXE阶段结果符号判断提前到ID阶段 产生容量为一个指令的延迟槽
	nextPC NEXTPC ( 
		.i_pc_plus4(i_pc_plus4), 
		.i_addr(addr), 
		.i_j(j),
		.i_jal(jal), 
		.i_beq(beq), 
		.i_bne(bne),
		.i_bgez(bgez),
		.i_bgtz(bgtz),
		.i_blez(blez),
		.i_bltz(bltz),
		.i_bgezal(bgezal),
		.i_bltzal(bltzal), 
		.i_jr(jr),
		.i_jalr(jalr),
		.i_src1(decode_src1), 
		.i_src2(decode_src2),
		.i_exception(o_exception),
		.i_eret(o_eret),
		.o_next_pc(o_next_pc),
		.o_pc_src(o_pc_src),
		.o_pc_store(o_pc_store)
		);

	// alu控制单元 主要负责R型指令等特殊指令的信号
	// 用以分离控制单元的功能 
	alu_control ALU_CU(
		.i_op(op),
		.i_rs(rs), 
		.i_func(func), 
		.o_alu_ctrl(o_alu_ctrl),
		.o_alu_src_op(alu_src_op1),
		.o_mult(mult),
		.o_multu(multu),
		.o_div(div),
		.o_divu(divu),
		.o_mfhi(mfhi),
		.o_mflo(mflo),
		.o_mthi(mthi),
		.o_mtlo(mtlo),
		.o_jr(jr),
		.o_jalr(jalr),
		.o_syscall(syscall),
		.o_break(break_wire),
		.o_eret(o_eret),
		.o_mfc0(o_mfc0), 
		.o_mtc0(o_mtc0),
		.o_unknown_func(unknown_func)
		);

	// 控制单元
	control CU(
		.i_op(op),
		.i_rt(rt),
 		.o_j(j), 
 		.o_jal(jal), 
		.o_beq(beq),
		.o_bne(bne),
		.o_bgez(bgez),
		.o_bgtz(bgtz),
		.o_blez(blez),
		.o_bltz(bltz),
		.o_bgezal(bgezal),
		.o_bltzal(bltzal),
		.o_reg_dst_op(reg_dst_op),
		.o_mem2reg(o_mem2reg),
		.o_mem_write(mem_write),
		.o_mem_read(o_mem_read),
		.o_unsign(o_unsign),
		.o_data_width(o_data_width),
		.o_alu_src_op2(alu_src_op2),
		.o_reg_write(reg_write),
		.o_extend_op(extend_op),
		.o_unknown_command(unknown_command)
		);

	// 流水线控制器
	pipeline_control PIPE_CU(
		.i_rs(rs),
		.i_rt(rt),
		.i_id_exe_reg_dst(i_id_exe_reg_dst),
		.i_exe_mem_reg_dst(i_exe_mem_reg_dst),
		.i_mem_wb_reg_dst(i_mem_wb_reg_dst),
		.i_id_exe_reg_write(i_id_exe_reg_write),
		.i_exe_mem_reg_write(i_exe_mem_reg_write),
		.i_mem_wb_reg_write(i_mem_wb_reg_write),
		.i_id_exe_mem_read(i_id_exe_mem_read),
		.i_id_exe_hi_lo_write(i_id_exe_hi_lo_write),
		.i_exe_mem_hi_lo_write(i_exe_mem_hi_lo_write),
		.i_mem_wb_hi_lo_write(i_mem_wb_hi_lo_write),
		.i_mfhi_lo(o_mfhi_lo),
		.i_id_exe_mult_div(i_id_exe_mult_div),
		.i_exception(o_exception),
		.i_ready(i_ready),
		.o_forward_src_op1(forward_src_op1),
		.o_forward_src_op2(forward_src_op2),
		.o_forward_hi_lo(forward_hi_lo),
		.o_pc_write(o_pc_write),
		.o_ir_write(o_ir_write),
		.o_stall(o_stall)
		);

	// CP0协处理器
	cp0 CP0(
		.i_clk(i_clk), 
		.i_rstn(i_rstn),
		.i_overflow(i_overflow),
		.i_divzero(divzero),
		.i_unknown_command(unknown_command),
		.i_unknown_func(unknown_func),
		.i_interrupt_request(i_interrupt_request),
		.i_interrupt_source(i_interrupt_source),
		.i_syscall(syscall),
		.i_break(break_wire),
		.i_data(decode_src2),
		.i_address(rd),
		.i_if_pc(i_if_pc),
		.i_if_id_pc(i_if_id_pc),
		.i_id_exe_pc(i_id_exe_pc),
		.i_exe_mem_pc(i_exe_mem_pc),
		.i_next_is_dslot(o_next_is_dslot),
		.i_id_exe_is_dslot(i_id_exe_is_dslot),
		.i_exe_mem_is_dslot(i_exe_mem_is_dslot),
		.i_mtc0(o_mtc0),
		.i_mfc0(o_mfc0),
		.i_eret(o_eret),
		.i_mult_div(o_mult_div),
		.i_id_exe_mult_div(i_id_exe_mult_div),
		.i_ready(i_ready),
		.o_interrupt_answer(o_interrupt_answer),
		.o_interrupt_source(o_interrupt_source),
		.o_exception(o_exception),
		.o_id_continue(o_id_continue),
		.o_mult_div_cancel(o_mult_div_cancel),
		.o_eret_pc(o_eret_pc),
		.o_excep_pc(o_excep_pc),
		.o_cp0_data(cp0_data)
		);
endmodule
