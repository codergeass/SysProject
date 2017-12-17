`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/20 14:22:54
// Design Name: 
// Module Name: mux4in1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 四选一选择器 默认数据宽度32位
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mux4in1(
	i_data0, 
	i_data1, 
	i_data2, 
	i_data3, 
	i_ctrl, 
	o_data
	);
	
	parameter WIDTH = 32;

	input	wire [WIDTH-1:0] i_data0, i_data1, i_data2, i_data3;
	input	wire [ 1:0] i_ctrl;

	output	reg [WIDTH-1:0] o_data;

	always @(*) begin
		case (i_ctrl)
			2'b00: o_data = i_data0;
			2'b01: o_data = i_data1;
			2'b10: o_data = i_data2;
			2'b11: o_data = i_data3;
		endcase
	end

endmodule
