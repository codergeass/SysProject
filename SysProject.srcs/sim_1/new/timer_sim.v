`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/30 16:55:11
// Design Name: 
// Module Name: timer_sim
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


module timer_sim(
    );
	reg i_clk = 0;
	reg i_rstn = 0;
	reg i_we = 0;				// 写使能
	reg i_re = 0;				// 读使能
		
	reg [ 2:0] i_op = 0;
	reg [15:0] i_data = 0;
	
	wire [15:0] o_data;

	wire o_out0;				// 定时输出
	wire o_out1;				// 定时输出

	timer TIMER_TEST(
		.i_clk(i_clk),
		.i_rstn(i_rstn),
		.i_we(i_we),
		.i_re(i_re),
		.i_op(i_op),
		.i_data(i_data),
		.o_data(o_data),
		.o_out0(o_out0),
		.o_out1(o_out1)
		);

	initial begin
		#20 i_rstn = 1;
		#30 i_op = 3'b000;
			i_data = 16'h2;
		#20 i_we = 1;
		#10 i_we = 0; i_op = 3'b100; i_data = 32'h5;
		#10 i_we = 1;
		#10 i_we = 0; i_op = 3'b110;
		#90 i_op = 3'b010;
		#10 i_re = 1;
		#10 i_re = 0;
		#10 i_op = 3'b000;
			i_data = 16'h3;
		#20 i_we = 1;
		#10 i_we = 0; i_op = 3'b100; i_data = 32'h5;
		#10 i_we = 1;
		#10 i_we = 0; i_op = 3'b110;
		#90 i_op = 3'b010;
		#10 i_re = 1;
		#10 i_re = 0;
	end
	
	always #5 i_clk = ~i_clk;
endmodule
