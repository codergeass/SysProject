`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/30 10:45:00
// Design Name: 
// Module Name: pwm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// PWM
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pwm(
	i_clk,
	i_rstn,
	i_we,
	i_re,
	i_op,
	i_data,
	o_data,
	o_out
	);

	input	i_clk;
	input	i_rstn;
	input	i_we;
	input	i_re;	
	
	input	[ 1:0] i_op;
	input	[15:0] i_data;
	
	output	[15:0] o_data;

	output	reg o_out;

	reg		[15:0] count;
	// reg		[ 1:0] read_which;	// ¶Á¼Ä´æÆ÷Ñ¡ÔñËø´æ

	wire	max_we, ratio_we, ctrl_we, max_re, ratio_re, ctrl_re;
	wire	[15:0] max_data, ratio_data, ctrl_data;

	assign	max_we	 = i_we & !i_op;
	assign	ratio_we = i_we & ~i_op[1] & i_op[0];
	assign	ctrl_we	 = i_we & i_op[1] & ~i_op[0];
	
	// assign	max_re	 = i_re & !i_op;
	// assign	ratio_re = i_re & ~i_op[1] & i_op[0];
	// assign	ctrl_re	 = i_re & i_op[1] & ~i_op[0];

	// // ¶Á¼Ä´æÆ÷Ñ¡ÔñÐÅºÅËø´æ
	// always @(posedge i_clk or negedge i_rstn) begin
	// 	if (~i_rstn) begin
	// 		// reset
	// 		read_which	<= 2'b11;
	// 	end
	// 	else if (max_re) begin
	// 		read_which	<= 2'b00;
	// 	end
	// 	else if (ratio_re) begin
	// 		read_which	<= 2'b01;
	// 	end
	// 	else if (ctrl_re) begin
	// 		read_which	<= 2'b10;
	// 	end
	// 	else begin
	// 		read_which	<= 2'b11;
	// 	end
	// end

	mux4in1 #(.WIDTH(16)) OUT_OP(
		.i_data0(max_data),
		.i_data1(ratio_data),
		.i_data2(ctrl_data),
		.i_data3(16'b0),
		.i_ctrl(i_op),
		.o_data(o_data)
		);

	// ×î´óÖµ¼Ä´æÆ÷
	dffe16	MAX_REG(
		.i_clk(~i_clk),
		.i_rstn(i_rstn),
		.i_we(max_we),
		.i_data(i_data),
		.o_data(max_data)
		);

	// ¶Ô±ÈÖµ¼Ä´æÆ÷
	dffe16	RATIO_REG(
		.i_clk(~i_clk),
		.i_rstn(i_rstn),
		.i_we(ratio_we),
		.i_data(i_data),
		.o_data(ratio_data)
		);

	// ¿ØÖÆ×Ö¼Ä´æÆ÷
	dffe16	CTRL_REG(
		.i_clk(~i_clk),
		.i_rstn(i_rstn),
		.i_we(ctrl_we),
		.i_data(i_data),
		.o_data(ctrl_data)
		);

	// Âö³å¼ÆÊý ¿í¶Èµ÷ÖÆ
	always @(posedge i_clk or negedge i_rstn) begin
		if (~i_rstn) begin
			// reset
			count	<= 0;
			o_out	<= 1'b1;	
		end
		else if (ctrl_data[0]) begin
			if (count >= max_data) begin
				count	<= 0;
				o_out	<= 1'b1;
			end
			else begin
				count	<= count + 1;
				if (count >= ratio_data) begin
					o_out	<= 1'b0;
				end else begin
					o_out	<= 1'b1;
				end
			end
		end
		else begin
			o_out	<= 1'b1;
		end
		
	end
endmodule
