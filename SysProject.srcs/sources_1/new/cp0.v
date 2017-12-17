`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/30 20:46:32
// Design Name: 
// Module Name: cp0
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// Э������cp0
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cp0(
	i_clk, 
	i_rstn,
	i_overflow,
	i_divzero,
	i_unknown_command,
	i_unknown_func,
	i_interrupt_request,
	i_interrupt_source,
	i_syscall,
	i_break,
	i_data,
	i_address,
	i_if_pc,
	i_if_id_pc,
	i_id_exe_pc,
	i_exe_mem_pc,
	i_next_is_dslot,
	i_id_exe_is_dslot,
	i_exe_mem_is_dslot,
	i_mtc0,
	i_mfc0,
	i_eret,
	i_mult_div,
	i_id_exe_mult_div,
	i_ready,
	o_interrupt_answer,
	o_interrupt_source,
	o_exception,
	o_id_continue,
	o_mult_div_cancel,
	o_eret_pc,
	o_excep_pc,
	o_cp0_data
	);

	localparam STATUS_ADDR	= 12;		// ״̬�Ĵ���STATUS���
	localparam CAUSE_ADDR	= 13;		// �쳣�ж�ԭ��Ĵ���CAUSE���
	localparam EPC_ADDR		= 14;		// �쳣���������EPC���

	/////////////////////////////////////////////////////////////////////////////
	// ip[7:0]	: cause[15:8]	exc_code[4:0]	: cause[6:2]
	// im[7:0]	: status[15:8]	ksu[1:0]		: status[4:3]	
	// exl 		: status[1]		ie 				: status[0]
	// bd		: status[31]
	/////////////////////////////////////////////////////////////////////////////


	/////////////////////////////////////////////////////////////////////////////
	// CP0�Ĵ������: mtc0 ֱ����ID����� ���������
	/////////////////////////////////////////////////////////////////////////////

	input	i_clk, i_rstn;
	input	i_overflow;
	input	i_divzero;
	input	i_unknown_command; 
	input	i_unknown_func;
	input	i_interrupt_request;		// �ж������ź�
	input	i_syscall;
	input	i_break;
	input	i_mtc0;
	input	i_mfc0;
	input	i_eret;
	input	i_mult_div;					// ����׶�Ϊ�˳����ź�
	input	i_id_exe_mult_div;			// ִ�н׶�Ϊ�˳����ź�
	input	i_ready;					// ִ�н׶�Ϊ�˳����ź�
	input	i_next_is_dslot;			// ת��ָ���ж��ź� ����ID��
	input	i_id_exe_is_dslot;			// �ӳٲ��ж��ź� ����ID��
	input	i_exe_mem_is_dslot;			// �ӳٲ��ж��ź� ����EXE��

	input	[31:0]	i_if_pc;
	input	[31:0]	i_if_id_pc;
	input	[31:0]	i_id_exe_pc;
	input	[31:0]	i_exe_mem_pc;
	input	[31:0]	i_data;				// дC0�Ĵ�������
	input	[ 4:0]	i_address;			// �Ĵ�����ַ
	input	[ 5:0]	i_interrupt_source;	// �ж�Դ�ź�

	output	o_exception;				// �ж� �쳣�ź�
	
	output	reg	o_interrupt_answer;		// �ж���Ӧ�ź�
	output	reg	o_id_continue;			// �ж�ʱָ�����ִ��
	output	reg	o_mult_div_cancel;		// �ж�ʱִ�н׶εĳ˳���ָ��ȡ��

	output	reg [ 5:0] o_interrupt_source;	// �������κ���ж�Դ

	output	[31:0]	o_eret_pc;			// �ж��쳣���ص�ַ
	output	[31:0]	o_excep_pc;			// �ж���ڵ�ַ
	output	[31:0]	o_cp0_data;			// ��C0�Ĵ�������
	
	reg	[31:0]	pc_to_epc;				// д��EPC��pc��ַ
	// reg	[31:0]	excep_entry;		// �жϴ�������ַ

	localparam EXCEPTION_ENTRY = 32'h00000008;
	
	// reg	interrupt_processing;			// �ж�״̬�Ĵ���

	reg [4:0]	exc_code;				// CAUSE�Ĵ���Exc Code�ֶ� �쳣����
	reg [7:0]	ip;						// CAUSE�Ĵ���IP�ֶ�
	reg [7:0]	im;						// STATUS�Ĵ����ж������ֶ�
	reg [1:0]	ksu_reg;				// ����STATUS�Ĵ���KSU�ֶ�
	reg ie_reg;							// ����STATUS�Ĵ����ж�ʹ���ֶ�
	reg exl_reg;							// ����STATUS�Ĵ���EXL�ֶ�
	// reg last_ie;						// �ݴ��ж��쳣����ǰ�� STATUS�Ĵ����ж�ʹ���ֶ�
	reg bd;								// CAUSE�ֶ�BDλ ���BDλλ1������쳣ָ������ӳٲ�

	reg ir_reg;							// ��¼�ж��ź�������

	reg r_interrupt_request;			// ʹ�üĴ�������һ���ȶ����ж������ź�

	wire [1:0]	ksu;					// STATUS�Ĵ���KSU�ֶ�
	wire ie;								// STATUS�Ĵ����ж�ʹ���ֶ�
	wire exl;							// STATUS�Ĵ���EXL�ֶ�

	wire status_we;						// ״̬�Ĵ���STATUSдʹ��
	wire cause_we;						// �쳣�ж�ԭ��Ĵ���CAUSEдʹ��
	wire epc_we;							// �쳣���������EPCдʹ��

	// wire ie_from_status;				// ��STATUS�Ĵ���������ieֵ
	// wire exl_from_status;				// ��STATUS�Ĵ���������exlֵ

	wire accept_exception;				// �ɽ����жϻ��쳣״̬

	wire interrupt_request;				// ����ж�����λ���ж�����λ�жϺ����Ч�ж������ź�
	wire exception;						// �����жϻ��쳣
	
	wire is_kernel;						// �����ں���̬

	wire [31:0]	epc, cause, status;		// EPC CAUSE STATUS�Ĵ����������
	wire [31:0] status_data;				// дSTATUS�Ĵ�������
	wire [31:0] cause_data;				// дCAUSE�Ĵ�������

	// wire [ 5:0] int_source;
	// assign int_source = i_interrupt_source;

	assign status_data = {16'b0, im[7:0], 3'b0, ksu, 1'b0, exl, ie};
	assign cause_data = {bd, 15'b0, ip[7:0], 1'b0, exc_code[4:0], 2'b00};

	// assign status_data = {16'b0, im[7:0], 7'b0, ie};
	// assign cause_data = {16'b0, ip[7:0], 1'b0, exc_code[4:0], 2'b00};

	assign status_we	 = (i_mtc0 & i_address == STATUS_ADDR & is_kernel) | i_eret | epc_we;
	// �жϷ���ʱ����дCAUSE�Ĵ���
	assign cause_we	= (i_mtc0 & i_address == CAUSE_ADDR  & is_kernel) | epc_we; // | i_eret
	// 
	assign epc_we = (i_overflow & (im[1:0] == 2'b01) |
					(i_syscall | i_break | i_unknown_command | i_unknown_func | i_divzero) & (im[1:0] == 2'b10) |
					r_interrupt_request & (im[1:0] == 2'b00)) & accept_exception;
					// & ie_from_status & ~exl_from_status;

	// assign ie_from_status	= status[0];
	// assign exl_from_status	= status[1];

	// assign o_interrupt_source = (im[7:2] & ip[7:2]);

	assign accept_exception = ~exl_reg & ie_reg;

	// ע������ʹ�õ��ǵ�����IP������CAUSE ԭ����Ӳ���ж�Դ�޷�ֱ�Ӵ�ʹCAUSE��д?
	assign interrupt_request = (|(status[15:10] & i_interrupt_source[5:0])) & i_interrupt_request;
	// always @(posedge i_clk or negedge i_rstn) begin
	// 	if (~i_rstn) begin
	// 		// reset
	// 		interrupt_request <= 1'b0;
	// 	end
	// 	else begin
	// 		interrupt_request <= (|i_interrupt_source & status[15:8]) & i_interrupt_request;
	// 	end
	// end
	
	// assign interrupt_request = (|o_interrupt_source) & ir_reg;

	assign is_kernel = ~ksu_reg[1] & ~ksu_reg[0];

	assign exception = epc_we;

	// ���ж� ���ж�
	// ͨ����exl������λ �������ʵ�� STATUS����λ��������
	assign ie = status[0];
	assign exl = exception ? 1'b1 : (i_eret ? 1'b0 : status[1]);
	assign ksu = exception ? 2'b00 : (i_eret ? 2'b10 : status[4:3]);
	
	assign o_exception	= exception;
	assign o_eret_pc	= epc;
	assign o_excep_pc	= EXCEPTION_ENTRY;

	wire [31:0] status_in;	
	wire [31:0] cause_in;
	wire [31:0] epc_in;

	// always @(posedge i_interrupt_request or edge i_rstn) begin
	// 	if (~rst) begin
	// 		// reset
	// 		ir_reg <= 1'b0;
	// 	end
	// 	else begin
	// 		ir_reg <= 1'b1;
	// 	end
	// end

	mux2in1 STATUS_OP(
		.i_data0(status_data),
		.i_data1(i_data),
		.i_ctrl(i_mtc0 & i_address == STATUS_ADDR),
		.o_data(status_in)
		);

	mux2in1 CAUSE_OP(
		.i_data0(cause_data),
		.i_data1(i_data),
		.i_ctrl(i_mtc0 & i_address == CAUSE_ADDR),
		.o_data(cause_in)
		);

	mux2in1 EPC_OP(
		.i_data0(pc_to_epc),
		.i_data1(i_data),
		.i_ctrl(i_mtc0 & i_address == EPC_ADDR),
		.o_data(epc_in)
		);

	// дStatus�Ĵ���
	dffe32 STATUS(
		.i_clk(~i_clk),
		.i_rstn(i_rstn),
		.i_we(status_we),
		.i_data(status_in),
		.o_data(status)
		);
 
	// дCause�Ĵ���
	dffe32 CAUSE(
		.i_clk(~i_clk),
		.i_rstn(i_rstn),
		.i_we(cause_we),
		.i_data(cause_in),
		.o_data(cause)
		);
	
	// дEPC�Ĵ���
	dffe32 EPC(
		.i_clk(~i_clk),
		.i_rstn(i_rstn),
		.i_we(epc_we | (i_mtc0 & i_address == EPC_ADDR & is_kernel)),
		.i_data(epc_in),
		.o_data(epc)
		);

	// �����ж����쳣
	// �쳣��������
	// bdλΪ1 �����쳣ָ��ΪEPC+4�� 
	// ʵ�־�ȷ�жϴ���ʽ
	// �쳣ʱ��ˮ��ȡָ�����벿����ָ��ᱻȡ��
	// �ж�ʱ�����벿��Ϊת��ָ�� ��ȡ�����벿��ָ�� ����������벿��ָ���ִ�����
	always @(*) begin
//		if (~i_rstn) begin
			pc_to_epc	= 32'b0;
			exc_code	= 5'b0;
			im[1:0]		= 2'b0;
			ip[1:0]		= 2'b0;
			bd			= 1'b0;
			o_id_continue = 1'b1;
			o_mult_div_cancel = 1'b0;
//		end else begin
			// ���
			if (i_overflow & accept_exception) begin 	// ����쳣 ִ��ʱ��⵽���� ���ȼ����
				if (i_exe_mem_is_dslot) begin		// �������������ӳٲ�ָ��
					pc_to_epc = i_exe_mem_pc;		// �쳣���ص�ַΪ������ָ��(ת��ָ��)�ĵ�ַ
					bd = 1'b1;						// BDλ��1 ��ʾ�쳣ָ���ַΪEPC+4
					o_id_continue = 1'b0;			// ȡ����һ��ָ�������һ��ָ��
				end									// �����벿����ǰָ���ȡָ����ָ��
				else begin 							// �������
					pc_to_epc = i_id_exe_pc;			// �쳣���ص�ַ����ִ�в��� ����ǰָ��
					o_id_continue = 1'b0;			// ȡ����ǰָ�����һ��ָ��
				end									// �����벿����ǰָ���ȡָ����ָ��
				im[1:0]		= 2'b01;					// �޸��ж�����λ
				ip[1:0]		= 2'b01;
				exc_code	= 5'b01100;				// ��¼���ʹ���
			end	
			// ���� ����׶μ�⵽
			else if (i_divzero & accept_exception) begin 			
													// �����쳣 ����ʱ��⵽����
				if (i_id_exe_is_dslot) begin			// �����ǰָ�����ӳٲ�ָ��(ָδָ֪���쳣 
													// ϵͳ����ָ��ܳ������ӳٲ�)
					pc_to_epc = i_id_exe_pc;			// �쳣���ص�ַΪ����ָ��(ת��ָ��)�ĵ�ַ
					bd = 1'b1;						// BDλ��1 ��ʾ�쳣ָ���ַΪEPC+4
					o_id_continue = 1'b0;			// ȡ����ǰָ��
				end 
				else if (!i_ready | i_id_exe_mult_div) begin	// ���EXE�׶��ǳ˳���ָ��
					pc_to_epc = i_id_exe_pc;			// �쳣����ָ��Ϊǰһ���˳���ָ��
					bd = 1'b1;						// BDλ��1 ��ʾ�쳣ָ���ַΪEPC+4
					o_id_continue = 1'b0;			// ��ǰָ��ȡ��
					o_mult_div_cancel = 1'b1;		// EXE�׶γ˳���ָ��ȡ��
				end
				else begin							// ȡ����һ��ָ��(ת��ָ��ִ�к�õ���ָ��)
					pc_to_epc = i_if_id_pc;			// ������� �쳣���ص�ַ�������벿��(��ǰָ��)
					o_id_continue = 1'b0;			// ȡ����ǰָ��
				end									// ȡ����һ��ָ��(ȡָ����ȡ��ָ��)
				im[1:0]		= 2'b01;					// �޸��ж�����λ
				ip[1:0]		= 2'b01;
				exc_code	= 5'b01101;				// ��¼���ʹ���
			end	
			// �û�̬��������Ȩָ���쳣
			else if ((i_mtc0 | i_eret | i_mfc0) & ~is_kernel & accept_exception) begin
				if (!i_ready | i_id_exe_mult_div) begin	// ���EXE�׶��ǳ˳���ָ��
					pc_to_epc = i_id_exe_pc;			// �쳣����ָ��Ϊǰһ���˳���ָ��
					bd = 1'b1;						// BDλ��1 ��ʾ�쳣ָ���ַΪEPC+4
					o_id_continue = 1'b0;			// ��ǰָ��ȡ��
					o_mult_div_cancel = 1'b1;		// EXE�׶γ˳���ָ��ȡ��
				end
				else if (i_id_exe_is_dslot) begin	// �����ǰָ�����ӳٲ�ָ��(ָδָ֪���쳣 
													// ϵͳ����ָ��ܳ������ӳٲ�)
					pc_to_epc = i_id_exe_pc;			// �쳣���ص�ַΪ����ָ��(ת��ָ��)�ĵ�ַ
					bd = 1'b1;						// BDλ��1 ��ʾ�쳣ָ���ַΪEPC+4
					o_id_continue = 1'b0;			// ȡ����ǰָ��
				end else begin						// ȡ����һ��ָ��(ת��ָ��ִ�к�õ���ָ��)
					pc_to_epc = i_if_id_pc;			// ������� �쳣���ص�ַ�������벿��(��ǰָ��)
					o_id_continue = 1'b0;			// ȡ����ǰָ��
				end									// ȡ����һ��ָ��(ȡָ����ȡ��ָ��)
				im[1:0]		= 2'b10;					// �޸��ж�����λ
				ip[1:0]		= 2'b10;
				exc_code	= 5'b01011;				// �û�̬������Ȩָ���쳣
			end
			// ����ָ�� syscall break�쳣 ����ʱ��⵽����
			else if ((i_syscall | i_break | i_unknown_func | i_unknown_command) 
					& accept_exception) begin
				if (!i_ready | i_id_exe_mult_div) begin	// ���EXE�׶��ǳ˳���ָ��
					pc_to_epc = i_id_exe_pc;			// �쳣����ָ��Ϊǰһ���˳���ָ��
					bd = 1'b1;						// BDλ��1 ��ʾ�쳣ָ���ַΪEPC+4
					o_id_continue = 1'b0;			// ��ǰָ��ȡ��
					o_mult_div_cancel = 1'b1;		// EXE�׶γ˳���ָ��ȡ��
				end
				else if (i_id_exe_is_dslot) begin	// �����ǰָ�����ӳٲ�ָ��(ָδָ֪���쳣 
													// ϵͳ����ָ��ܳ������ӳٲ�)
					pc_to_epc = i_id_exe_pc;			// �쳣���ص�ַΪ����ָ��(ת��ָ��)�ĵ�ַ
					bd = 1'b1;						// BDλ��1 ��ʾ�쳣ָ���ַΪEPC+4
					o_id_continue = 1'b0;			// ȡ����ǰָ��
				end else begin						// ȡ����һ��ָ��(ת��ָ��ִ�к�õ���ָ��)
					pc_to_epc = i_if_id_pc;			// ������� �쳣���ص�ַ�������벿��(��ǰָ��)
				end									// ȡ����һ��ָ��(ȡָ����ȡ��ָ��)
				im[1:0]		= 2'b10;					// �޸��ж�����λ
				ip[1:0]		= 2'b10;
				exc_code	= (i_syscall == 1'b1 ? 5'b01000 : (i_break == 1'b1 ? 5'b01001 : 5'b01010));
			end	
			// �ⲿ�ж�									
			else if(r_interrupt_request & accept_exception) begin			
													// �����ⲿ�ж� ������Ӧ�ж� ȡ��������ˮ����ȡ��ָ��
				if (i_mult_div) begin				// ����жϷ���ʱ ID�׶��ǳ˳���ָ��
					pc_to_epc = i_if_id_pc;			// �жϷ��ص�ַ��Ϊ�˳˳���ָ��
					o_id_continue = 1'b0;			// �˳���ָ��ȡ��
				end 
				else if (!i_ready | i_id_exe_mult_div) begin // ����жϷ���ʱ EXE�׶��ǳ˳���ָ��
					pc_to_epc = i_id_exe_pc;			// �жϷ���ָ����Ϊ�˳˳���ָ�� �˳���ָ��ȡ��
					o_id_continue = 1'b0;			// IDָ��ȡ��
					o_mult_div_cancel = 1'b1;		// EXE�׶γ˳���ָ��ȡ��
					// bd = 1'b1;					// bdλ��1 ��ʾ
				end
				else if (i_next_is_dslot) begin		// ����жϷ���ʱ ID�׶�ָ����ת��ָ��(�ӳ�)
					pc_to_epc = i_if_id_pc;			// �жϷ��ص�ַ��Ϊ��ת��ָ�� ��һ��ָ��(�ӳٲ�)ȡ��
					o_id_continue = 1'b0;			// ȡ�����벿��ָ�� ��������ָ��д�Ĵ���
				end									// �ӳٲ�ָ���ͬʱ��ת��ָ��!!!!!!!
				else if (i_id_exe_is_dslot) begin	// ����жϷ���ʱ ID�׶�ָ�����ӳٲ�ָ��
					pc_to_epc = i_if_pc;				// �жϷ��ص�ַ Ϊת��ָ��ִ�к�õ���ָ��
					o_id_continue = 1'b1;			// ��ȡ���ӳٲ�ָ��(���벿����ǰָ��)		
				end									// ��һ��ָ��(ת��ָ��ִ�к�õ���ָ��)ȡ��
				else begin							// һ�����
					pc_to_epc = i_if_pc;				// �жϷ��ص�ַ����ȡָ����
					o_id_continue = 1'b1;			// ���벿��ָ�����ִ��
				end									// ��һ��ָ��(ȡָ����ȡ��ָ��)ȡ��
				im[1:0]		= 2'b00;					// �޸��ж�����λ
				ip[1:0]		= 2'b00;
				exc_code	= 5'b00000;				// ��¼���ʹ���
			end 
//			else begin
//				o_id_continue		= 1'b1;
//				o_mult_div_cancel	= 1'b0;		
//			end	
			// else if (i_clk) begin
			// 	pc_to_epc	= 32'b0;
			// 	exc_code	= 5'b0;
			// 	im[1:0]		= 2'b0;
			// 	ip[1:0]		= 2'b0;
			// 	bd			= 1'b0;
			// 	o_id_continue = 1'b1;
			// 	o_mult_div_cancel = 1'b0;
			// end
//		end
	end

	// ���ж� ���ж�
	// ͨ����exl������λ �������ʵ�� STATUS����λ��������
	// assign ie = status[0];
	// assign exl = exception ? 1'b1 : (i_eret ? 1'b0 : status[1]);
	// assign ksu = exception ? 2'b00 : (i_eret ? 2'b10 : status[4:3]);
	always @(posedge i_clk or negedge i_rstn) begin
		if (~i_rstn) begin
			// reset
			ie_reg		<= 1'b0;		// Ĭ�Ϲ��ж�
			exl_reg		<= 1'b0;
			ksu_reg		<= 2'b0;
			o_interrupt_answer	<= 1'b0;
		end
		// else if (i_eret & last_ie) begin
		// 	exl		<= 1'b0;			// ���exl
		// 	ksu		<= 2'b10;			// �ָ��û�̬
		// end
		// else if (epc_we) begin
		// 	exl		<= 1'b1;			// ��exl
		// 	ksu		<= 2'b0;			// �����ں�̬
		// end
		else begin
			ie_reg		<= status[0];	
			exl_reg		<= status[1];
			ksu_reg		<= status[4:3];
			if (epc_we & interrupt_request) begin
				o_interrupt_answer	<= 1'b1;
			end
			else begin
				o_interrupt_answer	<= 1'b0;
			end
		end
	end
	// always @(*) begin
	// 	if (~i_rstn) begin
	// 		// reset
	// 		ie		= 1'b0;			// Ĭ�Ϲ��ж�
	// 		exl		= 1'b0;
	// 		ksu		= 2'b0;
	// 	end
	// 	else if (i_eret & last_ie) begin
	// 		exl		= 1'b0;			// ���exl
	// 		ksu		= 2'b10;			// �ָ��û�̬
	// 	end
	// 	else if (epc_we) begin
	// 		exl		= 1'b1;			// ��exl
	// 		ksu		= 2'b0;			// �����ں�̬
	// 	end
	// 	else begin
	// 		ie		= status[0];	
	// 		exl		= status[1];
	// 		ksu		= status[4:3];
	// 	end
	// end

	// // �ж��쳣״̬�л�
	// always @(posedge i_clk or negedge i_rstn) begin
	// 	if (~i_rstn) begin
	// 		interrupt_processing <= 1'b0;			// �ж�״̬ ���ж�
	// 		excep_entry <= EXCEPTION_ENTRY;			// �жϴ��������ڵ�ַ��ʼ��
	// 		o_interrupt_answer <= 1'b0;				// �ж�Ӧ���ź�	
	// 	end 
	// 	else begin
	// 		if (epc_we) begin
	// 			interrupt_processing <= 1'b1;		// �ж�״̬ �ж�
	// 			o_interrupt_answer <= interrupt_request == 1'b1 ? 1'b1 : 1'b0;// �ж���Ӧ
	// 		end else begin
	// 			o_interrupt_answer <= 1'b0;
	// 		end
	// 		// if(i_eret & last_ie) begin
	// 		if(i_eret) begin
	// 			interrupt_processing <= 1'b0;		// �ж�״̬ ���ж�
	// 		end
	// 	end
	// end

	// �ݴ��ж� �쳣����ǰ��status״̬�Ĵ�������
	always @(posedge i_clk or negedge i_rstn) begin
		if (~i_rstn) begin
			// last_ie <= 0;
			// ksu		<= 0;
			im[7:2]	<= 0;
			ip[7:2]	<= 0;
			r_interrupt_request	<= 0;
			o_interrupt_source 	<= 0;
		end
		else begin
			// ksu			<= status[4:3];
			im[7:2]		<= status[15:10];
			ip[7:2]		<= i_interrupt_source[5:0];
			r_interrupt_request			<= (|(status[15:10] & i_interrupt_source[5:0])) & i_interrupt_request;
			o_interrupt_source[5:0] 	<= status[15:10] & i_interrupt_source[5:0];
			// if (exception) begin
			// 	last_ie	<= status[0];
			// end
		end
	end

	// always @(posedge i_clk or negedge i_rstn) begin
	// 	if (i_rstn) begin
	// 		// reset
	// 		o_exception	<= 1'b0;
	// 	end
	// 	else if (exception) begin
	// 		o_exception	<= 1'b1;
	// 	end
	// 	else begin
	// 		o_exception	<= 1'b0;
	// 	end
	// end

	// ��cp0���
	mux4in1 CP0_DATA(
		.i_data0(status),
		.i_data1(cause),
		.i_data2(epc),
		.i_data3(32'b0),
		.i_ctrl(i_address[1:0]),
		.o_data(o_cp0_data)
		);
	
	// always @(*) begin 
	// 	case(i_address)
	// 		STATUS_ADDR:	o_cp0_data = status;
	// 		CAUSE_ADDR:		o_cp0_data = cause;
	// 		EPC_ADDR:		o_cp0_data = epc;
	// 		default:		o_cp0_data = 32'b0;
	// 	endcase 

	// 	o_eret_pc	= epc;
	// 	o_exception	= epc_we & ~exl_from_status & ie_from_status;
	// 	o_excep_pc	= excep_entry;
	// end

	

endmodule
