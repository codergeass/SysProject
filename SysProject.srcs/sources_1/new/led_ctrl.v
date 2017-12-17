`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/30 10:37:53
// Design Name: 
// Module Name: led_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// LEDµÆ¿ØÖÆÆ÷
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module led_ctrl(
	i_clk,
	i_rstn,
	i_we,
	i_data,
	o_data
	);
	
	input	i_clk;
	input	i_rstn;
	input	i_we;
	
	input	[15:0] i_data;
	output	[15:0] o_data;

	dffe16	LED_REG(
		.i_clk(~i_clk),
		.i_rstn(i_rstn),
		.i_we(i_we),
		.i_data(i_data),
		.o_data(o_data)
		);
endmodule
