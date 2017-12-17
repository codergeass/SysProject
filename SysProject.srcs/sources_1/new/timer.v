`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/30 10:42:53
// Design Name: 
// Module Name: timer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// ��ʱ��
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module timer(
	i_clk,
	i_rstn,
	i_we,
	i_re,
	i_op,
//	i_inta0,
//	i_inta1,
	i_data,
//	o_ir0,
//	o_ir1,
	o_data,
	o_out0,
	o_out1
	);
	
	/////////////////////////////////////////////////////////////////////////////
	// ����������ʱ������ ÿ����ʱ�����������ĸ��Ĵ��� ���弰��ַ����
	// opȡ��ַ��[3:1]
	// ��ʽ�Ĵ���		[0]op:000(0xfffffc20)	[1]op:001(0xfffffc22)
	// ״̬�Ĵ���		[0]op:010(0xfffffc24)	[1]op:011(0xfffffc26)
	// ��ʼֵ�Ĵ���		[0]op:100(0xfffffc28)	[1]op:101(0xfffffc2a)
	// ��ǰֵ�Ĵ���		[0]op:110(0xfffffc2c)	[1]op:111(0xfffffc2e)
	/////////////////////////////////////////////////////////////////////////////

	/////////////////////////////////////////////////////////////////////////////
	// �ж������ź�Ϊһ������
	/////////////////////////////////////////////////////////////////////////////

	input	i_clk;
	input	i_rstn;
	input	i_we;				// дʹ��
	input	i_re;				// ��ʹ��
//	input	i_inta0;			// �ж���Ӧ0
//	input	i_inta1;			// �ж���Ӧ1
	
	input	[ 2:0] i_op;
	input	[15:0] i_data;
	output	[15:0] o_data;
	
//	output	o_ir0;				// �ж�����0
//	output	o_ir1;				// �ж�����1
	output	o_out0;				// ��ʱ���
	output	o_out1;				// ��ʱ���

	wire	[15:0] data0, data1;
	// wire	out0, out1;
	wire	cnt_clk;

	assign	o_data	= i_re ? (i_op[0] ? data1 : data0) : 16'b0;
	// assign	o_out	= i_op[0] ? out1 : out0;
	
	//��Ƶ��23kHz
	clk_div #(.COUNT(500)) CLK_DIV(
		.i_clk(i_clk),
		.i_rstn(i_rstn),
		.o_clk(cnt_clk)
		);
			
	// ��ʱ������0
	cnt CNT0(
		.i_clk(i_clk),
		.i_timer_clk(cnt_clk),
//		.i_timer_clk(i_clk),
		.i_rstn(i_rstn),
		.i_we(i_we & ~i_op[0]),
		.i_re(i_re & ~i_op[0]),
		.i_op(i_op[2:1]),
//		.i_inta(i_inta0),
		.i_data(i_data),
		.o_data(data0),
//		.o_ir(o_ir0),
		.o_out(o_out0)
		);

	// ��ʱ������1
	cnt CNT1(
		.i_clk(i_clk),
		.i_timer_clk(cnt_clk),
//		.i_timer_clk(i_clk),	// sim
		.i_rstn(i_rstn),
		.i_we(i_we & i_op[0]),
		.i_re(i_re & i_op[0]),
		.i_op(i_op[2:1]),
//		.i_inta(i_inta1),
		.i_data(i_data),
		.o_data(data1),
//		.o_ir(o_ir1),
		.o_out(o_out1)
		);

endmodule

// ��ʱ��ģ��
module cnt(
	i_clk,
	i_timer_clk,
	i_rstn,
	i_we,
	i_re,
	i_op,
//	i_inta,
	i_data,
	o_data,
//	o_ir,
	o_out
	);
	
	/////////////////////////////////////////////////////////////////////////////
	// ÿ����ʱ�����������ĸ��Ĵ��� ���弰��ַ����
	// opȡ��ַ��[3:2]
	// ��ʽ�Ĵ���	op:00	reg[15:2] ����	reg[1] �ظ�/���ظ�	reg[0] ��ʱ/����
	// ״̬�Ĵ���	op:01	reg[15] ��Ч/��Ч	reg[14:2] ����	reg[1] ������	reg[0] ��ʱ��
	// ��ʼֵ�Ĵ���	op:10	��ʱ/������ʼֵ
	// ��ǰֵ�Ĵ���	op:11	��ʱ/������ǰֵ
	/////////////////////////////////////////////////////////////////////////////

	input	i_clk;
	input	i_timer_clk;
	input	i_rstn;
	input	i_we;
	input	i_re;
//	input	i_inta;
	
	input	[ 1:0] i_op;
	input	[15:0] i_data;
	
	// output	reg [15:0] o_data;
	output	[15:0] o_data;

	output	o_out;
//	output	reg o_ir;
	
//	reg		r_ontimer;
	
	reg		[15:0] count;	// ����ֵ
	
	reg		[ 1:0] state;	// д״̬ [00] Ĭ�� [01]д�˷�ʽ�� [10]д�˳�ʼֵ ��ʱ�������ڹ���

	reg		read_status;	// ��status  ����read_reset��һ�����ڵ��ӳ�
	reg		read_reset;		// ��status�� status�Ĵ�������
	
	reg		start;			// д��ʼ�ֺ�״̬ ��ʱ ������ʼ
	reg		get_first;		// ��ʱ�� �����Ĵ�������˵�һ������ֵ

	wire	[15:0] way;
	wire	[15:0] status;
	wire	[15:0] ini_val;
	wire	[15:0] now_val;
	
	wire	way_we, ini_we, sta_re, now_re;
	wire	is_count, is_repeat;

	wire	first_count;	// д��ʼֵ��ĵ�һ�μ���

	wire	count_valid;	// �Ƿ���Ч
	wire	on_timer;		// ��ʱ��
	wire	on_count;		// ������

	// ��ʽ�Ĵ��� ��ʼֵ�Ĵ��� дʹ��
	assign	way_we = i_we & !i_op;
	assign	ini_we = i_we & i_op[1] & ~i_op[0];
	
	// ״̬�Ĵ��� ��ǰֵ�Ĵ��� ��ʹ��	
	assign 	sta_re = i_re & ~i_op[1] & i_op[0];
	assign 	now_re = i_re & i_op[1] & i_op[0];

	assign	is_count	= way[0];
	assign	is_repeat	= way[1];

	// ��д�˳�ʼֵ �Լ���ʱ����������ʱ��Ч
	// ��״̬�Ĵ�������Ч
	assign	count_valid = read_reset ? 1'b0 : state[1];

	// ��ʱ �������ʱ���ź�
	assign	on_timer = count_valid & ~is_count & count == 1;
	assign	on_count = count_valid & is_count & count == 0;

	// ��ʱ��1ʱ���һ��ʱ�ӵĵ͵�ƽ
	assign	o_out = on_timer ? 1'b0 : 1'b1;

	assign	first_count = state[1] & ~state[0] | start & ~get_first;

	// // ѡ����ȷ��������
	// always @(posedge i_clk or negedge i_rstn) begin
	// 	if (~i_rstn) begin
	// 		// reset
	// 		o_data	<= 0;
	// 	end
	// 	else if (sta_re) begin
	// 		o_data	<= status;
	// 	end
	// 	else if (now_re) begin
	// 		o_data	<= now_val;
	// 	end
	// 	else begin
	// 		o_data	<= 0;
	// 	end
	// end
	
	// // �Զ�ʱ�����½����źŽ��д���
	// always @(posedge o_out or negedge o_out) begin
	// 	if (o_out)
	// 		r_ontimer	<= 1'b1;
	// 	else
	// 		r_ontimer	<= 1'b0;
	// end
	
	// // ��ʱ���½��ز����ж������ź�
	// always @(negedge i_clk or posedge i_rstn) begin
	// 	if (~i_rstn) begin
	// 		// reset
	// 		o_ir	<= 1'b0;
	// 	end
	// 	// ��ʱ��������ʱ���ź�
	// 	else begin 
	// 		if (i_inta) begin
	// 			o_ir	<= 1'b0;
	// 		end
	// 		else if (r_ontimer) begin
	// 			o_ir	<= 1'b1;
	// 		end
			
	// 	end
	// end

	mux4in1 #(.WIDTH(16)) OUT_OP(
		.i_data0(way),
		.i_data1(status),
		.i_data2(ini_val),
		.i_data3(now_val),
		.i_ctrl(i_op),
		.o_data(o_data)
		);

	// ��ʽ�Ĵ���
	dffe16	WAY_REG(
		.i_clk(~i_clk),
		.i_rstn(i_rstn),
		.i_we(way_we),
		.i_data(i_data),
		.o_data(way)
		);

	// ����״̬�Ĵ������������ź�
	always @(posedge i_clk or negedge i_rstn) begin
		if (~i_rstn) begin
			// reset
			read_reset	<= 1'b0;
			read_status	<= 1'b0;
		end
		else if (sta_re) begin
			read_status	<= 1'b1;
			read_reset	<= read_status;
		end
		else begin
			read_status	<= 1'b0;
			read_reset	<= read_status;
		end
	end
	
	// ״̬�Ĵ���
	// ֻ�� ��������
	// ״̬�Ĵ������ֵ
	assign	status = {count_valid, 13'b0, on_count, on_timer};
	// always @(posedge i_clk or negedge i_rstn) begin
	// 	if (~i_rstn) begin
	// 		// reset
	// 		status		<= 0;
	// 		status_read	<= 0;
	// 	end
	// 	else begin
	// 		status		<= i_re & ~i_op[1] & i_op[0] 
	// 					? 0 : {count_valid, 13'b0, on_count, on_timer};
	// 		status_read	<= status;
	// 	end
	// end
	// dffe16	STA_REG(
	// 	.i_clk(i_clk),
	// 	.i_rstn(i_rstn),
	// 	.i_we(1'b1),
	// 	.i_data({count_valid, 13'b0, on_count, on_timer}),
	// 	.o_data(status)
	// 	);

	// ��ʼֵ�Ĵ��� ֻд
	dffe16	INI_REG(
		.i_clk(~i_clk),
		.i_rstn(i_rstn),
		.i_we(ini_we),
		.i_data(i_data),
		.o_data(ini_val)
		);
	
	// ��ǰֵ�Ĵ��� ֻ��
	assign	now_val = first_count ? ini_val : count;
	// dffe16	NOW_REG(
	// 	.i_clk(i_clk),
	// 	.i_rstn(i_rstn),
	// 	.i_we(1'b1),
	// 	.i_data(count),
	// 	.o_data(now_val)
	// 	);

	// ��д��ʽ�� ��д��ʼֵ ֮������ſ�ʼ
	always @(posedge ~i_clk or negedge i_rstn) begin
		if (~i_rstn) begin
			state		<= 2'b00;
		end 
		else begin
			case(state)
				2'b00:	state	<= way_we ? 2'b01 : 2'b00;
				2'b01:	state	<= ini_we ? 2'b10 : 2'b01;
				2'b10:	state	<= ini_we ? 2'b10 : 2'b11;
				2'b11:	state	<= way_we ? 2'b01 : 
								   (ini_we ? 2'b10 : 
								   (read_reset ? 2'b00 : 2'b11));
			endcase
		end
	end
	// д��ʼֵ��ĵ�һ�����������ж�
	always @(posedge ~i_clk or negedge i_rstn) begin
		if (~i_rstn) begin
			start	<= 1'b0;
		end 
		else begin
			if (state == 2'b10) begin
				start	<= 1'b1;
			end
			else if(get_first) begin
				start	<= 1'b0;
			end
		end	
	end
	
	// ���� ��ʱ
	always @(posedge i_timer_clk or negedge i_rstn) begin
		if (~i_rstn) begin
			// reset
			count		<= 0;
			get_first	<= 0;
		end
		else if (first_count) begin
//		else if (ini_we) begin
				count	<= ini_val-1;		// ��ʼֵ��1��������Ĵ���
				get_first	<= 1'b1;
		end 
		else if (count_valid) begin
			get_first	<= 1'b0;			// �Ѿ�ȡ�ó�ʼ����ֵ��ʼ����
			if (!count) begin
				if (is_repeat)
					count	<= ini_val;		// ������� �����ظ����� �����¼���
			end
			else begin
				count	<= count - 1;		// ���� ����ֵ��1
			end
		end
	end
endmodule