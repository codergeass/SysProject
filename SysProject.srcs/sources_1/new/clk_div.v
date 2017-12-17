`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/30 10:08:11
// Design Name: 
// Module Name: clk_div
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//  ±÷”»Ìº˛∑÷∆µ
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clk_div(
	i_clk,
	i_rstn,
	o_clk
	);
	parameter COUNT = 2;

	input	i_clk;
	input	i_rstn;

	output	reg o_clk;
	
	reg		[32:0] count;

	always @(posedge i_clk or negedge i_rstn) begin
		if (~i_rstn) begin
			// reset
			o_clk	<= 0;
			count	<= 0;
		end
		else if (count >= COUNT) begin
			o_clk	<= ~o_clk;
			count	<= 0;		
		end
		else begin
			count	<= count + 1;
		end
	end
endmodule
