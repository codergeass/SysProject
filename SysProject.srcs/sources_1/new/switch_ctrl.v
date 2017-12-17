`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/30 10:37:53
// Design Name: 
// Module Name: switch_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 拨码开关控制器
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module switch_ctrl(
	i_clk,
	i_re,
	i_data,
	o_data
	);

	input	i_clk;
	input	i_re;				// 读使能
	
	input	[15:0] i_data;		// 接拨码开关

	output	[15:0] o_data;

	wire	[15:0] switch_data;	// 拨码开关键值寄存器

	assign	o_data = i_re ? switch_data : 16'b0;
	
	// 拨码开关键值寄存器
	dffe16	SWITCH_REG(
		.i_clk(~i_clk),
		.i_rstn(1'b1),
		.i_we(1'b1),
		.i_data(i_data),
		.o_data(switch_data)
		);

endmodule
