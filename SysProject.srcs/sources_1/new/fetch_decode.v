`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/01 21:00:43
// Design Name: 
// Module Name: fetch_decode
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// ȡָ-���벿����ļĴ��� ������������
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fetch_decode(
	i_clk,
	i_rstn,
	i_ir_write,
	i_exception,
	i_pc,
	i_pc_plus4,
	i_instr,
	o_pc,
	o_pc_plus4,
	o_instr
	);

	input	i_clk;
	input	i_rstn;
	input	i_ir_write;
	input	i_exception;
	
	input	[31:0] i_pc;			
	input	[31:0] i_pc_plus4;		// pc+4
	input	[31:0] i_instr;			// ָ��
	
	output	reg [31:0] o_pc;	
	output	reg [31:0] o_pc_plus4;
	
	output	reg [31:0] o_instr;		// �������ָ�� ����ID

	// wire 	[31:0] instr;			// �����жϵ�һ��ָ��
	reg		is_first;

	// // ��һ��ʱ������ ����ID��ָ��
	// assign	o_instr = is_first ? 0 : instr;

	// dffe32 IF_ID_PC(
	// 	.i_clk(i_clk),
	// 	.i_rstn(i_rstn),
	// 	.i_we(i_ir_write),
	// 	.i_data(i_pc),
	// 	.o_data(o_pc)
	// 	);

	// dffe32 IF_ID_IR(
	// 	.i_clk(i_clk),
	// 	.i_rstn(i_rstn & ~i_exception),
	// 	.i_we(i_ir_write),
	// 	.i_data(i_instr),
	// 	.o_data(instr)
	// 	);

	// dffe32 IF_ID_PC_PLUS4(
	// 	.i_clk(i_clk),
	// 	.i_rstn(i_rstn),
	// 	.i_we(i_ir_write),
	// 	.i_data(i_pc_plus4),
	// 	.o_data(o_pc_plus4)
	// 	);

	// ��֤��һ��ʱ�����ڽ������벿����ָ��Ϊ��
	always @(posedge i_clk or negedge i_rstn) begin
		if (~i_rstn) begin
			// reset
			is_first <= 1'b1;
		end
		else begin
			is_first <= 1'b0;
		end
	end

	// ���ǵ��쳣�ж�ʱ ����ȡ��ָ��������ϴ���
	always @(posedge i_clk or negedge i_rstn) begin
		if (~i_rstn) begin
			// ��λ���������ж��쳣 ��ˮ����ȡ��ָ������
			o_instr		<= 0;
			o_pc		<= 0;
			o_pc_plus4	<= 0;
		end
		else begin
			o_instr		<= i_exception | is_first ? 0 : (i_ir_write ? i_instr : o_instr);
			// o_instr		<= i_exception ? 0 : (i_ir_write & ~is_first ? i_instr : o_instr);
			o_pc		<= i_ir_write ? i_pc : o_pc;
			o_pc_plus4	<= i_ir_write ? i_pc_plus4 : o_pc_plus4;
		end
	end

endmodule
