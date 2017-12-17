`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/15 17:43:20
// Design Name: 
// Module Name: nextPC
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// ������תָ��õ��µ�pcֵ�Լ�pc��Դѡ��pc_src
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module nextPC(
	i_pc_plus4, 
	i_addr, 
	i_j,
	i_jal, 
	i_beq, 
	i_bne,
	i_bgez,
	i_bgtz,
	i_blez,
	i_bltz,
	i_bgezal,
	i_bltzal, 
	i_jr,
	i_jalr,
	i_src1, 
	i_src2,
	i_exception,
	i_eret,  
	o_next_pc, 
	o_pc_src,
	o_pc_store
	);

	input	[31:0]	i_pc_plus4;
	input	[25:0]	i_addr;

	input	i_j;
	input	i_jal; 
	input	i_beq; 
	input	i_bne;
	input	i_bgez;
	input	i_bgtz;
	input	i_blez;
	input	i_bltz;
	input	i_bgezal;
	input	i_bltzal; 
	input	i_jr;
	input	i_jalr;

	input	[31:0]	i_src1;
	input	[31:0]	i_src2;

	input	i_exception;
	input	i_eret;

	output	[31:0]	o_next_pc;
	output	reg [ 1:0]	o_pc_src;
	output	o_pc_store;					// ��תָ���Ƿ�洢pc

	wire	[31:0]	branch_pc;			// ת��ָ��õ���ƫת��ַ
	wire	[31:0]	jump_pc;			// ��תָ��õ�����ת��ַ
	wire	[31:0]	extended_data;		// ��չ�����
	
	wire	zero_flag;					// ���ʶλ
	wire	greater_zero_flag;			// �������ʶλ
	wire	less_zero_flag;				// С�����ʶλ
	wire	equal_zero_flag;			// �������ʶλ

	wire	is_jump;					// ����תָ��
	wire	is_branch;					// ��ת��ָ��ҳ���

	
	assign zero_flag = (i_src1 == i_src2);
	assign greater_zero_flag = ~i_src1[31];
	assign less_zero_flag = i_src1[31];
	assign equal_zero_flag = !i_src1;

	assign branch_pc = i_pc_plus4[31:0] + {extended_data[29:0], 2'b0};
	assign jump_pc = (i_jr | i_jalr) ? i_src1 : {i_pc_plus4[31:28], i_addr[25:0], 2'b0};

	assign is_jump = i_j | i_jal | i_jr | i_jalr;
	assign is_branch = ((zero_flag&i_beq) | (~zero_flag&i_bne)) |
		((i_bgez | i_bgezal) & (greater_zero_flag | equal_zero_flag)) |
		(i_bgtz & greater_zero_flag & ~equal_zero_flag) |
		((i_blez) & (less_zero_flag | equal_zero_flag)) |
		((i_bltz | i_bltzal) & less_zero_flag & ~equal_zero_flag);

	assign o_pc_store = i_jal | i_jalr | 
		(i_bgezal & (greater_zero_flag | equal_zero_flag)) |
		(i_bltzal & less_zero_flag & ~equal_zero_flag);

	always @(*) begin 
		case(1'b1)
			i_eret:			o_pc_src = 2'b10;	// ���жϻ��쳣����
			i_exception:	o_pc_src = 2'b11;	// �жϻ��쳣
			is_jump,
			is_branch:		o_pc_src = 2'b01;	// ��ת����ת��ָ��
			default:		o_pc_src = 2'b00;
		endcase
	end

	// offset��չ
	sign_extend EXT ( 
		.i_data(i_addr[15:0]), 
		.i_ctrl(1'b1), 
		.o_data(extended_data)
	); 
	
	// ��ת ת�Ƶ�ַѡ��
	mux2in1 B_J_PC_MUX ( 
		.i_data0(branch_pc), 
		.i_data1(jump_pc), 
		.i_ctrl(is_jump), 
		.o_data(o_next_pc)
	);

endmodule
