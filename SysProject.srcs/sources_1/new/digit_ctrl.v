`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/29 10:42:06
// Design Name: 
// Module Name: digit_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 数码管控制器
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module digit_ctrl(
	i_clk,
	i_rstn,
	i_we,
	i_re,
	i_op,
	i_data,
	o_data,
	o_digit,
	o_digit_en
	);
	
	input	i_clk;
	input	i_rstn;
	input	i_we;				// 写使能
	input	i_re;				// 读使能

	input	[ 1:0] i_op;			// 寄存器选择 使用地址线[2:1]
								// [00] LO_DIGIT		低四位数码管数据	(0xfffffc00)
								// [01] HI_DIGIT		高四位数码管数据	(0xfffffc02)
								// [1x] VIEW_WAY		显示方式			(0xfffffc04)
								// [15:8] 数据是否显示  [7:0] 小数点是否显示
	
	input	[15:0] i_data;		// 写数据
	
	output	[15:0] o_data;		// 读数据
	
	output	[ 7:0] o_digit;		// 接数码管信号 o_digit[0] 小数点
	output	[ 7:0] o_digit_en;	// 接数码管显示使能信号

	wire	lo_we, hi_we, way_we;
	// wire	lo_re, hi_re, way_re;
	wire	[15:0] lo_data, hi_data, way_data;
	// reg		[15:0] lo_data, hi_data, way_data;
	// reg		[ 1:0] read_which;	// 读寄存器选择锁存
	// wire	[ 1:0] read_which;	// 读寄存器选择
	
	assign lo_we = i_we & !i_op;
	assign hi_we = i_we & i_op[0] & ~i_op[1];
	assign way_we = i_we & i_op[1];

	// assign lo_re = i_re & !i_op;
	// assign hi_re = i_re & i_op[0] & ~i_op[1];
	// assign way_re = i_re & i_op[1];

	// assign read_which = ;
	
	// // 读寄存器选择信号锁存
	// always @(posedge i_clk or negedge i_rstn) begin
	// 	if (~i_rstn) begin
	// 		// reset
	// 		read_which	<= 2'b11;
	// 	end
	// 	else if (lo_re) begin
	// 		read_which	<= 2'b00;
	// 	end
	// 	else if (hi_re) begin
	// 		read_which	<= 2'b01;
	// 	end
	// 	else if (way_re) begin
	// 		read_which	<= 2'b10;
	// 	end
	// 	else begin
	// 		read_which	<= 2'b11;
	// 	end
	// end

	// 读出数据
	// always @(posedge i_clk or negedge i_rstn) begin
	// 	if (~i_rstn) begin
	// 		// reset
	// 		o_data	<= 0;
	// 	end
	// 	else if (lo_re) begin
	// 		o_data	<= lo_data;
	// 	end
	// 	else if (hi_re) begin
	// 		o_data	<= hi_data;
	// 	end
	// 	else if (way_re) begin
	// 		o_data	<= way_data;
	// 	end
	// 	else begin
	// 		o_data	<= 0;
	// 	end
	// end

	// 写数据
	// 使用阻塞式赋值 保证读出数据和寄存器数据一致
	// always @(posedge i_clk or negedge i_rstn) begin
	// 	if (~i_rstn) begin
	// 		// reset
	// 		lo_data		= 0;
	// 		hi_data		= 0;
	// 		way_data	= 0;
	// 	end
	// 	else if (lo_we) begin
	// 		lo_data		= i_data;
	// 	end
	// 	else if (hi_we) begin
	// 		hi_data		= i_data;
	// 	end
	// 	else if (way_we) begin
	// 		way_data	= i_data;
	// 	end
	// end

	mux4in1 #(.WIDTH(16)) OUT_OP(
		.i_data0(lo_data),
		.i_data1(hi_data),
		.i_data2(way_data),
		.i_data3(16'b0),
		.i_ctrl(i_op),
		.o_data(o_data)
		);

	// 数码管低四位数据寄存器
	dffe16	LO_DIGIT(
		.i_clk(~i_clk),
		.i_rstn(i_rstn),
		.i_we(lo_we),
		.i_data(i_data),
		.o_data(lo_data)
		);
	
	// 数码管高四位数据寄存器
	dffe16	HI_DIGIT(
		.i_clk(~i_clk),
		.i_rstn(i_rstn),
		.i_we(hi_we),
		.i_data(i_data),
		.o_data(hi_data)
		);
	
	// 显示方式寄存器
	dffe16	VIEW_WAY(
		.i_clk(~i_clk),
		.i_rstn(i_rstn),
		.i_we(way_we),
		.i_data(i_data),
		.o_data(way_data)
		);

	// 数码管显示控制
	digit_view DIGIT_VIEW(
		.i_clk(i_clk),
		.i_rstn(i_rstn),
		.i_enable(way_data[15:8]),
		.i_dp_enable(way_data[7:0]),
		.i_data0(lo_data[ 3:0 ]),
		.i_data1(lo_data[ 7:4 ]),
		.i_data2(lo_data[11:8 ]),
		.i_data3(lo_data[15:12]),
		.i_data4(hi_data[ 3:0 ]),
		.i_data5(hi_data[ 7:4 ]),
		.i_data6(hi_data[11:8 ]),
		.i_data7(hi_data[15:12]),
		.o_digit(o_digit),
		.o_digit_en(o_digit_en)
	);
endmodule
