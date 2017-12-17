`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/31 15:35:28
// Design Name: 
// Module Name: minisys_sim
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module minisys_sim(
	);
	reg		i_clk = 0;				// �Ӱ�ʱ��100MHz  E3
	reg		i_rstn = 0;				// �Ӱ�͵�ƽ��λ  C12
	
	reg		[15:0] i_switch = 0;	// ���뿪������ӿ�
	reg		[ 3:0] i_col = 0;
	wire	[ 3:0] o_row = 0;		// 4*4���̽ӿ�
	
	wire	[ 7:0] o_digit;			// ���������ӿ�
	wire	[ 7:0] o_digit_en;
	wire	[15:0] o_led;			// o_led������ӿ�
	
//	wire	o_pwm;					// PWM����ӿ�

	minisys MINISYS_TEST(
		.i_clk(i_clk),
		.i_rstn(i_rstn),
		.i_switch(i_switch),
		.i_col(i_col),
		.o_row(o_row),
		.o_digit(o_digit),
		.o_digit_en(o_digit_en),
		.o_led(o_led)
//		.o_pwm(o_pwm)
		);
		
	initial begin
		#20 i_rstn = 1'b1; i_col = 4'b1111;
		#5000 i_col = 4'b1110;
		#20 i_col = 4'b1111;
	end
	
	always #5 i_clk = ~i_clk;
endmodule
