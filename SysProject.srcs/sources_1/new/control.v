`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/20 15:14:30
// Design Name: 
// Module Name: control
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


module control(
	i_op,
	i_rt,
	o_j,
	o_jal,
	o_beq,
	o_bne,
	o_bgez,
	o_bgtz,
	o_blez,
	o_bltz,
	o_bgezal,
	o_bltzal,
	o_reg_dst_op,
	o_mem2reg,
	o_mem_write,
	o_mem_read,
	o_unsign,
	o_data_width,
	o_alu_src_op2,
	o_reg_write,
	o_extend_op,
	o_unknown_command
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
	localparam OP_BLEZ	= 6'b000110, OP_BGTZ		= 6'b000111;
	localparam OP_MUL_BRANCH = 6'b000001;	// bgez, bltz, bgezal, bltzal	
	localparam OP_SLTI	= 6'b001010, OP_SLTIU	= 6'b001011;
	localparam OP_J		= 6'b000010, OP_JAL		= 6'b000011;
	localparam OP_CP0	= 6'b010000;


	input	[5:0]	i_op;			// 指令op字段 
	input	[4:0]	i_rt;			// 指令rt字段 
	
	output	reg o_j; 
	output	reg o_jal; 
	output	reg o_beq;
	output	reg o_bne;
	output	reg o_bgez;
	output	reg o_bgtz;
	output	reg o_blez;
	output	reg o_bltz;
	output	reg o_bgezal;
	output	reg o_bltzal;

	output	reg o_reg_dst_op;			// 目的操作数寄存器地址 [0]rt [1]rd
	output	reg o_mem2reg;				// 存储器向寄存器写数据信号 用于取数指令
	output	reg o_mem_write;			// 存储器写信号 用于存数指令
	output	reg o_mem_read;				// 存储器读信号 用于取数指令
	output	reg o_unsign;				// 取数指令是否进行符号扩展

	output	reg o_alu_src_op2;			// alu源操作数来源 [0]rt [1]来自扩展器
	output	reg o_reg_write;			// 寄存器写使能
	output	reg o_extend_op;			// 扩展器扩展方式 [0]无符号扩展 [1]有符号扩展
	output	reg o_unknown_command;

	output	reg [1:0] o_data_width;		// 存取数指令数据宽度 [00]8位 [01]16位 [10]32位	

	always @(*) begin
		o_reg_dst_op	= 1'b0;
		o_reg_write		= 1'b0;
		o_alu_src_op2	= 1'b0;
		o_j				= 1'b0;
		o_jal			= 1'b0;
		o_beq			= 1'b0;
		o_bne			= 1'b0;
		o_bgez			= 1'b0;
		o_bgtz			= 1'b0;
		o_blez			= 1'b0;
		o_bltz			= 1'b0;
		o_bgezal		= 1'b0;
		o_bltzal		= 1'b0;
		o_mem_write		= 1'b0;
		o_mem2reg		= 1'b0;
		o_unsign		= 1'b0;
		o_extend_op		= 1'b0;
		o_mem_read		= 1'b0;
		o_data_width	= 2'b10;
		o_unknown_command = 1'b0;

		case(i_op)
			R_TYPE: 
			begin
				o_reg_dst_op	= 1'b1;
				o_reg_write		= 1'b1;
			end
			OP_ADDI,
			OP_SLTI:
			begin
				o_reg_write		= 1'b1;
				o_alu_src_op2	= 1'b1;
				o_extend_op		= 1'b1;
			end
			OP_LUI,
			OP_ORI,
			OP_XORI,
			OP_ANDI,
			OP_ADDIU,
			OP_SLTIU:
			begin
				o_reg_write		= 1'b1;
				o_alu_src_op2	= 1'b1;
			end
			OP_LB:
			begin
				o_reg_write		= 1'b1;
				o_alu_src_op2	= 1'b1;
				o_mem2reg		= 1'b1;
				o_extend_op		= 1'b1;
				o_mem_read		= 1'b1;
				o_data_width	= 2'b00;
			end
			OP_LBU:
			begin
				o_reg_write		= 1'b1;
				o_alu_src_op2	= 1'b1;
				o_mem2reg		= 1'b1;
				o_extend_op		= 1'b0;
				o_mem_read		= 1'b1;
				o_data_width	= 2'b00;
				o_unsign		= 1'b1;
			end
			OP_LH:
			begin
				o_reg_write		= 1'b1;
				o_alu_src_op2	= 1'b1;
				o_mem2reg		= 1'b1;
				o_extend_op		= 1'b1;
				o_mem_read		= 1'b1;
				o_data_width	= 2'b01;
			end
			OP_LHU:
			begin
				o_reg_write		= 1'b1;
				o_alu_src_op2	= 1'b1;
				o_mem2reg		= 1'b1;
				o_extend_op		= 1'b0;
				o_mem_read		= 1'b1;
				o_data_width	= 2'b01;
				o_unsign		= 1'b1;
			end
			OP_LW:
			begin
				o_reg_write		= 1'b1;
				o_alu_src_op2	= 1'b1;
				o_mem2reg		= 1'b1;
				o_extend_op		= 1'b1;
				o_mem_read		= 1'b1;
				o_data_width	= 2'b10;
			end
			OP_SB:
			begin
				o_alu_src_op2	= 1'b1;
				o_mem_write		= 1'b1;
				o_extend_op		= 1'b1;
				o_data_width	= 2'b00;
			end
			OP_SH:
			begin
				o_alu_src_op2	= 1'b1;
				o_mem_write		= 1'b1;
				o_extend_op		= 1'b1;
				o_data_width	= 2'b01;
			end
			OP_SW:
			begin
				o_alu_src_op2	= 1'b1;
				o_mem_write		= 1'b1;
				o_extend_op		= 1'b1;
				o_data_width	= 2'b10;
			end
			OP_J:		o_j 		= 1'b1;
			OP_JAL:
			begin
				o_jal			= 1'b1;
				o_reg_write		= 1'b1;
			end
			OP_BEQ:		o_beq	= 1'b1;
			OP_BNE:		o_bne	= 1'b1;
			OP_BGTZ:	o_bgtz	= 1'b1;
			OP_BLEZ:	o_blez	= 1'b1;
			OP_MUL_BRANCH:
			begin
				case(i_rt)
					5'b00001:	o_bgez		= 1'b1;
					5'b00000:	o_bltz		= 1'b1;
					5'b10001:	o_bgezal	= 1'b1;
					5'b10000:	o_bltzal	= 1'b1;
					default:	o_unknown_command = 1'b1;
				endcase
			end
			OP_CP0:		o_reg_write = 1'b1;
			default:	o_unknown_command = 1'b1;
		endcase
	end	
 
endmodule
