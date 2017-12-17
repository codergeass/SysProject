`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/20 13:49:43
// Design Name: 
// Module Name: alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 算术逻辑单元
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu(
	i_src1,
	i_src2,
	i_alu_ctrl,
	o_result,
	o_overflow
	);
	
	//运算方式标识
	localparam F_AND = 6'b100100, F_OR   = 6'b100101;
	localparam F_NOR = 6'b100111, F_XOR  = 6'b100110;
	localparam F_ADD = 6'b100000, F_ADDU = 6'b100001;
	localparam F_SUB = 6'b100010, F_SUBU = 6'b100011;
	localparam F_SLT = 6'b101010, F_SLTU = 6'b101011;
	localparam F_SRL = 6'b000010, F_SRLV = 6'b000110;
	localparam F_SLL = 6'b000000, F_SLLV = 6'b000100;
	localparam F_SRA = 6'b000011, F_SRAV = 6'b000111;
	localparam F_LUI = 6'b111100;

	input	[31:0] i_src1, i_src2;
	input	[ 5:0] i_alu_ctrl;
	
	output	reg [31:0] o_result;
	output	reg o_overflow;

	reg	extra;	// 进位

	always @(*) begin
		o_overflow = 1'b0;
		
		case(i_alu_ctrl)
			F_AND:	o_result = i_src1 & i_src2;
			F_OR:	o_result = i_src1 | i_src2;
			F_ADD: 
				begin
					{extra, o_result} = {i_src1[31], i_src1} + {i_src2[31], i_src2};
					o_overflow = (({extra, o_result[31]} == 2'b01) | ({extra, o_result[31]} == 2'b10));
					// 没有直接用extra != o_result[31]
				end
			F_ADDU:	o_result = i_src1 + i_src2;
			F_SUB: 
				begin
					{extra, o_result} = {i_src1[31], i_src1} - {i_src2[31], i_src2};
					o_overflow = (({extra, o_result[31]} == 2'b01) | ({extra, o_result[31]} == 2'b10));
					// 没有直接用extra != o_result[31]
				end
			F_SUBU:	o_result = i_src1 - i_src2;
			F_SLT:	o_result = $signed(i_src1) < $signed(i_src2) ? 1 : 0;
			F_SLTU:	o_result = i_src1 < i_src2 ? 1 : 0;
			F_NOR:	o_result =~( i_src1 | i_src2 );
			F_LUI:	o_result = { i_src2 , 16'b0};
			F_XOR:	o_result = i_src1 ^ i_src2;
			F_SLLV,
			F_SLL:	o_result = i_src2 << i_src1;
			F_SRLV,
			F_SRL:	o_result = i_src2 >> i_src1;
			F_SRAV,
			F_SRA:	o_result = $signed(i_src2) >>> i_src1;
			default:	o_result = 32'b0;
		endcase
	end

endmodule
