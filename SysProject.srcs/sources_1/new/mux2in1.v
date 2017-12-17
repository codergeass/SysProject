`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/20 14:01:57
// Design Name: 
// Module Name: mux2in1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 32λ��ѡһѡ����
// ��ʹ�ñ���WiDTH�Զ������ݿ��
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mux2in1(
	i_data0,
	i_data1,
	i_ctrl,
	o_data
	);

	parameter WIDTH = 32;

	input	[WIDTH-1:0]	i_data0, i_data1; 
	input	i_ctrl;
	output	[WIDTH-1:0]	o_data; 

	assign	o_data = i_ctrl ? i_data1 : i_data0;

endmodule
