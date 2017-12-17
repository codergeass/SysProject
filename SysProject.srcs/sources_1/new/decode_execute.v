`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/01 21:00:19
// Design Name: 
// Module Name: decode_execute
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 译码-执行部件间的寄存器 产生执行周期 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module decode_execute(
	i_clk,
	i_rstn,
	i_mtc0,
	i_mfc0,
	i_eret,
	i_pc,
	i_pc_plus4,
	// i_src1,
	// i_src2,
	i_imm,
	i_decode_src1,
	i_decode_src2,
	i_alu_src_op1,
	i_alu_src_op2,
	i_extend_op,
	i_pc_store,
	i_alu_ctrl,
	i_reg_dst,
	i_reg_write,
	i_mem_read,
	i_mem_write,
	i_mem2reg,
	i_unsign,
	i_data_width,
	i_exception,
	i_id_continue,
	i_stall,
	i_next_is_dslot,
	i_mfhi_lo,
	i_mult_div,
	i_divide,
	i_sign,
	i_ready,
	o_mfc0,
	o_pc,
	o_pc_plus4,
	// o_src1,
	// o_src2,
	o_imm,
	o_decode_src1,
	o_decode_src2,
	o_alu_src_op1,
	o_alu_src_op2,
	o_extend_op,
	o_pc_store,
	o_alu_ctrl,
	o_reg_dst,
	o_reg_write,
	o_mem_read,
	o_mem_write,
	o_mem2reg,
	o_unsign,
	o_data_width,
	o_next_is_dslot,
	o_mfhi_lo,
	o_mult_div,
	o_start,
	o_divide,
	o_sign
	);

	input	i_clk;
	input	i_rstn;
	input	i_mtc0;					// mtc0指令只需要IF ID两个周期 作为清除EXE阶段的信号
	input	i_mfc0;					// mfc0指令用于EXE段选择c0读出数据作为输出
	input	i_eret;					// eret指令只需要IF ID两个周期 作为清除EXE阶段的信号

	input	[31:0] i_pc;
	input	[31:0] i_pc_plus4;
	// input	[31:0] i_src1;
	// input	[31:0] i_src2;
	input	[15:0] i_imm;
	input	[31:0] i_decode_src1;
	input	[31:0] i_decode_src2;

	input	i_alu_src_op1;
	input	i_alu_src_op2;
	input	i_extend_op;

	input	i_pc_store;
	
	input	[5:0] i_alu_ctrl;
	input	[4:0] i_reg_dst;
	input	[1:0] i_data_width;

	input	i_reg_write;
	input	i_mem_read;
	input	i_mem_write;
	input	i_mem2reg;
	input	i_unsign;
	input	i_exception;
	input	i_id_continue;
	input	i_stall;
	input	i_next_is_dslot;
	input	i_mfhi_lo;
	input	i_mult_div;
	input	i_divide;
	input	i_sign;
	input	i_ready;
	
	output	reg [31:0] o_pc;
	output	reg [31:0] o_pc_plus4;
	// output	reg [31:0] o_src1;
	// output	reg [31:0] o_src2;
	output	reg [15:0] o_imm;
	output	reg [31:0] o_decode_src1;
	output	reg [31:0] o_decode_src2;
	
	output	reg o_alu_src_op1;
	output	reg o_alu_src_op2;
	output	reg o_extend_op;

	output	reg o_pc_store;
	
	output	reg [5:0] o_alu_ctrl;
	output	reg [4:0] o_reg_dst;
	output	reg [1:0] o_data_width;

	output	reg o_reg_write;
	output	reg o_mem_read;
	output	reg o_mem_write;
	output	reg o_mem2reg;
	output	reg o_unsign;
	output	reg o_mfc0;
	output	reg o_next_is_dslot;
	output	reg o_mfhi_lo;
	output	reg o_mult_div;
	output	reg o_start;
	output	reg o_divide;
	output	reg o_sign;

	wire	exe_cancel;
	assign	exe_cancel = i_mtc0 | i_eret | i_exception & ~i_id_continue | i_stall;
	
	always @(posedge i_clk or negedge i_rstn) begin
		if (~i_rstn) begin
			// mtc0 eret指令只需要IF ID阶段所以报废剩余执行周期
			// 中断异常时、流水线暂停时报废剩余周期
			// 只有关机时才将pc清零 避免中断或异常时pc缺失
			// o_pc		<= ~i_rstn ? 0 : o_pc;
			// o_pc_plus4	<= ~i_rstn ? 0 : o_pc_plus4;
			
			o_pc		<= 0;
			o_pc_plus4	<= 0;
			
			// o_src1		<= 0;
			// o_src2		<= 0;
			o_imm			<= 0;
			o_decode_src1	<= 0;
			o_decode_src2	<= 0;

			o_alu_src_op1	<= 0;
			o_alu_src_op2	<= 0;
			o_extend_op		<= 0;

			o_pc_store	<= 0;
			o_alu_ctrl	<= 0;
			o_reg_dst	<= 0;
			o_data_width <= 0;

			o_reg_write	<= 0;
			o_mem_read	<= 0;
			o_mem_write <= 0;
			o_mem2reg	<= 0;
			o_unsign	<= 0;
			
			o_mfc0		<= 0;
			
			o_start		<= 0;
			o_mfhi_lo	<= 0;
			o_mult_div	<= 0;
			o_divide	<= 0;
			o_sign		<= 0;

			o_next_is_dslot	<= 0;
			// o_next_is_dslot <= ~i_rstn ? 0 : i_next_is_dslot;
		end
		else begin
			o_pc		<= i_pc;
			o_pc_plus4	<= i_pc_plus4;
			
			// o_src1		<= exe_cancel ? 0 : i_src1;
			// o_src2		<= exe_cancel ? 0 : i_src2;
			o_imm			<= i_imm;	
			o_decode_src1	<= i_decode_src1;
			o_decode_src2	<= i_decode_src2;

			o_alu_src_op1	<= i_alu_src_op1;
			o_alu_src_op2	<= i_alu_src_op2;
			o_extend_op		<= i_extend_op;

			o_pc_store	<= ~exe_cancel & i_pc_store;
			o_alu_ctrl	<= {6{~exe_cancel}} & i_alu_ctrl;
			o_reg_dst	<= i_reg_dst;
			o_data_width <= i_data_width;

			o_reg_write	<= ~exe_cancel & i_reg_write;
			o_mem_read	<= ~exe_cancel & i_mem_read;
			o_mem_write <= ~exe_cancel & i_mem_write;
			o_mem2reg	<= ~exe_cancel & i_mem2reg;
			o_unsign	<= i_unsign;
			
			o_mfc0		<= ~exe_cancel & i_mfc0;
			o_mfhi_lo	<= ~exe_cancel & i_mfhi_lo;
			o_mult_div	<= ~exe_cancel & i_mult_div;
			o_start		<= ~exe_cancel & i_mult_div;		// 使用乘除法信号产生开始运算符号
			o_divide	<= ~exe_cancel & i_divide;
			o_sign		<= i_sign;

			o_next_is_dslot	<= i_next_is_dslot;
		end
	end
endmodule
