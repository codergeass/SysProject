`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/05 16:22:26
// Design Name: 
// Module Name: pipeline_control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// ��ˮ�߿����� ��������ת�������źŵ����� �Լ���ͣ��ˮ
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pipeline_control(
	i_rs,
	i_rt,
	i_id_exe_reg_dst,
	i_exe_mem_reg_dst,
	i_mem_wb_reg_dst,
	i_id_exe_reg_write,
	i_exe_mem_reg_write,
	i_mem_wb_reg_write,
	i_id_exe_mem_read,
	i_id_exe_hi_lo_write,
	i_exe_mem_hi_lo_write,
	i_mem_wb_hi_lo_write,
	i_mfhi_lo,
	i_id_exe_mult_div,
	i_exception,
	i_ready,
	o_forward_src_op1,
	o_forward_src_op2,
	o_forward_hi_lo,
	o_pc_write,
	o_ir_write,
	o_stall
	);
	
	input	[4:0] i_rs;					// rs�Ĵ�����ַ
	input	[4:0] i_rt;					// rt�Ĵ�����ַ
	input	[4:0] i_id_exe_reg_dst;		// id-exe�Ĵ��������Ŀ�Ĳ������Ĵ�����ַ ��������ָ��exe�׶�
	input	[4:0] i_exe_mem_reg_dst;	// exe-mem�Ĵ��������Ŀ�Ĳ������Ĵ�����ַ ����������ָ��mem�׶�
	input	[4:0] i_mem_wb_reg_dst;		// mem-wb�Ĵ��������Ŀ�Ĳ������Ĵ�����ַ ������������ָ��wb�׶�

	input	i_id_exe_reg_write;			// id-exe�Ĵ�������ļĴ���дʹ���ź� ��������ָ��
	input	i_exe_mem_reg_write;		// exe-mem�Ĵ�������ļĴ���дʹ���ź� ����������ָ��
	input	i_mem_wb_reg_write;			// mem-wb�Ĵ�������ļĴ���дʹ���ź� ������������ָ��
	input	i_id_exe_mem_read;			// id-exe�Ĵ�������Ĵ洢�����ź� ��������ָ��Ϊȡ��ָ��
	input	i_id_exe_hi_lo_write;		// id-exe�Ĵ�������Ĵ洢�����ź� ��������ָ��Ϊȡ��ָ��
	input	i_exe_mem_hi_lo_write;		// id-exe�Ĵ�������Ĵ洢�����ź� ��������ָ��Ϊȡ��ָ��
	input	i_mem_wb_hi_lo_write;		// id-exe�Ĵ�������Ĵ洢�����ź� ��������ָ��Ϊȡ��ָ��
	input	i_exception;				// �쳣�ź�
	input	i_mfhi_lo;					// ���벿��mfhi mfloָ���ź�
	input	i_id_exe_mult_div;			// ִ�в����˳���ָ���ź�
	input	i_ready;					// �˳�������������ź�

	output	reg [1:0] o_forward_src_op1;	// Դ������1����ת��ѡ��
	output	reg [1:0] o_forward_src_op2;	// Դ������2����ת��ѡ��
	output	reg [1:0] o_forward_hi_lo;	// HI LO�Ĵ�������ת��ѡ��
	
	output	reg o_pc_write;				// pcдʹ��
	output	reg o_ir_write;				// irдʹ��
	output	reg o_stall;					// ��ˮ����ͣ�ź�

	always @(*) begin
		// Դ������1��ת���ź�
		if ((i_rs == i_id_exe_reg_dst) & (i_id_exe_reg_dst!= 0) & i_id_exe_reg_write) begin
			// ��ǰָ������һ��ָ������������ �����ݴ�aluת�������벿��
			o_forward_src_op1 = 2'b01;
		end
		else if ((i_rs == i_exe_mem_reg_dst) & (i_exe_mem_reg_dst != 0) & i_exe_mem_reg_write) begin
			// ��ǰָ����������ָ������������ �����ݴ�memת�������벿��
			o_forward_src_op1 = 2'b10;
		end
		else if ((i_rs == i_mem_wb_reg_dst) & (i_mem_wb_reg_dst != 0) & i_mem_wb_reg_write) begin
			// ��ǰָ������������ָ������������ �����ݴ�wbת�������벿��
			o_forward_src_op1 = 2'b11;
		end
		else begin
			// Ĭ�� ��������� ��ת��
			o_forward_src_op1 = 2'b00;
		end

		// Դ������2��ת���ź� 
		if ((i_rt == i_id_exe_reg_dst) & (i_id_exe_reg_dst!= 0) & i_id_exe_reg_write) begin
			// ��ǰָ������һ��ָ������������ �����ݴ�exeת�������벿��
			o_forward_src_op2 = 2'b01;
		end
		else if ((i_rt == i_exe_mem_reg_dst) & (i_exe_mem_reg_dst != 0) & i_exe_mem_reg_write) begin
			// ��ǰָ����������ָ������������ �����ݴ�memת�������벿��
			o_forward_src_op2 = 2'b10;
		end
		else if ((i_rt == i_mem_wb_reg_dst) & (i_mem_wb_reg_dst != 0) & i_mem_wb_reg_write) begin
			// ��ǰָ������������ָ������������ �����ݴ�wbת�������벿��
			o_forward_src_op2 = 2'b11;
		end
		else begin
			// Ĭ�� ��������� ��ת��
			o_forward_src_op2 = 2'b00;
		end

		// HI LO�Ĵ�����ת���ź�
		if (i_mfhi_lo & i_id_exe_hi_lo_write) begin
			// ǰһ��ָ���ǳ˳���ָ�� ��������� �����ݴ�exeת��
			o_forward_hi_lo = 2'b01;
		end
		else if (i_mfhi_lo & i_exe_mem_hi_lo_write) begin
			// ������ָ���ǳ˳���ָ�� ��������� �����ݴ�memת��
			o_forward_hi_lo = 2'b10;
		end
		else if (i_mfhi_lo & i_mem_wb_hi_lo_write) begin
			// ��������ָ���ǳ˳���ָ�� ��������� �����ݴ�wbת��
			o_forward_hi_lo = 2'b11;
		end
		else begin
			// Ĭ�� ��������� ��ת��
			o_forward_hi_lo = 2'b00;
		end

		// ��ͣ��ˮ���ź�
		// ȡ��ָ��Ҫ��mem�׶β����������� ����Ҫ��ͣһ��ʱ������
		if (((i_rs == i_id_exe_reg_dst) | (i_rt == i_id_exe_reg_dst)) 
			& (i_id_exe_reg_dst != 0) & i_id_exe_mem_read & ~i_exception) begin
			o_stall		= 1'b1;
			o_pc_write	= 1'b0;
			o_ir_write	= 1'b0;
		end
		else if ((~i_ready | i_id_exe_mult_div) & ~i_exception) begin 	// �˳�������δ������� ��ͣ��ˮ��
			o_stall		= 1'b1;
			o_pc_write	= 1'b0;
			o_ir_write	= 1'b0;
		end
		else begin
			o_stall		= 1'b0;
			o_pc_write	= 1'b1;
			o_ir_write	= 1'b1;
		end
		 
	end
endmodule
