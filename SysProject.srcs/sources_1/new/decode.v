`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/20 13:49:20
// Design Name: 
// Module Name: decode
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// ���뵥Ԫ
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module decode(
	i_clk, 
	i_rstn,
	i_reg_write,  
	i_reg_data, 
	i_pc_plus4, 
	i_instr,
	i_alu_res, 
	i_mem_data,
	i_id_exe_reg_dst,
	i_exe_mem_reg_dst,
	i_mem_wb_reg_dst,
	i_id_exe_reg_write,
	i_exe_mem_reg_write,
	i_mem_wb_reg_write,
	i_id_exe_mem_read,
	i_overflow,
	i_interrupt_request,
	i_interrupt_source,
	i_if_pc,
	i_if_id_pc,
	i_id_exe_pc,
	i_exe_mem_pc,
	i_id_exe_is_dslot,
	i_exe_mem_is_dslot,
	i_wb_hi,
	// i_wb_lo,
	i_exe_hi,
	// i_exe_lo,
	i_mem_hi,
	// i_mem_lo,
	i_id_exe_hi_lo_write,
	i_exe_mem_hi_lo_write,
	i_mem_wb_hi_lo_write,
	i_id_exe_mult_div,
	i_ready,
	o_alu_ctrl, 
	o_pc_store,
	o_next_pc, 
	o_eret_pc,
	o_excep_pc,
	o_pc_src,
	// o_alu_src1, 
	// o_alu_src2,
	o_decode_src1,
	o_decode_src2,
	o_alu_src_op1,
	o_alu_src_op2,
	o_extend_op,
	o_reg_dst,
	o_reg_write,
	o_data_width,
	o_mem_read,
	o_mem_write,
	o_mem2reg,
	o_unsign,
	o_pc_write,
	o_ir_write,
	o_interrupt_answer,
	o_interrupt_source,
	o_mtc0,
	o_mfc0,
	o_eret,
	o_next_is_dslot,
	o_exception,
	o_id_continue,
	o_mult_div_cancel,
	o_stall,
	o_mfhi_lo,
	o_mult_div,
	o_divide,
	o_sign
	);

	input	i_clk;
	input	i_rstn;
	input	i_reg_write; 

	input	[31:0] i_reg_data; 

	input	[31:0] i_pc_plus4;
	input	[31:0] i_instr;

	input	[31:0] i_alu_res;				// alu���
	input	[31:0] i_mem_data;				// �洢����

	input	[ 4:0] i_id_exe_reg_dst;			// id-exe�Ĵ��������Ŀ�Ĳ������Ĵ�����ַ ��������ָ��exe�׶�
	input	[ 4:0] i_exe_mem_reg_dst;		// exe-mem�Ĵ��������Ŀ�Ĳ������Ĵ�����ַ ����������ָ��mem�׶�
	input	[ 4:0] i_mem_wb_reg_dst;			// mem-wb�Ĵ��������Ŀ�Ĳ������Ĵ�����ַ ������������ָ��wb�׶� 
											// ������ˮ�߿����źŲ���

	input	i_id_exe_reg_write;				// id-exe�Ĵ�������ļĴ���дʹ���ź� ��������ָ��
	input	i_exe_mem_reg_write;			// exe-mem�Ĵ�������ļĴ���дʹ���ź� ����������ָ��
	input	i_mem_wb_reg_write;				// mem-wb�Ĵ�������ļĴ���дʹ���ź� ������������ָ��
	input	i_id_exe_mem_read;				// id-exe�Ĵ�������Ĵ洢�����ź� ��������ָ��Ϊȡ��ָ��

	input	i_id_exe_hi_lo_write;			// id-exe�Ĵ��������HI LO�Ĵ���дʹ���ź� ��������ָ��
	input	i_exe_mem_hi_lo_write;			// exe-mem�Ĵ��������HI LO�Ĵ���дʹ���ź� ����������ָ��
	input	i_mem_wb_hi_lo_write;			// mem-wb�Ĵ��������HI LO�Ĵ���дʹ���ź� ������������ָ��

	input	i_overflow;						// �����ʶ
	input	i_interrupt_request;			// �ⲿ�ж��ź�
	input	i_id_exe_is_dslot;				// ִ�в����ӳٲ��ź�
	input	i_exe_mem_is_dslot;				// �洢�������ӳٲ��ź�
	
	input	i_id_exe_mult_div;				// ִ�в����˳��������ź�
	input	i_ready;						// �˳�����������ź�
	
	input	[31:0] i_if_pc;					// ȡָ����pc
	input	[31:0] i_if_id_pc;				// ���벿��pc
	input	[31:0] i_id_exe_pc;				// ִ�в���pc
	input	[31:0] i_exe_mem_pc;				// �洢������pc
	
	input	[ 5:0] i_interrupt_source;		// �ж�Դ

	input	[31:0] i_exe_hi;					// �˳�������HI�Ĵ���ִ�в���ת������
	// input	[31:0] i_exe_lo;					// �˳�������LO�Ĵ���ִ�в���ת������
	input	[31:0] i_mem_hi;					// �˳�������HI�Ĵ����洢������ת������
	// input	[31:0] i_mem_lo;					// �˳�������LO�Ĵ����洢������ת������
	input	[31:0] i_wb_hi;					// �˳�������HI�Ĵ�����д����
	// input	[31:0] i_wb_lo;					// �˳�������LO�Ĵ�����д����
	
	output	[ 5:0] o_interrupt_source;		// �������κ���ж�Դ
	
	output	[31:0] o_decode_src1;			// ����׶εõ�Դ������1
	output	[31:0] o_decode_src2;			// ����׶εõ�Դ������2

	// output	[31:0] o_alu_src1;				// ALUԴ������1
	// output	[31:0] o_alu_src2;				// ALUԴ������2

	output	[ 4:0] o_reg_dst;				// Ŀ�Ĳ������Ĵ�����ַ
	output	[ 1:0] o_data_width;				// ����ȡ��ָ�����ݿ��

	output	[31:0] o_next_pc;				// ת�� ��ת pc��ַ
	output	[31:0] o_eret_pc;				// �ж��쳣���� pc��ַ
	output	[31:0] o_excep_pc;				// �жϴ��� pc��ַ
	output	[ 1:0] o_pc_src;					// pc�µ�ַ��Դ
	output	[ 5:0] o_alu_ctrl;				// alu�����ź�
	
	output	o_alu_src_op1;					// aluԴ������1 ѡ��
	output	o_alu_src_op2;					// aluԴ������2 ѡ��
	output	o_extend_op;					// ��չ��ʽѡ��
	
	output	o_reg_write;					// �Ĵ���д�ź�
	output	o_mem_read;						// �洢�����ź�
	output	o_mem_write;					// �洢��д�ź�
	output	o_mem2reg;						// �洢��ȡ�����Ĵ����ź�
	output	o_unsign;						// ȡ����ʽ �ֽ� ���� �Ƿ���з�����չ
	output	o_pc_write;						// pcд�ź� ������ˮ����ͣ
	output	o_ir_write;						// irд�ź� ������ˮ����ͣ
	output	o_interrupt_answer;				// �ж���Ӧ�ź�
	output	o_pc_store;						// ��תָ���Ƿ��pc���д洢
	output	o_mtc0;							// mtc0ָ���ź�
	output	o_mfc0;							// mfc0ָ���ź�
	output	o_eret;							// eretָ���ź�
	output	o_next_is_dslot;				// ��һ��ָ�����ӳٲ��е�ָ��
	output	o_exception;					// �ж� �쳣ָ���ź�
	output	o_id_continue;					// �ж�ʱָ�����ִ��
	output	o_stall;						// ��ˮ����ͣ�ź�
	
	output	o_mfhi_lo;						// ��HI��LO�Ĵ�������ָ���ź�
											// ���ᷢ��ͬʱ��HI��LO

	output	o_mult_div;						// �˳��������ź�
	output	o_mult_div_cancel;				// �ж�ʱ�˳�������ȡ���ź�
	output	o_divide;						// ���������ź�
	output	o_sign;							// �з��ų˳����ź�

	// �ڲ��ź�
	wire	extend_op;						// ��������չ��ʽ
	wire	alu_src_op1;					// aluԴ������1ѡ�� [0]�Ĵ����� [1]ָ��shamt�ֶ�
	wire	alu_src_op2;					// aluԴ������2ѡ�� [0]�Ĵ����� [1]����imme��չ

	wire	mult;
	wire	multu;
	wire	div;
	wire	divu;
	wire	mfhi;
	wire	mflo;
	wire	mthi;
	wire	mtlo;
	wire	j;
	wire	jr;
	wire	jal; 
	wire	jalr; 
	wire	beq; 
	wire	bne;
	wire	bgez;
	wire	bgtz;
	wire	blez;
	wire	bltz;
	wire	bgezal;
	wire	bltzal; 

	wire	reg_dst_op;
	wire	reg_write;
	wire	mem_write;

	wire	syscall;
	wire	break_wire;
	
	wire	unknown_func;
	wire	unknown_command;

	wire	divzero;

	wire	[ 4:0] rs;					// rs�ֶ�
	wire	[ 4:0] rt;					// rt�ֶ�
	wire	[ 4:0] rd;					// rd�ֶ�
	wire	[ 5:0] op;					// op�ֶ�
	wire	[ 5:0] func;					// func�ֶ�
	wire	[15:0] imm;					// immediate�ֶ�
	wire	[25:0] addr;					// address�ֶ�

	// wire	[ 4:0] rt_or_r31;			// rt �� $31��ѡ����

	assign rs	= i_instr[25:21];
	assign rt	= i_instr[20:16];
	assign rd	= i_instr[15:11];
	assign op	= i_instr[31:26];
	assign func	= i_instr[ 5: 0];
	assign imm	= i_instr[15: 0];
	assign addr	= i_instr[25: 0];

	wire	[31:0] rs_data, rt_data;		// rs rt�Ĵ�����

	wire	[31:0] decode_src1;			// Դ������1���ڲ�ѡ������
	// wire	[31:0] decode_src2_in;		// Դ������2���ڲ�ѡ������
	wire	[31:0] decode_src2;			// Դ������2���ڲ�ѡ������
	wire	[31:0] cp0_data;				// ��cp0�Ĵ��������� Դ������2���ڲ�ѡ������

	// wire	[31:0] byte_data;
	// wire	[31:0] half_data;
	// wire	[31:0] word_data;
	
	// wire	[31:0] extended_data;		// ��չ������

	wire	[31:0] exe_lo, mem_lo, wb_lo;
	
	wire	[31:0] hi, hi_in;
	wire	[31:0] lo, lo_in;
	wire	[31:0] hi_lo, hi_lo_in;
	wire	[31:0] exe_hi_lo, mem_hi_lo, wb_hi_lo;

	// wire	[23:0] sign_ext_byte;
	// wire	[15:0] sign_ext_half;
	
	wire	[ 1:0] forward_src_op1;
	wire	[ 1:0] forward_src_op2;
	wire	[ 1:0] forward_hi_lo;
	
	wire	[ 2:0] src2_ctrl;

	//////////////////////////////////////////////////////////////////////////////////////////////
	// �ⲿ��ת�Ƶ�MEM�׶�ȡ������ѡ��
	// assign sign_ext_byte = {24{i_reg_data[7]}};
	// assign sign_ext_half = {16{i_reg_data[15]}};
	// 
	// �����Ƿ���з�����չ�����ݽ�����չ
	// assign byte_data = i_unsign ? {24'b0, i_reg_data[ 7:0]} : {sign_ext_byte, i_reg_data[ 7:0]};
	// assign half_data = i_unsign ? {16'b0, i_reg_data[15:0]} : {sign_ext_half, i_reg_data[15:0]};
	// 
	// ����ȡ�����ݿ��ѡ����ȷ������
	// mux4in1 REG_DATA_OP(
	// 	.i_data0(byte_data),
	// 	.i_data1(half_data),
	// 	.i_data2(i_reg_data),
	// 	.i_data3(i_reg_data),
	// 	.i_ctrl(i_data_width),
	// 	.o_data(word_data)
	// 	);
	//////////////////////////////////////////////////////////////////////////////////////////////
	assign exe_lo = i_alu_res;
	assign mem_lo = i_mem_data;
	assign wb_lo = i_reg_data;

	// �������ת��ָ����� д�Ĵ�������Ч
	// mult multu div divu ��д�Ĵ���
	assign o_reg_write = ((bgezal | bltzal) & (o_pc_src == 2'b01)) ? 1'b1 : reg_write & ~o_mult_div;
	assign o_mem_write = mem_write;

	// �������ת����ת��ָ�� ����һ��ָ�����ӳٲ��е�ָ��
	assign o_next_is_dslot = j | jal | jr | jalr | beq | bne | bgez | bgtz | blez | bltz | bgezal | bltzal;

	// ȷ��HI LO�Ĵ���������
	assign hi_in = mthi ? decode_src1 : i_wb_hi;
	assign lo_in = mtlo ? decode_src1 : wb_lo;

	// ȷ��HI LO�Ĵ��������
	assign o_mfhi_lo = mfhi | mflo;
	
	assign hi_lo_in = mfhi ? hi : lo;
	assign exe_hi_lo = mfhi ? i_exe_hi : exe_lo;
	assign mem_hi_lo = mfhi ? i_mem_hi : mem_lo;
	assign wb_hi_lo = mfhi ? i_wb_hi : wb_lo;
	
	// assign src2_ctrl[0] = o_mfc0 ? 1'b1 : 1'b0;
	assign src2_ctrl = 	o_mfhi_lo ? 3'b111 : 
						{o_mfc0, forward_src_op2};

	// ��˳�������������
	assign o_mult_div = mult | multu | div | divu;
	assign o_divide = div | divu;
	assign o_sign = mult | div;

	assign o_decode_src1 = decode_src1;
	assign o_decode_src2 = decode_src2;
	assign o_alu_src_op1 = alu_src_op1;
	assign o_alu_src_op2 = alu_src_op2;
	assign o_extend_op = extend_op;
	
	assign divzero = o_divide & !decode_src2;

	// // ȷ��Ŀ�Ĳ�������ַ [0]rt [1]$31
	// // assign rt_or_r31 = (jal | bgezal | bltzal) ? 31 : rt;
	// mux2in1 #(.WIDTH(5)) REG_DST_OP1( 
	// 	.i_data0(rt), 
	// 	.i_data1({5'b11111}),				// $31
	// 	.i_ctrl(jal | bgezal | bltzal), 
	// 	.o_data(rt_or_r31)
	// 	);

	// // ȷ��Ŀ�Ĳ�������ַ [0]rt [1]rd
	// // assign o_reg_dst = reg_dst_op & ~o_mfc0 ? rd : rt_or_r31;
	// mux2in1 #(.WIDTH(5)) REG_DST_OP2( 
	// 	.i_data0(rt_or_r31), 
	// 	.i_data1(rd), 
	// 	.i_ctrl(reg_dst_op & ~o_mfc0),	//  �����mfc0ָ������rt��ΪĿ�Ĳ�����
	// 	.o_data(o_reg_dst)
	// 	);

	// Ŀ�Ĳ�������ַ
	mux4in1 #(.WIDTH(5)) REG_DST_OP(
		.i_data0(rt), 
		.i_data1(5'b11111),				// $31
		.i_data2(rd),
		.i_data3(5'b00000), 
		.i_ctrl({reg_dst_op & ~o_mfc0, jal | bgezal | bltzal}), 
		.o_data(o_reg_dst)
		);

	// HI LO��������Դ
	mux4in1 HI_LO_OP( 
		.i_data0(hi_lo_in),			// [00] Ĭ��HI LO���� ���������
		.i_data1(exe_hi_lo),		// [01] exe��� ��ˮ������ת��
		.i_data2(mem_hi_lo),		// [10] �洢������ ��ˮ������ת��
		.i_data3(wb_hi_lo),			// [11] д������ ��ˮ������ת��
		.i_ctrl(forward_hi_lo), 
		.o_data(hi_lo)
		);

	// Դ��������Դ1
	mux4in1 SRC1_OP(  
		.i_data0(rs_data),			// [00] Ĭ��rs���� ���������
		.i_data1(i_alu_res),		// [01] alu��� ��ˮ������ת��
		.i_data2(i_mem_data),		// [10] �洢������ ��ˮ������ת��
		.i_data3(i_reg_data),		// [11] �Ĵ���д������ ��ˮ������ת��
		.i_ctrl(forward_src_op1), 
		.o_data(decode_src1)
		);

	// Դ��������Դ2
	mux8in1 SRC2_OP(
		.i_data0(rt_data),
		.i_data1(i_alu_res),
		.i_data2(i_mem_data),
		.i_data3(i_reg_data),
		.i_data4(cp0_data),
		.i_data5(32'b0),
		.i_data6(32'b0),
		.i_data7(hi_lo),
		.i_ctrl(src2_ctrl),
		.o_data(decode_src2)
		);
	
	// mux4in1 SRC2_OP1( 
	// 	.i_data0(rt_data),			// [00] Ĭ��rt���� ���������
	// 	.i_data1(i_alu_res),		// [01] alu��� ��ˮ������ת��
	// 	.i_data2(i_mem_data),		// [10] �洢������ ��ˮ������ת��
	// 	.i_data3(i_reg_data),		// [11] �Ĵ���д������ ��ˮ������ת��
	// 	.i_ctrl(forward_src_op2), 
	// 	.o_data(decode_src2_in)
	// 	);

	// // ��mfhi mflo mfc0�����ݾ�ͨ��Դ������src2���д���
	// mux4in1 SRC2_OP2(
	// 	.i_data0(decode_src2_in),		
	// 	.i_data1(cp0_data),			// mfc0ָ�� ��������cp0�Ĵ���
	// 	.i_data2(hi_lo),			// mfhiָ�� mfloָ�� ��������HI LO�Ĵ���
	// 	.i_data3(hi_lo),			// mfloָ�� mfloָ�� ��������LO Lo�Ĵ���
	// 	.i_ctrl(src2_ctrl),
	// 	.o_data(decode_src2)
	// 	);

	// // ��չ��
	// sign_extend EXTENDER ( 
	// 	.i_data(imm), 
	// 	.i_ctrl(extend_op), 
	// 	.o_data(extended_data)
	// );

	// // Դ������1��ѡ�� [0]rs [1]shamt
	// mux2in1 ALU_SRC_OP1 ( 
	// 	.i_data0(decode_src1),
	// 	.i_data1({27'b0, imm[10:6]}),
	// 	.i_ctrl(alu_src_op1),
	// 	.o_data(o_alu_src1)
	// 	);

	// // Դ������2��ѡ�� [0]rt/c0/hi/lo [1]extended-immediate
	// mux2in1 ALU_SRC_OP2 ( 
	// 	.i_data0(decode_src2), 
	// 	.i_data1(extended_data), 
	// 	.i_ctrl(alu_src_op2), 
	// 	.o_data(o_alu_src2)
	// 	);

	// �Ĵ�����
	reg_file REGISTERS( 
		.i_clk(i_clk),
		.i_rstn(i_rstn), 
		.i_raddr1(rs), 
		.i_raddr2(rt), 
		.i_waddr(i_mem_wb_reg_dst),
		.i_wdata(i_reg_data), 
		.i_we(i_reg_write), 
		.o_rdata1(rs_data),
		.o_rdata2(rt_data)
		);

	// �˳�������������ָ��������д�ؽ׶ν�����д�ص��Ĵ���
	// ����mthi mtloָ��Ĵ��� ����׶�Ҳ���ܻ�ֱ��дHI LO�Ĵ���
	// ������������ͻʱ ȡ������ָ�� ��mthi mtlo
	// Ϊ�˱�֤�ܹ���ID�׶�дHI LO ��ʱ�ӷ���
	// HI�Ĵ���
	dffe32 HI(
		.i_clk(~i_clk),
		.i_rstn(i_rstn),
		.i_we(i_mem_wb_hi_lo_write | mthi),
		.i_data(hi_in),
		.o_data(hi)
		);

	// LO�Ĵ���
	dffe32 LO(
		.i_clk(~i_clk),
		.i_rstn(i_rstn),
		.i_we(i_mem_wb_hi_lo_write | mtlo),
		.i_data(lo_in),
		.o_data(lo)
		);
	
	// ���ת�� ��ת��ַ
	// ��EXE�׶ν�������ж���ǰ��ID�׶� ��������Ϊһ��ָ����ӳٲ�
	nextPC NEXTPC ( 
		.i_pc_plus4(i_pc_plus4), 
		.i_addr(addr), 
		.i_j(j),
		.i_jal(jal), 
		.i_beq(beq), 
		.i_bne(bne),
		.i_bgez(bgez),
		.i_bgtz(bgtz),
		.i_blez(blez),
		.i_bltz(bltz),
		.i_bgezal(bgezal),
		.i_bltzal(bltzal), 
		.i_jr(jr),
		.i_jalr(jalr),
		.i_src1(decode_src1), 
		.i_src2(decode_src2),
		.i_exception(o_exception),
		.i_eret(o_eret),
		.o_next_pc(o_next_pc),
		.o_pc_src(o_pc_src),
		.o_pc_store(o_pc_store)
		);

	// alu���Ƶ�Ԫ ��Ҫ����R��ָ�������ָ����ź�
	// ���Է�����Ƶ�Ԫ�Ĺ��� 
	alu_control ALU_CU(
		.i_op(op),
		.i_rs(rs), 
		.i_func(func), 
		.o_alu_ctrl(o_alu_ctrl),
		.o_alu_src_op(alu_src_op1),
		.o_mult(mult),
		.o_multu(multu),
		.o_div(div),
		.o_divu(divu),
		.o_mfhi(mfhi),
		.o_mflo(mflo),
		.o_mthi(mthi),
		.o_mtlo(mtlo),
		.o_jr(jr),
		.o_jalr(jalr),
		.o_syscall(syscall),
		.o_break(break_wire),
		.o_eret(o_eret),
		.o_mfc0(o_mfc0), 
		.o_mtc0(o_mtc0),
		.o_unknown_func(unknown_func)
		);

	// ���Ƶ�Ԫ
	control CU(
		.i_op(op),
		.i_rt(rt),
 		.o_j(j), 
 		.o_jal(jal), 
		.o_beq(beq),
		.o_bne(bne),
		.o_bgez(bgez),
		.o_bgtz(bgtz),
		.o_blez(blez),
		.o_bltz(bltz),
		.o_bgezal(bgezal),
		.o_bltzal(bltzal),
		.o_reg_dst_op(reg_dst_op),
		.o_mem2reg(o_mem2reg),
		.o_mem_write(mem_write),
		.o_mem_read(o_mem_read),
		.o_unsign(o_unsign),
		.o_data_width(o_data_width),
		.o_alu_src_op2(alu_src_op2),
		.o_reg_write(reg_write),
		.o_extend_op(extend_op),
		.o_unknown_command(unknown_command)
		);

	// ��ˮ�߿�����
	pipeline_control PIPE_CU(
		.i_rs(rs),
		.i_rt(rt),
		.i_id_exe_reg_dst(i_id_exe_reg_dst),
		.i_exe_mem_reg_dst(i_exe_mem_reg_dst),
		.i_mem_wb_reg_dst(i_mem_wb_reg_dst),
		.i_id_exe_reg_write(i_id_exe_reg_write),
		.i_exe_mem_reg_write(i_exe_mem_reg_write),
		.i_mem_wb_reg_write(i_mem_wb_reg_write),
		.i_id_exe_mem_read(i_id_exe_mem_read),
		.i_id_exe_hi_lo_write(i_id_exe_hi_lo_write),
		.i_exe_mem_hi_lo_write(i_exe_mem_hi_lo_write),
		.i_mem_wb_hi_lo_write(i_mem_wb_hi_lo_write),
		.i_mfhi_lo(o_mfhi_lo),
		.i_id_exe_mult_div(i_id_exe_mult_div),
		.i_exception(o_exception),
		.i_ready(i_ready),
		.o_forward_src_op1(forward_src_op1),
		.o_forward_src_op2(forward_src_op2),
		.o_forward_hi_lo(forward_hi_lo),
		.o_pc_write(o_pc_write),
		.o_ir_write(o_ir_write),
		.o_stall(o_stall)
		);

	// CP0Э������
	cp0 CP0(
		.i_clk(i_clk), 
		.i_rstn(i_rstn),
		.i_overflow(i_overflow),
		.i_divzero(divzero),
		.i_unknown_command(unknown_command),
		.i_unknown_func(unknown_func),
		.i_interrupt_request(i_interrupt_request),
		.i_interrupt_source(i_interrupt_source),
		.i_syscall(syscall),
		.i_break(break_wire),
		.i_data(decode_src2),
		.i_address(rd),
		.i_if_pc(i_if_pc),
		.i_if_id_pc(i_if_id_pc),
		.i_id_exe_pc(i_id_exe_pc),
		.i_exe_mem_pc(i_exe_mem_pc),
		.i_next_is_dslot(o_next_is_dslot),
		.i_id_exe_is_dslot(i_id_exe_is_dslot),
		.i_exe_mem_is_dslot(i_exe_mem_is_dslot),
		.i_mtc0(o_mtc0),
		.i_mfc0(o_mfc0),
		.i_eret(o_eret),
		.i_mult_div(o_mult_div),
		.i_id_exe_mult_div(i_id_exe_mult_div),
		.i_ready(i_ready),
		.o_interrupt_answer(o_interrupt_answer),
		.o_interrupt_source(o_interrupt_source),
		.o_exception(o_exception),
		.o_id_continue(o_id_continue),
		.o_mult_div_cancel(o_mult_div_cancel),
		.o_eret_pc(o_eret_pc),
		.o_excep_pc(o_excep_pc),
		.o_cp0_data(cp0_data)
		);
endmodule
