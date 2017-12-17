`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/30 10:37:53
// Design Name: 
// Module Name: interface_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 接口控制部件
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module interface_ctrl(
//	i_clk,
	i_ioclk,
	i_rstn,
	i_we,
	i_re,
	i_addr,
	i_data,
	i_inta,
	i_int_source,
	i_switch,
	i_col,
	o_row,
	o_digit,
	o_digit_en,
	o_led,
	o_pwm,
	o_data,
	o_reset,
	o_intr,
	o_int_source
	);

//	input	i_clk;			// 板上100MHz 用于接口部件
	input	i_ioclk;		// 同CPU时钟
	input	i_rstn;
	input	i_we;
	input	i_re;
	input	i_inta;
	
	input	[ 7:0] i_addr;
	input	[15:0] i_data;
	input	[ 5:0] i_int_source;
	
	// 拨码开关输入接口
	input	[15:0] i_switch;
	
	// 4*4键盘接口
	input	[ 3:0] i_col;
	output	[ 3:0] o_row;

	// 数码管输出接口
	output	[ 7:0] o_digit;
	output	[ 7:0] o_digit_en;
	
	// o_led灯输出接口
	output	[15:0] o_led;
	
	// PWM输出接口
	output	o_pwm;

	output	o_reset;
	
	output	o_intr;
	
	output	[15:0] o_data;
	output	[ 5:0] o_int_source;

	// 各接口部件片选信号
	wire	digit_cs, keypad_cs, timer_cs, pwm_cs, watchdog_cs, led_cs, switch_cs;
	// 各接口部件写使能
	wire	digit_we, timer_we, pwm_we, watchdog_we, led_we;
	// 各接口部件读使能
	wire	digit_re, keypad_re, timer_re, pwm_re, switch_re;
	// 各接口部件中断请求线
	wire	keypad_ir, timer_ir0, timer_ir1;
	// 各接口部件中断应答线
	wire	timer_ia0, timer_ia1, keypad_ia;
	// 各接口输出数据
	wire	[15:0] digit_data, keypad_data, timer_data, pwm_data, switch_data;
	wire	timer_out0, timer_out1, pwm_out;
	
	assign	timer_ir0 = ~timer_out0;
	assign	timer_ir1 = ~timer_out1;
	
	assign	digit_cs	= !i_addr[7:4];
	assign	keypad_cs	= !i_addr[7:5] & i_addr[4];
	assign	timer_cs	= !i_addr[7:6] & i_addr[5] & ~i_addr[4];
	assign	pwm_cs		= !i_addr[7:6] & i_addr[5] & i_addr[4];
	assign	watchdog_cs	= ~i_addr[7] & i_addr[6] & ~i_addr[5] & i_addr[4];
	assign	led_cs		= ~i_addr[7] & i_addr[6] & i_addr[5] & ~i_addr[4];
	assign	switch_cs	= ~i_addr[7] & i_addr[6] & i_addr[5] & i_addr[4];

	assign	digit_we	= i_we & digit_cs;
	assign	timer_we	= i_we & timer_cs;
	assign	pwm_we		= i_we & pwm_cs;
	assign	watchdog_we	= i_we & watchdog_cs;
	assign	led_we		= i_we & led_cs;

	assign	digit_re	= i_re & digit_cs;
	assign	keypad_re	= i_re & keypad_cs;
	assign	timer_re	= i_re & timer_cs;
	assign	pwm_re		= i_re & pwm_cs;
	assign	switch_re	= i_re & switch_cs;

	assign	o_pwm = pwm_out;

	// 输出数据选择
	mux8in1 #(.WIDTH(16)) DATA_OP(
		.i_data0(digit_data),
		.i_data1(keypad_data),
		.i_data2(timer_data),
		.i_data3(pwm_data),
		.i_data4(16'b0),
		.i_data5(16'b0),
		.i_data6(16'b0),
		.i_data7(switch_data),
		.i_ctrl(i_addr[6:4]),
		.o_data(o_data)
		);

	// 中断控制器
	int_ctrl INT_CTRL(
		.i_clk(i_ioclk),
		.i_rstn(i_rstn),
		.i_inta(i_inta),
		.i_int_source(i_int_source),
		.i_ir0(1'b0),
		.i_ir1(1'b0),
		.i_ir2(1'b0),
//		.i_ir3(keypad_ir),
		.i_ir3(1'b0),
		.i_ir4(timer_ir0),
		.i_ir5(timer_ir1),
		.o_inta0(),
		.o_inta1(),
		.o_inta2(),
		.o_inta3(keypad_ia),
		.o_inta4(timer_ia0),
		.o_inta5(timer_ia1),
		.o_intr(o_intr),
		.o_int_source(o_int_source)
		);

	// 数码管控制器 0xfffffc00
	digit_ctrl DIGIT_CTRL(
		.i_clk(i_ioclk),
		.i_rstn(i_rstn),
		.i_we(digit_we),
		.i_re(digit_re),
		.i_op(i_addr[2:1]),
		.i_data(i_data),
		.o_data(digit_data),
		.o_digit(o_digit),
		.o_digit_en(o_digit_en)
		);
	
	// 4x4键盘控制器 0xfffffc10
	keypad_ctrl KEYPAD_CTRL(
		.i_clk(i_ioclk),
//		.i_scanclk(i_clk),
		.i_rstn(i_rstn),
		.i_re(keypad_re),
		.i_op(i_addr[1]),
		.i_inta(keypad_ia),
		.i_col(i_col),
		.o_row(o_row),
		.o_ir(keypad_ir),
		.o_data(keypad_data)
		);
		
	// 定时器 0xfffffc20
	timer TIMER(
		.i_clk(i_ioclk),
		.i_rstn(i_rstn),
		.i_we(timer_we),
		.i_re(timer_re),
		.i_op(i_addr[3:1]),
		.i_data(i_data),
//		.i_inta0(timer_ia0),
//		.i_inta1(timer_ia1),
		.o_data(timer_data),
//		.o_ir0(timer_ir0),
//		.o_ir1(timer_ir1),
		.o_out0(timer_out0),
		.o_out1(timer_out1)
		);
	
	// PWM 0xfffffc30
	pwm PWM(
		.i_clk(i_ioclk),
		.i_rstn(i_rstn),
		.i_we(pwm_we),
		.i_re(pwm_re),
		.i_op(i_addr[2:1]),
		.i_data(i_data),
		.o_data(pwm_data),
		.o_out(pwm_out)
		);
	
	// 看门狗 0xfffffc50
	watchdog WATCHDOG(
		.i_clk(i_ioclk),
		.i_rstn(i_rstn),
		.i_we(watchdog_we),
		.i_data(i_data),
		.o_reset(o_reset)
		);
	
	// LED 0xfffffc60
	led_ctrl LED_CTRL(
		.i_clk(i_ioclk),
		.i_rstn(i_rstn),
		.i_we(led_we),
		.i_data(i_data),
		.o_data(o_led)
		);
		
	// 拨码开关 0xfffffc70
	switch_ctrl SWITCH_CTRL(
		.i_clk(i_ioclk),
		.i_re(switch_re),
		.i_data(i_switch),
		.o_data(switch_data)
		);
endmodule
