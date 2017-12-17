`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/20 14:10:24
// Design Name: 
// Module Name: sign_extend
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 16位数扩展为32位
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sign_extend(
	i_data,
	i_ctrl,
	o_data
	);
	
	input	[15:0]  i_data;
	input	i_ctrl;
	output	[31:0]  o_data;

	assign	o_data = (i_ctrl == 1'b1) 
					? ({ {16{i_data[15]}}, i_data[15:0] }) 
					: ({ {16{i_ctrl}}, i_data[15:0] });

endmodule
