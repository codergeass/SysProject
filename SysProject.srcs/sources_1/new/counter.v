`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/30 11:58:03
// Design Name: 
// Module Name: counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 计数器 WIDTH 控制计数大小
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module counter(
	i_clk,
	i_rstn,
	o_count
	);
	
	parameter WIDTH = 8;
	
	input	i_clk;
	input	i_rstn;
	output	reg [(WIDTH-1):0] o_count;

	always @(posedge i_clk, negedge i_rstn)
	if (~i_rstn) 	o_count <= 0;
	else			o_count <= o_count + 1;

endmodule
