`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/20 13:27:59
// Design Name: 
// Module Name: reg_file
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// �Ĵ����ļ�
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module reg_file(
	i_clk,
	i_rstn, 
	i_raddr1, 
	i_raddr2, 
	i_waddr, 
	i_wdata, 
	i_we,
	o_rdata1,
	o_rdata2 
	);

	input	i_clk, i_we;								// ʱ�ӡ�дʹ��
	input	i_rstn;										// ��λ�ź�
	input	[ 4:0]	i_raddr1, i_raddr2, i_waddr;		// ��ַ
	input	[31:0]	i_wdata;							// д����
	output	[31:0]	o_rdata1, o_rdata2;					// ������

	reg [31:0] registers [0:31];

	assign o_rdata1 = registers[i_raddr1];
	assign o_rdata2 = registers[i_raddr2]; 

	always @ (posedge i_clk or negedge i_rstn) begin
		if (~i_rstn) begin : regs_ini
			integer i;
			for(i = 0;i < 32;i = i+1)
				registers[i] <= i;		// ��λʱ��ʼ��ÿһ���Ĵ���Ϊi
		end
		else begin
			if(i_we) 
				registers[i_waddr] <= i_wdata;  
			registers[0] <= 32'b0;		// $0: zero
		end
	end

endmodule
