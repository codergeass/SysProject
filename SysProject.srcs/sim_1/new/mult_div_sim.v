`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/26 11:59:06
// Design Name: 
// Module Name: mult_div_sim
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


module mult_div_sim(
    );
	// input
	reg i_clk = 0;
	reg i_rstn = 0;	
	reg i_divide = 0;	
	reg i_sign = 0;	
	reg i_cancel = 0;
	wire i_start;	

	reg [31:0] i_data0 = 1000;
	reg [31:0] i_data1 = 9;

	wire o_ready;
	wire [63:0] o_result;

	assign i_start = o_ready;
	
	mult_div MULT_DIV_TEST(
		.i_clk(i_clk),
		.i_rstn(i_rstn),
		.i_cancel(i_cancel),
		.i_divide(i_divide),
		.i_sign(i_sign),
		.i_start(i_start),
		.i_data0(i_data0),
		.i_data1(i_data1),
		.o_ready(o_ready),
		.o_result(o_result)
		);
	
	initial begin
		#20 i_rstn = 1; i_divide = 1;
		#1000 i_sign = 1;
	end

	always #5 i_clk = ~i_clk;
	always #400 i_data0 = ($random) % (2**23);
	always #400 i_data1 = ($random) % (2**23);
	
endmodule
