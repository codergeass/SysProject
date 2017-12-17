`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/22 11:53:32
// Design Name: 
// Module Name: dffe32
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 16Î»D´¥·¢Æ÷
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module dffe16(
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
	
	output	reg [15:0] o_data;

	always @(posedge i_clk or negedge i_rstn) begin
		if (~i_rstn) begin
			// reset
			o_data <= 0;
		end else begin
			if(i_we) o_data <= i_data;	
		end
	end
	
endmodule
