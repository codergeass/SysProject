`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/30 20:46:56
// Design Name: 
// Module Name: mips_pipeline
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// MIPS流水线cpu顶层文件
// 支持Minisy-1A 57条指令
// 实现协处理器cp0 6个硬件中断源
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mips_pipeline(
	i_clk,
	i_rstn,
	i_interrupt_request,
	i_interrupt_source,
	i_interface_data,
	o_interrupt_answer,
	o_interrupt_source,
	o_interface_read,
	o_interface_write,
	o_interface_addr,
	o_interface_data,
	o_pc,
	o_instr,
	o_alu_res,
	o_mem_data,
	o_reg_data
	);

	input	i_clk;
	input	i_rstn;
	input	i_interrupt_request;

	input	[ 5:0] i_interrupt_source;
	input	[15:0] i_interface_data;

	output	o_interrupt_answer;
	output	o_interface_read;
	output	o_interface_write;
	
	output	[ 5:0] o_interrupt_source;
	output	[ 7:0] o_interface_addr;
	output	[15:0] o_interface_data;

	output	[31:0] o_pc;
	output	[31:0] o_instr;
	output	[31:0] o_alu_res;
	output	[31:0] o_mem_data;
	output	[31:0] o_reg_data;

	// 用于取指部件的内部接线
	wire	pc_write;

	wire	[1:0 ] pc_src;
	wire	[31:0] next_pc;
	wire	[31:0] eret_pc;
	wire	[31:0] excep_pc;
	wire	[31:0] inner_pc;

	wire	[31:0] pc;
	wire	[31:0] pc_plus4;
	wire	[31:0] if_instr;

	// 用于IF-ID间寄存器的接线
	wire	ir_write;
	wire	exception;

	wire	[31:0] if_id_pc;
	wire	[31:0] if_id_pc_plus4;
	wire	[31:0] if_id_instr;
	
	// 用于译码部件的接线
	wire	alu_src_op1;
	wire	alu_src_op2;
	wire	extend_op;
	wire	reg_write;
	wire	mem_read;
	wire	mem_write;
	wire	mem2reg;
	wire	unsign;
	wire	mtc0;
	wire	mfc0;
	wire	eret;
	wire	stall;
	wire	id_continue;
	wire	next_is_dslot;
	wire	mfhi_lo;
	wire	mult_div;
	wire	mult_div_cancel;
	wire	divide;
	wire	sign;

	wire	[ 5:0] alu_ctrl;
	// wire	[31:0] alu_src1;
	// wire	[31:0] alu_src2;
	wire	[31:0] decode_src1;
	wire	[31:0] decode_src2;
	wire	[31:0] hi_lo;
	wire	[ 4:0] reg_dst;
	wire	[ 1:0] data_width;

	// 用于ID-EXE间寄存器的接线
	wire	id_exe_reg_write;
	wire	id_exe_mem_read;
	wire	id_exe_mem_write;
	wire	id_exe_mem2reg;
	wire	id_exe_unsign;
	wire	id_exe_mfc0;
	wire	id_exe_alu_src_op1;
	wire	id_exe_alu_src_op2;
	wire	id_exe_extend_op;
	wire	id_exe_pc_store;
	wire	id_exe_is_dslot;
	wire	id_exe_mfhi_lo;
	wire	id_exe_mult_div;
	wire	start;
	wire	id_exe_divide;
	wire	id_exe_sign;

	wire	[31:0] id_exe_pc;
	wire	[31:0] id_exe_pc_plus4;
	wire	[15:0] id_exe_imm;
	wire	[ 5:0] id_exe_alu_ctrl;
	// wire	[31:0] id_exe_alu_src1;
	// wire	[31:0] id_exe_alu_src2;
	wire	[31:0] id_exe_decode_src1;
	wire	[31:0] id_exe_decode_src2;
	wire	[ 4:0] id_exe_reg_dst;
	wire	[ 1:0] id_exe_data_width;

	// 用于执行部件的接线
	wire	overflow;
	wire	pc_store;
	wire	hi_lo_write;
	wire	ready;

	wire	[31:0] alu_res;
	wire	[31:0] exe_hi;
	// wire	[31:0] exe_lo;

	// 用于EXE-MEM间寄存器的接线
	wire	exe_mem_reg_write;
	wire	exe_mem_mem_read;
	wire	exe_mem_mem_write;
	wire	exe_mem_mem2reg;
	wire	exe_mem_unsign;
	wire	exe_mem_is_dslot;
	wire	exe_mem_hi_lo_write;

	wire	[31:0] exe_mem_pc;
	wire	[31:0] exe_mem_pc_plus4;
	wire	[31:0] exe_mem_alu_res;
	wire	[31:0] exe_mem_src2;
	wire	[31:0] exe_mem_hi;
	// wire	[31:0] exe_mem_lo;
	wire	[ 4:0] exe_mem_reg_dst;
	wire	[ 1:0] exe_mem_data_width;

	// 用于存储器访问部件的接线
	wire	[31:0] mem_data;

	// 用于MEM-WB间寄存器的接线
	wire	mem_wb_reg_write;
	wire	mem_wb_mem2reg;
	wire	mem_wb_hi_lo_write;

	wire	[ 4:0] mem_wb_reg_dst;
	wire	[31:0] mem_wb_reg_data;
	wire	[31:0] mem_wb_hi;
	// wire	[31:0] mem_wb_lo;

	assign	o_pc = pc;
	assign	o_instr = if_id_instr;
	assign	o_alu_res = alu_res;
	assign	o_mem_data = mem_data;
	assign	o_reg_data = mem_wb_reg_data;

	assign o_interface_addr = exe_mem_alu_res[7:0];
	assign o_interface_data = exe_mem_src2[15:0];

	fetch IF(
		.i_clk(i_clk), 
		.i_rstn(i_rstn), 
		.i_pc_src(pc_src),
		.i_pc_write(pc_write), 
		.i_next_pc(next_pc), 
		.i_eret_pc(eret_pc), 
		.i_excep_pc(excep_pc), 
		.o_inner_pc(inner_pc),
		.o_pc(pc), 
		.o_pc_plus4(pc_plus4),
		.o_instr(if_instr) 
		);

	fetch_decode IF_ID(
		.i_clk(i_clk),
		.i_rstn(i_rstn),
		.i_ir_write(ir_write),
		.i_exception(exception),
		.i_pc(pc),
		.i_pc_plus4(pc_plus4),
		.i_instr(if_instr),
		.o_pc(if_id_pc),
		.o_pc_plus4(if_id_pc_plus4),
		.o_instr(if_id_instr)
		);

	decode ID(
		.i_clk(i_clk), 
		.i_rstn(i_rstn),
		.i_reg_write(mem_wb_reg_write),  
		.i_reg_data(mem_wb_reg_data), 
		.i_pc_plus4(if_id_pc_plus4), 
		.i_instr(if_id_instr),				
		.i_alu_res(alu_res), 
		.i_mem_data(mem_data), 
		.i_id_exe_reg_dst(id_exe_reg_dst),
		.i_exe_mem_reg_dst(exe_mem_reg_dst),
		.i_mem_wb_reg_dst(mem_wb_reg_dst),
		.i_id_exe_reg_write(id_exe_reg_write),
		.i_exe_mem_reg_write(exe_mem_reg_write),
		.i_mem_wb_reg_write(mem_wb_reg_write),
		.i_id_exe_mem_read(id_exe_mem_read),	
		.i_id_exe_hi_lo_write(hi_lo_write),	
		.i_exe_mem_hi_lo_write(exe_mem_hi_lo_write),	
		.i_mem_wb_hi_lo_write(mem_wb_hi_lo_write),	
		.i_overflow(overflow),
		.i_interrupt_request(i_interrupt_request),
		.i_interrupt_source(i_interrupt_source),
		.i_if_pc(pc),
		.i_if_id_pc(if_id_pc),
		.i_id_exe_pc(id_exe_pc),
		.i_exe_mem_pc(exe_mem_pc),
		.i_id_exe_is_dslot(id_exe_is_dslot),
		.i_exe_mem_is_dslot(exe_mem_is_dslot),
		.i_exe_hi(exe_hi),
		// .i_exe_lo(exe_lo),
		.i_mem_hi(exe_mem_hi),
		// .i_mem_lo(exe_mem_lo),
		.i_wb_hi(mem_wb_hi),
		// .i_wb_lo(mem_wb_lo),
		.i_id_exe_mult_div(id_exe_mult_div),
		.i_ready(ready),
		.o_alu_ctrl(alu_ctrl), 
		.o_next_pc(next_pc),
		.o_eret_pc(eret_pc),
		.o_excep_pc(excep_pc), 
		.o_pc_src(pc_src),
		// .o_alu_src1(alu_src1), 
		// .o_alu_src2(alu_src2),
		.o_decode_src1(decode_src1),
		.o_decode_src2(decode_src2),
		.o_alu_src_op1(alu_src_op1),
		.o_alu_src_op2(alu_src_op2),
		.o_extend_op(extend_op),
		.o_pc_store(pc_store),
		.o_reg_dst(reg_dst),
		.o_reg_write(reg_write),
		.o_data_width(data_width),
		.o_mem_read(mem_read),
		.o_mem_write(mem_write),
		.o_mem2reg(mem2reg),
		.o_unsign(unsign),
		.o_pc_write(pc_write),
		.o_ir_write(ir_write),
		.o_interrupt_answer(o_interrupt_answer),
		.o_interrupt_source(o_interrupt_source),
		.o_mtc0(mtc0),
		.o_mfc0(mfc0),
		.o_eret(eret),
		.o_next_is_dslot(next_is_dslot),
		.o_exception(exception),
		.o_id_continue(id_continue),
		.o_mult_div_cancel(mult_div_cancel),
		.o_stall(stall),
		.o_mfhi_lo(mfhi_lo),
		.o_mult_div(mult_div),
		.o_divide(divide),
		.o_sign(sign)
		);

	decode_execute ID_EXE(
		.i_clk(i_clk),
		.i_rstn(i_rstn),
		.i_mtc0(mtc0),
		.i_mfc0(mfc0),
		.i_eret(eret),
		.i_pc(if_id_pc),
		.i_pc_plus4(if_id_pc_plus4),
		// .i_src1(alu_src1),
		// .i_src2(alu_src2),
		.i_imm(if_id_instr[15:0]),
		.i_decode_src1(decode_src1),
		.i_decode_src2(decode_src2),
		.i_alu_src_op1(alu_src_op1),
		.i_alu_src_op2(alu_src_op2),
		.i_extend_op(extend_op),
		.i_pc_store(pc_store),
		.i_alu_ctrl(alu_ctrl),
		.i_reg_dst(reg_dst),
		.i_reg_write(reg_write),
		.i_mem_read(mem_read),
		.i_mem_write(mem_write),
		.i_mem2reg(mem2reg),
		.i_unsign(unsign),
		.i_data_width(data_width),
		.i_exception(exception),
		.i_id_continue(id_continue),
		.i_stall(stall),
		.i_next_is_dslot(next_is_dslot),
		.i_mfhi_lo(mfhi_lo),
		.i_mult_div(mult_div),
		.i_divide(divide),
		.i_sign(sign),
		.i_ready(ready),
		.o_mfc0(id_exe_mfc0),
		.o_pc(id_exe_pc),
		.o_pc_plus4(id_exe_pc_plus4),
		// .o_src1(id_exe_alu_src1),
		// .o_src2(id_exe_alu_src2),
		.o_imm(id_exe_imm),
		.o_decode_src1(id_exe_decode_src1),
		.o_decode_src2(id_exe_decode_src2),
		.o_alu_src_op1(id_exe_alu_src_op1),
		.o_alu_src_op2(id_exe_alu_src_op2),
		.o_extend_op(id_exe_extend_op),
		.o_pc_store(id_exe_pc_store),
		.o_alu_ctrl(id_exe_alu_ctrl),
		.o_reg_dst(id_exe_reg_dst),
		.o_reg_write(id_exe_reg_write),
		.o_mem_read(id_exe_mem_read),
		.o_mem_write(id_exe_mem_write),
		.o_mem2reg(id_exe_mem2reg),
		.o_unsign(id_exe_unsign),
		.o_data_width(id_exe_data_width),
		.o_next_is_dslot(id_exe_is_dslot),
		.o_mfhi_lo(id_exe_mfhi_lo),
		.o_mult_div(id_exe_mult_div),
		.o_start(start),
		.o_divide(id_exe_divide),
		.o_sign(id_exe_sign)
		);

	execute EXE(
		.i_clk(i_clk),
		.i_rstn(i_rstn),
		.i_pc_plus4(id_exe_pc_plus4),
		// .i_alu_src1(id_exe_alu_src1), 
		// .i_alu_src2(id_exe_alu_src2),
		.i_imm(id_exe_imm), 
		.i_decode_src1(id_exe_decode_src1), 
		.i_decode_src2(id_exe_decode_src2), 
		.i_alu_src_op1(id_exe_alu_src_op1),
		.i_alu_src_op2(id_exe_alu_src_op2),
		.i_extend_op(id_exe_extend_op),
		.i_alu_ctrl(id_exe_alu_ctrl), 
		.i_pc_store(id_exe_pc_store),
		.i_mfc0(id_exe_mfc0),
		.i_mfhi_lo(id_exe_mfhi_lo),
		.i_mult_div(id_exe_mult_div),
		.i_mult_div_cancel(mult_div_cancel),
		.i_start(start),
		.i_divide(id_exe_divide),
		.i_sign(id_exe_sign),
		.o_alu_res(alu_res),
		.o_overflow(overflow),
		.o_hi(exe_hi),
		// .o_lo(exe_lo),
		.o_hi_lo_write(hi_lo_write),
		.o_ready(ready)
		);

	execute_memory EXE_MEM(
		.i_clk(i_clk),
		.i_rstn(i_rstn),
		.i_overflow(overflow),
		.i_pc(id_exe_pc),
		.i_pc_plus4(id_exe_pc_plus4),
		.i_alu_res(alu_res),
		.i_src2(id_exe_decode_src2),
		.i_reg_dst(id_exe_reg_dst),
		.i_reg_write(id_exe_reg_write),
		.i_mem_read(id_exe_mem_read),
		.i_mem_write(id_exe_mem_write),
		.i_mem2reg(id_exe_mem2reg),
		.i_unsign(id_exe_unsign),
		.i_data_width(id_exe_data_width),
		.i_next_is_dslot(id_exe_is_dslot),
		.i_hi(exe_hi),
		// .i_lo(exe_lo),
		.i_hi_lo_write(hi_lo_write),
		.o_pc(exe_mem_pc),
		.o_pc_plus4(exe_mem_pc_plus4),
		.o_alu_res(exe_mem_alu_res),
		.o_src2(exe_mem_src2),
		.o_reg_dst(exe_mem_reg_dst),
		.o_reg_write(exe_mem_reg_write),
		.o_mem_read(exe_mem_mem_read),
		.o_mem_write(exe_mem_mem_write),
		.o_mem2reg(exe_mem_mem2reg),
		.o_unsign(exe_mem_unsign),
		.o_data_width(exe_mem_data_width),
		.o_next_is_dslot(exe_mem_is_dslot),
		.o_hi(exe_mem_hi),
		// .o_lo(exe_mem_lo),
		.o_hi_lo_write(exe_mem_hi_lo_write),
		.o_interface_read(o_interface_read),
		.o_interface_write(o_interface_write)
		// .o_interface_addr(o_interface_addr),
		// .o_interface_data(o_interface_data)
		);

	memory MEM(
		.i_clk(i_clk), 
		.i_rstn(i_rstn), 
		.i_addr(exe_mem_alu_res), 
		.i_data(exe_mem_src2), 
		.i_mem_write(exe_mem_mem_write), 
		.i_mem2reg(exe_mem_mem2reg),
		.i_unsign(exe_mem_unsign), 
		.i_data_width(exe_mem_data_width),
		.i_interface_read(o_interface_read),
		.i_interface_write(o_interface_write),
		.i_interface_data(i_interface_data),
		.o_mem_data(mem_data)
		);

	memory_writeback MEM_WB(
		.i_clk(i_clk),
		.i_rstn(i_rstn),
		.i_reg_dst(exe_mem_reg_dst),
		.i_reg_data(mem_data),
		.i_reg_write(exe_mem_reg_write),
		.i_mem2reg(exe_mem_mem2reg),
		// .i_interface_read(o_interface_read),
		// .i_data_width(exe_mem_data_width),
		// .i_unsign(exe_mem_unsign),
		// .i_load_addr(exe_mem_alu_res[1:0]),
		.i_hi(exe_mem_hi),
		// .i_lo(exe_mem_lo),
		.i_hi_lo_write(exe_mem_hi_lo_write),
		.o_reg_dst(mem_wb_reg_dst),
		.o_reg_data(mem_wb_reg_data),
		.o_reg_write(mem_wb_reg_write),
		.o_mem2reg(mem_wb_mem2reg),
		.o_hi(mem_wb_hi),
		// .o_lo(mem_wb_lo),
		.o_hi_lo_write(mem_wb_hi_lo_write)
		);

endmodule
