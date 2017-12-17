`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/30 10:37:53
// Design Name: 
// Module Name: watchdog
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// ���Ź�
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module watchdog(
	i_clk,
	i_rstn,
	i_we,
	i_data,
	o_reset
	);

	input	i_clk;
	input	i_rstn;
	input	i_we;				// дʹ��
	
	input	[15:0] i_data;

	output	reg o_reset;			// ���Ź������λ�ź�

	reg		[15:0] count;		// ��ʱ��
	reg		[ 2:0] count_reset;	// ��λ�ź�ʱ�����ڸ��� ��ʱ��
	
	always @(posedge ~i_clk or negedge i_rstn) begin
		if (~i_rstn) begin
			// reset
			count		<= 16'hffff;
			count_reset	<= 4;
			o_reset		<= 1;
		end
		else if (i_we) begin
				count	<= i_data;			// ��ʼֱֵ����������Ĵ���
		end 
		else begin
			if (!count) begin
				if (!count_reset) begin
					o_reset		<= 1'b1;		// ���Ź���������ź�
					count_reset	<= 4;		// ��λ�������ָ�
					count		<= 16'hffff;
				end
				else begin
					o_reset		<= 1'b0;		// ���Ź���������ź�
					count_reset	<= count_reset - 1;
				end
			end
			else begin
				count	<= count - 1;		// ���� ����ֵ��1
			end
		end
	end

endmodule
