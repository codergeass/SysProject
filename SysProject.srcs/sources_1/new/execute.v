`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/20 13:52:49
// Design Name: 
// Module Name: execute
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 执行部件  
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module execute(
	i_clk,
	i_rstn,
	i_pc_plus4,
	i_imm,
	i_decode_src1, 
	i_decode_src2, 
	i_alu_src_op1,
	i_alu_src_op2,
	i_extend_op, 
	// i_alu_src1, 
	// i_alu_src2,
	i_alu_ctrl, 
	i_pc_store,
	i_mfc0,
	i_mfhi_lo,
	i_mult_div,
	i_mult_div_cancel,
	i_start,
	i_divide,
	i_sign,
	o_alu_res,
	o_overflow,
	o_hi,
	// o_lo,
	o_hi_lo_write,
	o_ready
	);
	
	input	[31:0] i_pc_plus4;				// pc+4
	input	[15:0] i_imm;					// imm
	input	[31:0] i_decode_src1;			// alu源操作数1
	input	[31:0] i_decode_src2;			// alu源操作数2
	// input	[31:0] i_alu_src1;				// alu源操作数1
	// input	[31:0] i_alu_src2;				// alu源操作数2
	input	[5:0 ] i_alu_ctrl;				// alu控制信号
	
	input	i_pc_store;						// 跳转指令是否存储pc信号
	
	input	i_mfc0;							// mfc0指令 [1]选择c0读出数据作为 alu_res
	input	i_mfhi_lo;						// mfhi mflo指令 [1]选择hi_lo读出数据作为 alu_res

	input	i_clk;
	input	i_rstn;
	input	i_alu_src_op1;
	input	i_alu_src_op2;
	input	i_extend_op;
	input	i_mult_div_cancel;				// 中断时乘除法取消信号
	input	i_mult_div;						// 乘除法运算信号
	input	i_start;						// 乘除法运算开始信号
	input	i_divide;						// 除法运算信号
	input	i_sign;							// 有符号乘除法运算标识
	
	output	[31:0] o_alu_res;				// alu运算结果
	
	output	[31:0] o_hi;						// 乘除法运算结果高32位
	// 低32位用alures 存储 节省资源
	// output	[31:0] o_lo;						// 乘除法运算结果低32位
	
	output	o_overflow;						// 溢出标识位
	output	o_hi_lo_write;					// 乘除法运算写HI LO寄存器信号
	output	o_ready;						// 乘除法运算完毕信号
	
	wire	[31:0] alu_res_in;				// alu计算结果
	wire	[31:0] pc_plus8;					// pc+8

	wire	[31:0] alu_src1;
	wire	[31:0] alu_src2;
	wire	[31:0] extended_data;
	
	wire	[31:0] lo;
	wire	[31:0] alu_res;

	wire	busy;							// 乘除法运算正在工作信号
	
	assign	pc_plus8 = i_pc_plus4 + 32'h4;

	// 当运算完成 并且不是开始或中断取消乘除法时 才有效
	assign	o_hi_lo_write = o_ready & busy;
	// 使用alu_res寄存器存储乘除法运算lo寄存器数据
	assign o_alu_res = o_hi_lo_write ? lo : alu_res;

	// 扩展器
	sign_extend EXTENDER ( 
		.i_data(i_imm), 
		.i_ctrl(i_extend_op), 
		.o_data(extended_data)
	);

	// 源操作数1的选择 [0]rs [1]shamt
	mux2in1 ALU_SRC_OP1 ( 
		.i_data0(i_decode_src1),
		.i_data1({27'b0, i_imm[10:6]}),
		.i_ctrl(i_alu_src_op1),
		.o_data(alu_src1)
		);

	// 源操作数2的选择 [0]rt/c0/hi/lo [1]extended-immediate
	mux2in1 ALU_SRC_OP2 ( 
		.i_data0(i_decode_src2), 
		.i_data1(extended_data), 
		.i_ctrl(i_alu_src_op2), 
		.o_data(alu_src2)
		);

	// 算术逻辑单元
	alu ALU ( 
		.i_src1(alu_src1), 
		.i_src2(alu_src2), 
		.i_alu_ctrl(i_alu_ctrl), 
		.o_result(alu_res_in), 
		.o_overflow(o_overflow)
		);
	
	// 乘除法运算单元
	mult_div MULT_DIV (
		.i_clk(i_clk),
		.i_rstn(i_rstn),
		.i_cancel(i_mult_div_cancel),
		.i_divide(i_divide),
		.i_sign(i_sign),
		.i_start(i_start),
		.i_data0(i_decode_src1),
		.i_data1(i_decode_src2),
		.o_ready(o_ready),
		.o_busy(busy),
		.o_result({o_hi, lo})
		);

	// 根据跳转指令是否向寄存器写回pc 选择输出
	// mfhi mflo mfc0 这些不需要alu的数据也通过alures传递
	// 由于存在一条指令的延迟转移 所以保存的pc应为下下条指令地址 即pc+8
	mux4in1 PC_ALU_OP(
		.i_data0(alu_res_in),
		.i_data1(pc_plus8),
		.i_data2(alu_src2),
		.i_data3(alu_src2),
		.i_ctrl({i_mfc0 | i_mfhi_lo, i_pc_store}),
		.o_data(alu_res)
	);

endmodule
