`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Compano_data: 
// Engineer: 
// 
// Create Date: 2016/12/30 11:58:20
// Design Name: 
// Module Name: mux8in1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// °ËÑ¡Ò»Ñ¡ÔñÆ÷ 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module mux8in1(
	i_data0,
	i_data1,
	i_data2,
	i_data3,
	i_data4,
	i_data5,
	i_data6,
	i_data7,
	i_ctrl,
	o_data
	);
	
	parameter WIDTH = 32;
	
	input	[WIDTH-1:0]	i_data0, i_data1, i_data2, i_data3, 
						i_data4, i_data5, i_data6, i_data7;
	input	[2:0]		i_ctrl;
	
	output	reg [WIDTH-1:0] o_data;


	always @(*)
		case (i_ctrl)
			3'b000:		o_data = i_data0;
			3'b001:		o_data = i_data1;
			3'b010:		o_data = i_data2;
			3'b011:		o_data = i_data3;
			3'b100:		o_data = i_data4;
			3'b101:		o_data = i_data5;
			3'b110:		o_data = i_data6;
			3'b111:		o_data = i_data7;
			default:	o_data = i_data0;
		endcase

endmodule
