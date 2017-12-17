`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/30 20:46:18
// Design Name: 
// Module Name: minisys
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// ϵͳ�����Ŀ�����ļ�
// �����ӿں�CPU 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module minisys(
	i_clk,
	i_rstn,
	i_switch,
	i_col,
	o_row,
	o_digit,
	o_digit_en,
	o_led,
	o_pwm
	);
	
	input	i_clk;				// �Ӱ�ʱ��100MHz  E3
	input	i_rstn;				// �Ӱ�͵�ƽ��λ  C12
	
	input	[15:0] i_switch;	// ���뿪������ӿ�
	input	[ 3:0] i_col;		// 4*4���̽ӿ�
	output	[ 3:0] o_row;

	output	[ 7:0] o_digit;		// ���������ӿ�
	output	[ 7:0] o_digit_en;
	output	[15:0] o_led;		// o_led������ӿ�
	
	output	o_pwm;				// PWM����ӿ�
	
	wire	sys_clk;
	wire	reset;

	wire	interrupt_request;
	wire	interrupt_answer;
	wire	interface_read;
	wire	interface_write;
	
	wire	[ 5:0] interrupt_source_to_cpu;
	wire	[ 5:0] interrupt_source_from_cpu;
	wire	[ 7:0] interface_addr;
	wire	[15:0] interface_read_data;
	wire	[15:0] interface_write_data;

//	// ʱ�ӷ�Ƶ 25MHz
//	clk_div CLK_DIV(
//		.i_clk(i_clk),
//		.i_rstn(i_rstn),	
//		.o_clk(sys_clk)
//		);

	// sys_clk 23MHz
	cpu_clk CLK_DIV(
		.clk_in1(i_clk),
		.clk_out1(sys_clk)
		);

	// CPU
	mips_pipeline CPU(
		.i_clk(sys_clk),
//		.i_clk(i_clk),
		// .i_rstn(i_rstn & reset),	
		.i_rstn(i_rstn),
		.i_interrupt_request(interrupt_request),
		.i_interrupt_source(interrupt_source_to_cpu),
		.i_interface_data(interface_read_data),
		.o_interrupt_answer(interrupt_answer),
		.o_interrupt_source(interrupt_source_from_cpu),
		.o_interface_read(interface_read),
		.o_interface_write(interface_write),
		.o_interface_addr(interface_addr),
		.o_interface_data(interface_write_data)
		);
	
	// �ӿڿ����� ���жϿ�����
	interface_ctrl INTERFACE(
//		.i_clk(i_clk),
		.i_ioclk(sys_clk),
//		.i_ioclk(i_clk),
		.i_rstn(i_rstn),
		.i_we(interface_write),
		.i_re(interface_read),
		.i_addr(interface_addr),
		.i_data(interface_write_data),
		.i_inta(interrupt_answer),
		.i_int_source(interrupt_source_from_cpu),
		.i_switch(i_switch),
		.i_col(i_col),
		.o_row(o_row),
		.o_digit(o_digit),
		.o_digit_en(o_digit_en),
		.o_led(o_led),
		.o_pwm(o_pwm),
		.o_data(interface_read_data),
		.o_reset(reset),
		.o_intr(interrupt_request),
		.o_int_source(interrupt_source_to_cpu)
		);
endmodule
