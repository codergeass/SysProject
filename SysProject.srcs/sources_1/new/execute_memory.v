`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/01 21:01:05
// Design Name: 
// Module Name: execute_memory
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 执行-存储器访问间的寄存器 产生寄存器访问周期 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module execute_memory(
	i_clk,
	i_rstn,
	i_overflow,
	i_pc,
	i_pc_plus4,
	i_alu_res,
	i_src2,
	i_reg_dst,
	i_reg_write,
	i_mem_read,
	i_mem_write,
	i_mem2reg,
	i_unsign,
	i_data_width,
	i_next_is_dslot,
	i_hi,
	// i_lo,
	i_hi_lo_write,
	o_pc,
	o_pc_plus4,
	o_alu_res,
	o_src2,
	o_reg_dst,
	o_reg_write,
	o_mem_read,
	o_mem_write,
	o_mem2reg,
	o_unsign,
	o_data_width,
	o_next_is_dslot,
	o_hi,
	// o_lo,
	o_hi_lo_write,
	o_interface_read,
	o_interface_write
	// o_interface_addr,
	// o_interface_data
	);

	input	i_clk;
	input	i_rstn;
	input	i_overflow;
	
	input	[31:0] i_pc;
	input	[31:0] i_pc_plus4;
	input	[31:0] i_alu_res;
	input	[31:0] i_src2;
	input	[31:0] i_hi;
	// input	[31:0] i_lo;
	input	[4:0 ] i_reg_dst;
	input	[1:0 ] i_data_width;

	input	i_reg_write;
	input	i_mem_read;
	input	i_mem_write;
	input	i_mem2reg;
	input	i_unsign;
	input	i_next_is_dslot;
	input	i_hi_lo_write;
	
	output	reg [31:0] o_pc;
	output	reg [31:0] o_pc_plus4;
	output	reg [31:0] o_alu_res;
	output	reg [31:0] o_src2;
	output	reg [31:0] o_hi;
	// output	reg [31:0] o_lo;
	output	reg [4:0 ] o_reg_dst;
	output	reg [1:0 ] o_data_width;

	output	reg o_reg_write;
	output	reg o_mem_read;
	output	reg o_mem_write;
	output	reg o_mem2reg;
	output	reg o_unsign;
	output	reg o_next_is_dslot;
	output	reg o_hi_lo_write;

	output	reg o_interface_read;
	output	reg o_interface_write;
	// output	reg [ 7:0] o_interface_addr;
	// output	reg [15:0] o_interface_data;

	wire	is_interface;		// 访问接口部件信号
	assign	is_interface = (&i_alu_res[31:10]);

	always @(posedge i_clk or negedge i_rstn) begin
		if (~i_rstn) begin
			// 如果溢出 则取消当前指令的剩余执行过程
			o_pc		<= 0;
			o_pc_plus4	<= 0;
			o_alu_res	<= 0;
			o_src2		<= 0;
			o_reg_dst	<= 0;
			o_data_width <=0;
			
			o_reg_write	<= 0;
			o_mem_read	<= 0;
			o_mem_write <= 0;
			o_mem2reg	<= 0;
			o_unsign	<= 0;

			o_hi		<= 0;
			// o_lo		<= 0;
			o_hi_lo_write	<= 0;
			
			o_next_is_dslot <= 0;

			o_interface_read	<= 0;
			o_interface_write	<= 0;
			// o_interface_addr	<= 0;
			// o_interface_data	<= 0;
		end
		else begin
			o_pc		<= i_pc;
			o_pc_plus4	<= i_pc_plus4;
			o_alu_res	<= i_alu_res;
			o_src2		<= i_src2;
			o_reg_dst	<= i_reg_dst;
			o_data_width <= i_data_width;
			
			o_reg_write	<= ~i_overflow & i_reg_write;
			o_mem_read	<= ~i_overflow & i_mem_read;
			o_mem_write <= ~i_overflow & i_mem_write;
			o_mem2reg	<= ~i_overflow & i_mem2reg;
			o_unsign	<=  i_unsign;

			o_hi		<= i_hi;
			// o_lo		<= i_lo;
			o_hi_lo_write	<= i_hi_lo_write;

			o_next_is_dslot <= i_next_is_dslot;
			
			o_interface_read	<= ~i_overflow & is_interface & i_mem_read;
			o_interface_write	<= ~i_overflow & is_interface & i_mem_write;
			// o_interface_addr	<=  i_alu_res[7:0];
			// o_interface_data	<=  i_src2[15:0];
		end
	end
endmodule
