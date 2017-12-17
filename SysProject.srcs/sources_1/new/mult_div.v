`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/26 10:54:21
// Design Name: 
// Module Name: mult_div
// Project Name:  
// Target Devices: 
// Tool Versions: 
// Description: 
// 乘除法器
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mult_div(
	i_clk,
	i_rstn,
	i_cancel,
	i_divide,
	i_sign,
	i_start,
	i_data0,
	i_data1,
	o_ready,
	o_busy,
	o_result
	);

	input	i_clk;
	input	i_rstn;
	input	i_cancel;
	input	i_divide;
	input	i_sign;
	input	i_start;
	
	input	[31:0] i_data0;
	input	[31:0] i_data1;
	
	output	o_ready;
	output	reg o_busy;
	
	output	[63:0] o_result;

//	wire	[31:0] abs_data0;
//	wire	[31:0] abs_data1;

	wire	[63:0] mult_result;
	wire	[63:0] div_result;

	wire	mult_ready;
	wire	div_ready;	
//	wire	sign_diff;

//	// 乘法运算完毕计数器 用时五个时钟周期
//	reg		[ 2:0] count;
	reg		r_divide;
//	reg		r_sign;

//	assign sign_diff = i_sign & i_data0[31]^i_data1[31];

//	assign abs_data0 = sign_diff ? ~i_data0+1 : i_data0;
//	assign abs_data1 = sign_diff ? ~i_data1+1 : i_data1;

	assign o_result = r_divide & div_ready ? div_result : mult_result;
	assign o_ready = r_divide ? div_ready : mult_ready;
	// assign mult_ready = !count;

//	// 使用3个时钟周期
//	// 第4个时钟周期输出ready信号
//	mult_32x32 MULT (
//		.CLK(i_clk),
//		.A(abs_data0),
//		.B(abs_data0),
//		.CE(i_start | o_busy),
//		.SCLR(~i_rstn | i_cancel | i_divide),
//		.P(mult_result)
//		);
	
	// 使用5个时钟周期
	// 第一个周期用于锁存输入操作数
	// 第5个时钟周期输出ready信号
	mult_32x32 MULT (
		.i_clk(i_clk),
		.i_rstn(i_rstn),
		.i_cancel(i_cancel | i_divide),
		.i_sign(i_sign),
		.i_start(i_start & ~i_divide),
		.i_data0(i_data0),
		.i_data1(i_data1),
		.o_ready(mult_ready),
		.o_result(mult_result)
		);

	// 使用33个时钟周期
	// 第一个周期用于锁存输入操作数
	// 第34个时钟周期输出ready信号
	div_32x32 DIV (
		.i_clk(i_clk),
		.i_rstn(i_rstn),
		.i_cancel(i_cancel),
		.i_sign(i_sign),
		.i_start(i_start & i_divide),
		.i_data0(i_data0),
		.i_data1(i_data1),
		.o_ready(div_ready),
		.o_quotient(div_result[31:0]),
		.o_remainder(div_result[63:32])
		);

	// 一方面给乘法器进行时钟周期计数 产生ready信号
	// 另一方面产生busy信号供EXE阶段产生写HI LO寄存器信号
	// 并且锁存输入的控制信息 如除法信号 符号信号 供运算完毕时选择正确的输出结果
	always @(posedge i_clk or negedge i_rstn) begin
		if (~i_rstn | i_cancel) begin
			// reset
//			count		<= 0;
			r_divide	<= 0;
//			r_sign		<= 0;
			o_busy		<= 0;
		end else begin
			// if (o_ready & ~i_start) begin
			// 	o_result	<= r_divide ? div_result : (r_sign ? ~mult_result+1 : mult_result);
			// end else 
			if (mult_ready & i_start) begin
//				count		<= 3;
				r_divide	<= i_divide;
//				r_sign		<= sign_diff;
				o_busy		<= 1;
			end
//			else if (~mult_ready) begin
//				count		<= count - 1;
//			end 
			else if (o_ready)begin
				o_busy		<= 0;
				r_divide	<= 0;
			end
		end
	end
endmodule
