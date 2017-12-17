`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/20 14:09:10
// Design Name: 
// Module Name: alu_control
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


module alu_control(
	i_op,
	i_rs,
	i_func,
	o_alu_ctrl,
	o_alu_src_op,
	o_mult,
	o_multu,
	o_div,
	o_divu,
	o_mfhi,
	o_mflo,
	o_mthi,
	o_mtlo,
	o_jr,
	o_jalr,
	o_syscall,
	o_break,
	o_eret,
	o_mfc0,
	o_mtc0,
	o_unknown_func
	);
	
	localparam R_TYPE	= 6'b000000;			// R型指令
	localparam OP_ADDI	= 6'b001000, OP_ADDIU	= 6'b001001;
	localparam OP_ANDI	= 6'b001100, OP_ORI		= 6'b001101;
	localparam OP_XORI	= 6'b001110, OP_LUI		= 6'b001111;
	localparam OP_LB	= 6'b100000, OP_LBU		= 6'b100100;
	localparam OP_LH	= 6'b100001, OP_LHU		= 6'b100101;
	localparam OP_SB	= 6'b101000, OP_SH		= 6'b101001;
	localparam OP_LW	= 6'b100011, OP_SW		= 6'b101011;
	localparam OP_BEQ	= 6'b000100, OP_BNE		= 6'b000101;
	localparam OP_BLEZ	= 6'b000110, OP_BGTZ	= 6'b000111;
	localparam OP_MUL_BRANCH = 6'b000001;		// bgez, bltz, bgezal, bltzal	
	localparam OP_SLTI	= 6'b001010, OP_SLTIU	= 6'b001011;
	localparam OP_J		= 6'b000010, OP_JAL		= 6'b000011;
	localparam OP_CP0	= 6'b010000;

	// R型指令func字段部分标识
	localparam F_AND	= 6'b100100, F_OR		= 6'b100101;
	localparam F_NOR	= 6'b100111, F_XOR		= 6'b100110;
	localparam F_ADD	= 6'b100000, F_ADDU		= 6'b100001;
	localparam F_SUB	= 6'b100010, F_SUBU		= 6'b100011;
	localparam F_SLT	= 6'b101010, F_SLTU		= 6'b101011;
	localparam F_SRL	= 6'b000010, F_SRLV		= 6'b000110;
	localparam F_SLL	= 6'b000000, F_SLLV		= 6'b000100;
	localparam F_SRA	= 6'b000011, F_SRAV		= 6'b000111;
	localparam F_LUI	= 6'b111100, F_JR		= 6'b001000;
	localparam F_JALR	= 6'b001001, F_SYSCALL	= 6'b001100;
	localparam F_BREAK	= 6'b001101;
	localparam F_MULT	= 6'b011000, F_MULTU	= 6'b011001;
	localparam F_DIV	= 6'b011010, F_DIVU		= 6'b011011;
	localparam F_MFHI	= 6'b010000, F_MFLO		= 6'b010010;
	localparam F_MTHI	= 6'b010001, F_MTLO		= 6'b010011;

	input [5:0] i_op;				// op字段
	input [4:0] i_rs;				// rs字段
	input [5:0] i_func;				// func字段

	output reg [5:0] o_alu_ctrl;	// ALU运算标识
	output reg o_alu_src_op;		// ALU操作数来源 [0]寄存器数 [1]指令shamt字段
	output reg o_mult;
	output reg o_multu;
	output reg o_div;
	output reg o_divu;
	output reg o_mfhi;
	output reg o_mflo;
	output reg o_mthi;
	output reg o_mtlo;
	output reg o_jr;
	output reg o_jalr;
	output reg o_syscall;
	output reg o_break;
	output reg o_eret;
	output reg o_mfc0;
	output reg o_mtc0;
	output reg o_unknown_func;		// 未实现指令

	// 使用逻辑门描述组合逻辑电路
	// 得到各个信号的表达式更好
	// 暂时先用always和case这样简单处理

	always @(*) begin
		o_alu_src_op	= 1'b0;
		o_mult			= 1'b0;
		o_multu			= 1'b0;
		o_div			= 1'b0;
		o_divu			= 1'b0;
		o_mfhi			= 1'b0;
		o_mflo			= 1'b0;
		o_mthi			= 1'b0;
		o_mtlo			= 1'b0;
		o_jr			= 1'b0;
		o_jalr			= 1'b0;
		o_syscall		= 1'b0;
		o_break			= 1'b0;
		o_eret			= 1'b0;
		o_mfc0			= 1'b0;
		o_mtc0			= 1'b0;
		o_unknown_func	= 1'b0;

		case(i_op)
			OP_ADDIU:	o_alu_ctrl = F_ADDU;
			OP_ADDI,
			OP_LW,
			OP_SW:		o_alu_ctrl = F_ADD;
			OP_BEQ,
			OP_BNE:		o_alu_ctrl = 6'b0;
			R_TYPE:			
			begin
				o_alu_ctrl = i_func;
				case(i_func)
					F_ADD, 
					F_ADDU, 
					F_AND,
					F_OR, 
					F_XOR,
					F_SUB,
					F_SUBU, 
					F_SLT,
					F_SLTU, 
					F_NOR, 
					F_SLLV,
					F_SRLV, 
					F_SRAV:		;
					F_SLL,
					F_SRL, 
					F_SRA:		o_alu_src_op	= 1'b1;
					F_JR:		o_jr			= 1'b1;
					F_JALR:		o_jalr			= 1'b1;
					F_SYSCALL:	o_syscall		= 1'b1;
					F_BREAK:	o_break			= 1'b1;
					F_MULT:		o_mult			= 1'b1;
					F_MULTU:	o_multu			= 1'b1;
					F_DIV:		o_div			= 1'b1;
					F_DIVU:		o_divu			= 1'b1;
					F_MFHI:		o_mfhi			= 1'b1;
					F_MFLO:		o_mflo			= 1'b1;
					F_MTHI:		o_mthi			= 1'b1;
					F_MTLO:		o_mtlo			= 1'b1;
					default:	o_unknown_func	= 1'b1;
				endcase
			end
			OP_LUI:		o_alu_ctrl = F_LUI;
			OP_ORI:		o_alu_ctrl = F_OR;
			OP_XORI:	o_alu_ctrl = F_XOR;
			OP_ANDI:	o_alu_ctrl = F_AND;
			OP_CP0:		
			begin
				o_alu_ctrl = 0;
				case(i_rs)
					5'b00100:	// mtco
					begin 
						o_mtc0 = 1'b1;
					end
					5'b00000:	// mfco				
					begin 
						o_mfc0 = 1'b1;
						o_alu_ctrl = F_ADD;
					end
					5'b10000:	// eret
					begin 
						if(i_func == 6'b011000)	o_eret = 1'b1;
						else					o_unknown_func = 1'b1;
					end
					default: 
						o_unknown_func = 1'b1;
				endcase
			end
			default:	o_alu_ctrl = 6'b0;
		endcase
	end

endmodule
