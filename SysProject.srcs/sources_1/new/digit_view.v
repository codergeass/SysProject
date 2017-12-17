`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/29 10:42:06
// Design Name: 
// Module Name: digit_view
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// �������ʾ������
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module digit_view(
	i_clk,
	i_rstn,	
	i_enable,
	i_dp_enable,
	i_data0,
	i_data1,
	i_data2,
	i_data3,
	i_data4,
	i_data5,
	i_data6,
	i_data7,
	o_digit,
	o_digit_en
	);
	
	input	i_clk;
	input	i_rstn;
	
	input	[7:0] i_enable;			// �Ƿ���ʾ
	input	[7:0] i_dp_enable;		// С�����Ƿ���ʾ
	input	[3:0] i_data0;			// �������ʾ����
	input	[3:0] i_data1;
	input	[3:0] i_data2;
	input	[3:0] i_data3;
	input	[3:0] i_data4;
	input	[3:0] i_data5;
	input	[3:0] i_data6;
	input	[3:0] i_data7;
	
	output	[7:0] o_digit_en;		// �������ʹ���ź�
	output	[7:0] o_digit;			// ��������ź�

	wire	[14:0] cnt15;
	wire	[ 2:0] cnt_sel;
	wire	[ 7:0] en0, en1, en2, en3, en4, en5, en6, en7;
	wire	[ 3:0] num_out;

	wire	dp_en;					// С������ʾ�ź�

	assign en0 = (~i_enable | 8'hfe);
	assign en1 = (~i_enable | 8'hfd);
	assign en2 = (~i_enable | 8'hfb);
	assign en3 = (~i_enable | 8'hf7);
	assign en4 = (~i_enable | 8'hef);
	assign en5 = (~i_enable | 8'hdf);
	assign en6 = (~i_enable | 8'hbf);
	assign en7 = (~i_enable | 8'h7f);

	// ����������ʾ�ź�
	digit_out DIGIT_OUT(
		.i_data(num_out),
		.i_enable(1'b1),
		.i_dp_enable(dp_en),
		.o_digit(o_digit)
		);

	counter #(.WIDTH(15)) COUNTER15(i_clk, i_rstn, cnt15);
	counter #(.WIDTH(3))  COUNTER_SEL(cnt15[14], i_rstn, cnt_sel);
	
	mux8in1 #(.WIDTH(8)) SEG_EN_OP(
		en0, en1, en2, en3, en4, en5, en6, en7,
		cnt_sel, o_digit_en);
	mux8in1 #(.WIDTH(1)) DP_EN_OP(
		i_dp_enable[0], i_dp_enable[1], i_dp_enable[2], i_dp_enable[3],
		i_dp_enable[4], i_dp_enable[5], i_dp_enable[6], i_dp_enable[7],
		cnt_sel, dp_en);
	mux8in1 #(.WIDTH(4)) SEG_VAL_OP(
		i_data0, i_data1, i_data2, i_data3, 
		i_data4, i_data5, i_data6, i_data7,
		cnt_sel, num_out);

endmodule



// �������ʾ���
module digit_out(
	i_data,
	i_enable,
	i_dp_enable,
	o_digit
	);
	
	input	i_enable, i_dp_enable;	// ��ʾʹ�� С������ʾʹ��
	input	[3:0] i_data;			// ��������

	output	reg [7:0] o_digit;		// ����������ʾ�ź�

	always @(*) begin
		if (~i_enable) begin
			// reset
			o_digit = 8'b1111_1111; 
		end
		else begin
			if (i_dp_enable) begin
				o_digit[0] = 1'b0;
			end
			else begin
				o_digit[0] = 1'b1;
			end
			case (i_data)
				4'b0000:	o_digit[7:1] = 7'b0000_001;
				4'b0001:	o_digit[7:1] = 7'b1001_111;
				4'b0010:	o_digit[7:1] = 7'b0010_010;
				4'b0011:	o_digit[7:1] = 7'b0000_110;
				4'b0100:	o_digit[7:1] = 7'b1001_100;
				4'b0101:	o_digit[7:1] = 7'b0100_100;
				4'b0110:	o_digit[7:1] = 7'b0100_000;
				4'b0111:	o_digit[7:1] = 7'b0001_111;
				4'b1000:	o_digit[7:1] = 7'b0000_000;
				4'b1001:	o_digit[7:1] = 7'b0000_100;
				4'b1010:	o_digit[7:1] = 7'b0001_000;
				4'b1011:	o_digit[7:1] = 7'b1100_000;
				4'b1100:	o_digit[7:1] = 7'b0110_001;
				4'b1101:	o_digit[7:1] = 7'b1000_010;
				4'b1110:	o_digit[7:1] = 7'b0110_000;
				4'b1111:	o_digit[7:1] = 7'b0111_000;
				default:	o_digit[7:1] = 7'bxxxx_xxx;
			endcase
		end
	end
endmodule
