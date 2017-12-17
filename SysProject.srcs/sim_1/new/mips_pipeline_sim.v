`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/19 18:06:13
// Design Name: 
// Module Name: mips_pipeline_sim
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mips_pipeline_sim(
	);
	// input
	reg i_clk = 0;
	reg i_rstn = 0;	
	reg i_interrupt_request = 0;
	reg [5:0] i_interrupt_source = 0;
	
	wire o_interrupt_answer;
	
	wire [31:0] o_pc;
	wire [31:0] o_instr;
	wire [31:0] o_alu_res;
	wire [31:0] o_mem_data;
	wire [31:0] o_reg_data;

	wire [ 5:0] o_interrupt_source;

	mips_pipeline MIPS_PIPE_TEST(
		.i_clk(i_clk),
		.i_rstn(i_rstn),
		.i_interrupt_request(i_interrupt_request),
		.i_interrupt_source(i_interrupt_source),
		.o_interrupt_answer(o_interrupt_answer),
		.o_interrupt_source(o_interrupt_source),
		.o_pc(o_pc),
		.o_instr(o_instr),
		.o_alu_res(o_alu_res),
		.o_mem_data(o_mem_data),
		.o_reg_data(o_reg_data)
		);

	initial begin
		#20 i_rstn = 1;
//		#700 i_interrupt_source = 6'b000011;
//		#20 i_interrupt_request = 1;
//		#50 i_interrupt_request = 0; i_interrupt_source = 6'b000010;
//		#50 i_interrupt_request = 1;
//		#1000 i_interrupt_request = 1;
//		#1020 i_interrupt_request = 0;
	end
	
	always #5 i_clk = ~i_clk;
endmodule
