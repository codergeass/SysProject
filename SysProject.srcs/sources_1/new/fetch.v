`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/15 17:00:31
// Design Name: 
// Module Name: fetch
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// ȡָ����
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fetch( 
	i_clk, 
	i_rstn, 
	i_pc_src,
	i_pc_write, 
	i_next_pc, 
	i_eret_pc, 
	i_excep_pc, 
	o_inner_pc,
	o_pc, 
	o_pc_plus4,
	o_instr 
	);

	input	i_clk;					// ʱ��
	input	i_rstn;					// ����
	input	[1:0] i_pc_src;			// pc��Դ
	input	i_pc_write;				// pcдʹ��
	
	input	[31:0] i_next_pc;		// �����벿���õ���pc��ֵ
	input	[31:0] i_eret_pc;		// �ж��쳣����ʹ���쳣�����������pcֵ
	input	[31:0] i_excep_pc;		// �жϴ��������ڵ�ַ
	
	output	[31:0] o_pc;				// PC�Ĵ������pcֵ
	output	[31:0] o_pc_plus4;		// pc+4
	output	[31:0] o_instr;			// ȡ����ָ��
	
	output	reg	[31:0] o_inner_pc;	// �ڲ�pc ����pc+4
	
	assign	o_pc_plus4 = o_pc + 32'h4;

	reg		is_first;
	// reg		is_first2;				// ���ڵ�һ��ʱ������ pc��Ȼ����Ϊ��
	wire	clkn;
	assign	clkn = ~i_clk;
	
	// ָ��洢��
	prg_rom ROM(
		.clka(clkn),					// ��ָ�����������
		.addra(o_pc[15:2]),
		.douta(o_instr)
		);
	
	// PC�Ĵ���
	dffe32 PC(					
		.i_clk(i_clk),				
		.i_rstn(i_rstn),
		.i_we(i_pc_write),
		.i_data(o_inner_pc),
		.o_data(o_pc)
		);
	
	// // pc��ֵѡ�� ע���п��ܵ�һ��ʱ�����ھʹ�32'h4��ַ��ʼ����
	// mux4in1 NPC_MUX(
	// 	.i_data0(pc_plus4),
	// 	.i_data1(i_next_pc),
	// 	.i_data2(i_eret_pc),
	// 	.i_data3(i_excep_pc),
	// 	.i_ctrl(i_pc_src),
	// 	.o_data(o_inner_pc)
	// 	);

	// ��֤��һ��ʱ�����ڽ������벿����ָ��Ϊ��
	always @(posedge i_clk or negedge i_rstn) begin
		if (~i_rstn) begin
			// reset
			is_first	<= 1'b1;
		end
		else begin
			is_first	<= 1'b0;
		end
	end

	always @(*) begin
//		if(~i_rstn) begin
			o_inner_pc	= 32'b0;
//		end
//		else begin
			if (i_pc_write) begin
				case(i_pc_src)										// ����pc��Դ����pcֵ
					2'b01:		o_inner_pc = i_next_pc;				// ��ת		
					2'b10:		o_inner_pc = i_eret_pc;				// �жϷ���
					2'b11:		o_inner_pc = i_excep_pc;				// �жϴ���
					default:	o_inner_pc = is_first ? o_pc : o_pc_plus4;
				endcase
			end
//		end
	end
endmodule
