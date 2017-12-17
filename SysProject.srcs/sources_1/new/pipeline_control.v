`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/05 16:22:26
// Design Name: 
// Module Name: pipeline_control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 流水线控制器 负责数据转发控制信号的生成 以及暂停流水
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pipeline_control(
	i_rs,
	i_rt,
	i_id_exe_reg_dst,
	i_exe_mem_reg_dst,
	i_mem_wb_reg_dst,
	i_id_exe_reg_write,
	i_exe_mem_reg_write,
	i_mem_wb_reg_write,
	i_id_exe_mem_read,
	i_id_exe_hi_lo_write,
	i_exe_mem_hi_lo_write,
	i_mem_wb_hi_lo_write,
	i_mfhi_lo,
	i_id_exe_mult_div,
	i_exception,
	i_ready,
	o_forward_src_op1,
	o_forward_src_op2,
	o_forward_hi_lo,
	o_pc_write,
	o_ir_write,
	o_stall
	);
	
	input	[4:0] i_rs;					// rs寄存器地址
	input	[4:0] i_rt;					// rt寄存器地址
	input	[4:0] i_id_exe_reg_dst;		// id-exe寄存器保存的目的操作数寄存器地址 用于上条指令exe阶段
	input	[4:0] i_exe_mem_reg_dst;	// exe-mem寄存器保存的目的操作数寄存器地址 用于上上条指令mem阶段
	input	[4:0] i_mem_wb_reg_dst;		// mem-wb寄存器保存的目的操作数寄存器地址 用于上上上条指令wb阶段

	input	i_id_exe_reg_write;			// id-exe寄存器保存的寄存器写使能信号 用于上条指令
	input	i_exe_mem_reg_write;		// exe-mem寄存器保存的寄存器写使能信号 用于上上条指令
	input	i_mem_wb_reg_write;			// mem-wb寄存器保存的寄存器写使能信号 用于上上上条指令
	input	i_id_exe_mem_read;			// id-exe寄存器保存的存储器读信号 代表上条指令为取数指令
	input	i_id_exe_hi_lo_write;		// id-exe寄存器保存的存储器读信号 代表上条指令为取数指令
	input	i_exe_mem_hi_lo_write;		// id-exe寄存器保存的存储器读信号 代表上条指令为取数指令
	input	i_mem_wb_hi_lo_write;		// id-exe寄存器保存的存储器读信号 代表上条指令为取数指令
	input	i_exception;				// 异常信号
	input	i_mfhi_lo;					// 译码部件mfhi mflo指令信号
	input	i_id_exe_mult_div;			// 执行部件乘除法指令信号
	input	i_ready;					// 乘除法器运算完毕信号

	output	reg [1:0] o_forward_src_op1;	// 源操作数1数据转发选择
	output	reg [1:0] o_forward_src_op2;	// 源操作数2数据转发选择
	output	reg [1:0] o_forward_hi_lo;	// HI LO寄存器数据转发选择
	
	output	reg o_pc_write;				// pc写使能
	output	reg o_ir_write;				// ir写使能
	output	reg o_stall;					// 流水线暂停信号

	always @(*) begin
		// 源操作数1的转发信号
		if ((i_rs == i_id_exe_reg_dst) & (i_id_exe_reg_dst!= 0) & i_id_exe_reg_write) begin
			// 当前指令与上一条指令存在数据相关 将数据从alu转发到译码部件
			o_forward_src_op1 = 2'b01;
		end
		else if ((i_rs == i_exe_mem_reg_dst) & (i_exe_mem_reg_dst != 0) & i_exe_mem_reg_write) begin
			// 当前指令与上上条指令存在数据相关 将数据从mem转发到译码部件
			o_forward_src_op1 = 2'b10;
		end
		else if ((i_rs == i_mem_wb_reg_dst) & (i_mem_wb_reg_dst != 0) & i_mem_wb_reg_write) begin
			// 当前指令与上上上条指令存在数据相关 将数据从wb转发到译码部件
			o_forward_src_op1 = 2'b11;
		end
		else begin
			// 默认 无数据相关 不转发
			o_forward_src_op1 = 2'b00;
		end

		// 源操作数2的转发信号 
		if ((i_rt == i_id_exe_reg_dst) & (i_id_exe_reg_dst!= 0) & i_id_exe_reg_write) begin
			// 当前指令与上一条指令存在数据相关 将数据从exe转发到译码部件
			o_forward_src_op2 = 2'b01;
		end
		else if ((i_rt == i_exe_mem_reg_dst) & (i_exe_mem_reg_dst != 0) & i_exe_mem_reg_write) begin
			// 当前指令与上上条指令存在数据相关 将数据从mem转发到译码部件
			o_forward_src_op2 = 2'b10;
		end
		else if ((i_rt == i_mem_wb_reg_dst) & (i_mem_wb_reg_dst != 0) & i_mem_wb_reg_write) begin
			// 当前指令与上上上条指令存在数据相关 将数据从wb转发到译码部件
			o_forward_src_op2 = 2'b11;
		end
		else begin
			// 默认 无数据相关 不转发
			o_forward_src_op2 = 2'b00;
		end

		// HI LO寄存器的转发信号
		if (i_mfhi_lo & i_id_exe_hi_lo_write) begin
			// 前一条指令是乘除法指令 且运算完毕 将数据从exe转发
			o_forward_hi_lo = 2'b01;
		end
		else if (i_mfhi_lo & i_exe_mem_hi_lo_write) begin
			// 上上条指令是乘除法指令 且运算完毕 将数据从mem转发
			o_forward_hi_lo = 2'b10;
		end
		else if (i_mfhi_lo & i_mem_wb_hi_lo_write) begin
			// 上上上条指令是乘除法指令 且运算完毕 将数据从wb转发
			o_forward_hi_lo = 2'b11;
		end
		else begin
			// 默认 无数据相关 不转发
			o_forward_hi_lo = 2'b00;
		end

		// 暂停流水线信号
		// 取数指令要到mem阶段才能流出数据 所以要暂停一个时钟周期
		if (((i_rs == i_id_exe_reg_dst) | (i_rt == i_id_exe_reg_dst)) 
			& (i_id_exe_reg_dst != 0) & i_id_exe_mem_read & ~i_exception) begin
			o_stall		= 1'b1;
			o_pc_write	= 1'b0;
			o_ir_write	= 1'b0;
		end
		else if ((~i_ready | i_id_exe_mult_div) & ~i_exception) begin 	// 乘除法运算未计算完毕 暂停流水线
			o_stall		= 1'b1;
			o_pc_write	= 1'b0;
			o_ir_write	= 1'b0;
		end
		else begin
			o_stall		= 1'b0;
			o_pc_write	= 1'b1;
			o_ir_write	= 1'b1;
		end
		 
	end
endmodule
