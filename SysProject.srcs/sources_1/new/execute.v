`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/20 13:52:49
// Design Name: 
// Module Name: execute
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// ִ�в���  
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module execute(
	i_clk,
	i_rstn,
	i_pc_plus4,
	i_imm,
	i_decode_src1, 
	i_decode_src2, 
	i_alu_src_op1,
	i_alu_src_op2,
	i_extend_op, 
	// i_alu_src1, 
	// i_alu_src2,
	i_alu_ctrl, 
	i_pc_store,
	i_mfc0,
	i_mfhi_lo,
	i_mult_div,
	i_mult_div_cancel,
	i_start,
	i_divide,
	i_sign,
	o_alu_res,
	o_overflow,
	o_hi,
	// o_lo,
	o_hi_lo_write,
	o_ready
	);
	
	input	[31:0] i_pc_plus4;				// pc+4
	input	[15:0] i_imm;					// imm
	input	[31:0] i_decode_src1;			// aluԴ������1
	input	[31:0] i_decode_src2;			// aluԴ������2
	// input	[31:0] i_alu_src1;				// aluԴ������1
	// input	[31:0] i_alu_src2;				// aluԴ������2
	input	[5:0 ] i_alu_ctrl;				// alu�����ź�
	
	input	i_pc_store;						// ��תָ���Ƿ�洢pc�ź�
	
	input	i_mfc0;							// mfc0ָ�� [1]ѡ��c0����������Ϊ alu_res
	input	i_mfhi_lo;						// mfhi mfloָ�� [1]ѡ��hi_lo����������Ϊ alu_res

	input	i_clk;
	input	i_rstn;
	input	i_alu_src_op1;
	input	i_alu_src_op2;
	input	i_extend_op;
	input	i_mult_div_cancel;				// �ж�ʱ�˳���ȡ���ź�
	input	i_mult_div;						// �˳��������ź�
	input	i_start;						// �˳������㿪ʼ�ź�
	input	i_divide;						// ���������ź�
	input	i_sign;							// �з��ų˳��������ʶ
	
	output	[31:0] o_alu_res;				// alu������
	
	output	[31:0] o_hi;						// �˳�����������32λ
	// ��32λ��alures �洢 ��ʡ��Դ
	// output	[31:0] o_lo;						// �˳�����������32λ
	
	output	o_overflow;						// �����ʶλ
	output	o_hi_lo_write;					// �˳�������дHI LO�Ĵ����ź�
	output	o_ready;						// �˳�����������ź�
	
	wire	[31:0] alu_res_in;				// alu������
	wire	[31:0] pc_plus8;					// pc+8

	wire	[31:0] alu_src1;
	wire	[31:0] alu_src2;
	wire	[31:0] extended_data;
	
	wire	[31:0] lo;
	wire	[31:0] alu_res;

	wire	busy;							// �˳����������ڹ����ź�
	
	assign	pc_plus8 = i_pc_plus4 + 32'h4;

	// ��������� ���Ҳ��ǿ�ʼ���ж�ȡ���˳���ʱ ����Ч
	assign	o_hi_lo_write = o_ready & busy;
	// ʹ��alu_res�Ĵ����洢�˳�������lo�Ĵ�������
	assign o_alu_res = o_hi_lo_write ? lo : alu_res;

	// ��չ��
	sign_extend EXTENDER ( 
		.i_data(i_imm), 
		.i_ctrl(i_extend_op), 
		.o_data(extended_data)
	);

	// Դ������1��ѡ�� [0]rs [1]shamt
	mux2in1 ALU_SRC_OP1 ( 
		.i_data0(i_decode_src1),
		.i_data1({27'b0, i_imm[10:6]}),
		.i_ctrl(i_alu_src_op1),
		.o_data(alu_src1)
		);

	// Դ������2��ѡ�� [0]rt/c0/hi/lo [1]extended-immediate
	mux2in1 ALU_SRC_OP2 ( 
		.i_data0(i_decode_src2), 
		.i_data1(extended_data), 
		.i_ctrl(i_alu_src_op2), 
		.o_data(alu_src2)
		);

	// �����߼���Ԫ
	alu ALU ( 
		.i_src1(alu_src1), 
		.i_src2(alu_src2), 
		.i_alu_ctrl(i_alu_ctrl), 
		.o_result(alu_res_in), 
		.o_overflow(o_overflow)
		);
	
	// �˳������㵥Ԫ
	mult_div MULT_DIV (
		.i_clk(i_clk),
		.i_rstn(i_rstn),
		.i_cancel(i_mult_div_cancel),
		.i_divide(i_divide),
		.i_sign(i_sign),
		.i_start(i_start),
		.i_data0(i_decode_src1),
		.i_data1(i_decode_src2),
		.o_ready(o_ready),
		.o_busy(busy),
		.o_result({o_hi, lo})
		);

	// ������תָ���Ƿ���Ĵ���д��pc ѡ�����
	// mfhi mflo mfc0 ��Щ����Ҫalu������Ҳͨ��alures����
	// ���ڴ���һ��ָ����ӳ�ת�� ���Ա����pcӦΪ������ָ���ַ ��pc+8
	mux4in1 PC_ALU_OP(
		.i_data0(alu_res_in),
		.i_data1(pc_plus8),
		.i_data2(alu_src2),
		.i_data3(alu_src2),
		.i_ctrl({i_mfc0 | i_mfhi_lo, i_pc_store}),
		.o_data(alu_res)
	);

endmodule
