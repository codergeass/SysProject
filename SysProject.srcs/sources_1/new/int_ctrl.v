`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/22 20:47:10
// Design Name: 
// Module Name: int_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 中断控制器 六个中断请求信号
// 优先级 0>1>2>3>4>5
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module int_ctrl(
	i_clk,
	i_rstn,
	i_inta,
	i_int_source,
	i_ir0,
	i_ir1,
	i_ir2,
	i_ir3,
	i_ir4,
	i_ir5,
	o_inta0,
	o_inta1,
	o_inta2,
	o_inta3,
	o_inta4,
	o_inta5,
	o_intr,
	o_int_source
	);

	input	i_clk;
	input	i_rstn;
	
	input	i_inta;					// cpu中断响应信号
	input	[5:0] i_int_source;		// cpu加上屏蔽位后的中断源
	
	input	i_ir0;					// 中断请求源
	input	i_ir1;
	input	i_ir2;
	input	i_ir3;
	input	i_ir4;
	input	i_ir5;
	
	output	reg o_inta0 = 0;			// 对每个中断请求源的中断响应
	output	reg o_inta1 = 0;
	output	reg o_inta2 = 0;
	output	reg o_inta3 = 0;
	output	reg o_inta4 = 0;
	output	reg o_inta5 = 0;

	output	reg o_intr;				// 对cpu的中断请求
	
	output	reg [5:0] o_int_source;	// 对cpu的中断源描述

	reg	[5:0] intr_reg = 0;			// 对外设中断请求信号进行锁存

	// wire intr;
	// assign intr = (|o_int_source);

	// assign	o_inta0 = i_inta & i_int_source[0];
	// assign	o_inta1 = i_inta & i_int_source[1];
	// assign	o_inta2 = i_inta & i_int_source[2];
	// assign	o_inta3 = i_inta & i_int_source[3];
	// assign	o_inta4 = i_inta & i_int_source[4];
	// assign	o_inta5 = i_inta & i_int_source[5];

	// 对中断请求信号进行触发
	always @(posedge i_ir0 or negedge i_ir0 or posedge i_inta) begin
		if (i_inta & i_int_source[0]) begin
			intr_reg[0]	<= 1'b0;
		end
		else begin
			if (i_ir0)
				intr_reg[0]	<= 1'b1;
			else
				intr_reg[0]	<= 1'b0;
		end
	end
	always @(posedge i_ir1 or negedge i_ir1 or posedge i_inta) begin
		if (i_inta & i_int_source[1]) begin
			intr_reg[1]	<= 1'b0;
		end
		else begin
			if (i_ir1)
				intr_reg[1]	<= 1'b1;
			else
				intr_reg[1]	<= 1'b0;
		end
	end
	always @(posedge i_ir2 or negedge i_ir2 or posedge i_inta) begin
		if (i_inta & i_int_source[2]) begin
			intr_reg[2]	<= 1'b0;
		end
		else begin
			if (i_ir2)
				intr_reg[2]	<= 1'b1;
			else
				intr_reg[2]	<= 1'b0;
		end
	end
	always @(posedge i_ir3 or negedge i_ir3 or posedge i_inta) begin
		if (i_inta & i_int_source[3]) begin
			intr_reg[3]	<= 1'b0;
		end
		else if (i_ir3)
			intr_reg[3]	<= 1'b1;
		else
			intr_reg[3]	<= 1'b0;
	end
	always @(posedge i_ir4 or negedge i_ir4 or posedge i_inta) begin
		if (i_inta & i_int_source[4]) begin
			intr_reg[4]	<= 1'b0;
		end
		else if (i_ir4)
			intr_reg[4]	<= 1'b1;
		else
			intr_reg[4]	<= 1'b0;
	end
	always @(posedge i_ir5 or negedge i_ir5 or posedge i_inta) begin
		if (i_inta & i_int_source[5]) begin
			intr_reg[5]	<= 1'b0;
		end
		else if (i_ir5)
			intr_reg[5]	<= 1'b1;
		else
			intr_reg[5]	<= 1'b0;
	end
	
	// 在时钟下降沿产生中断请求信号
	always @(negedge i_clk or posedge i_rstn) begin
		if (~i_rstn) begin
			// reset
			o_intr			<= 1'b0;
			o_int_source	<= 5'b0;
		end
		else begin 
			o_int_source	<= intr_reg;
			if (|intr_reg) begin
				o_intr	<= 1'b1;
			end
			else begin
				o_intr	<= 1'b0;
			end
		end
	end

	// 实现中断优先级的判定
	always @(posedge i_inta or negedge i_inta) begin
		if (i_inta) begin
			case(1'b1)
				i_int_source[0]:	o_inta0	<= 1'b1;
				i_int_source[1]:	o_inta1	<= 1'b1;
				i_int_source[2]:	o_inta2	<= 1'b1;
				i_int_source[3]:	o_inta3	<= 1'b1;
				i_int_source[4]:	o_inta4	<= 1'b1;
				i_int_source[5]:	o_inta5	<= 1'b1;
				default:	;
			endcase
		end
		else begin
			o_inta0	<= 1'b0;
			o_inta1	<= 1'b0;
			o_inta2	<= 1'b0;
			o_inta3	<= 1'b0;
			o_inta4	<= 1'b0;
			o_inta5	<= 1'b0;
		end
		
	end

// 	always @(*) begin
// //		if (~i_rstn) begin
// 			// reset
// 			o_inta0		= 0;
// 			o_inta1		= 0;
// 			o_inta2		= 0;
// 			o_inta3		= 0;
// 			o_inta4		= 0;
// 			o_inta5		= 0;
// 			o_intr		= 0;
// 			o_int_source	= 0;
// //		end
// //		else begin
// 			o_int_source[0]	= i_ir0;
// 			o_int_source[1]	= i_ir1;
// 			o_int_source[2]	= i_ir2;
// 			o_int_source[3]	= i_ir3;
// 			o_int_source[4]	= i_ir4;
// 			o_int_source[5]	= i_ir5;

// 			if (i_inta) begin
// 				if(i_int_source[0]) begin
// 					o_intr	= intr | 1'b0;
// 					o_inta0	= 1'b1;
// 					o_int_source[0]	= 1'b0;
// 				end else if(i_int_source[1]) begin
// 					o_intr	= intr | 1'b0;
// 					o_inta1	= 1'b1;
// 					o_int_source[1]	= 1'b0;
// 				end else if(i_int_source[2]) begin
// 					o_intr	= intr | 1'b0;
// 					o_inta2	= 1'b1;
// 					o_int_source[2]	= 1'b0;
// 				end else if(i_int_source[3]) begin
// 					o_intr	= intr | 1'b0;
// 					o_inta3	= 1'b1;
// 					o_int_source[3]	= 1'b0;
// 				end else if(i_int_source[4]) begin
// 					o_intr	= intr | 1'b0;
// 					o_inta4	= 1'b1;
// 					o_int_source[4]	= 1'b0;
// 				end else if(i_int_source[5]) begin
// 					o_intr	= intr | 1'b0;
// 					o_inta5	= 1'b1;
// 					o_int_source[5]	= 1'b0;
// 				end
// 			end
// //		end
// 	end

endmodule
