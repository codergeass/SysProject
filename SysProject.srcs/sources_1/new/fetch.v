`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/15 17:00:31
// Design Name: 
// Module Name: fetch
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 取指部件
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fetch( 
	i_clk, 
	i_rstn, 
	i_pc_src,
	i_pc_write, 
	i_next_pc, 
	i_eret_pc, 
	i_excep_pc, 
	o_inner_pc,
	o_pc, 
	o_pc_plus4,
	o_instr 
	);

	input	i_clk;					// 时钟
	input	i_rstn;					// 清零
	input	[1:0] i_pc_src;			// pc来源
	input	i_pc_write;				// pc写使能
	
	input	[31:0] i_next_pc;		// 由译码部件得到的pc新值
	input	[31:0] i_eret_pc;		// 中断异常返回使用异常程序计数器的pc值
	input	[31:0] i_excep_pc;		// 中断处理程序入口地址
	
	output	[31:0] o_pc;				// PC寄存器输出pc值
	output	[31:0] o_pc_plus4;		// pc+4
	output	[31:0] o_instr;			// 取出的指令
	
	output	reg	[31:0] o_inner_pc;	// 内部pc 用于pc+4
	
	assign	o_pc_plus4 = o_pc + 32'h4;

	reg		is_first;
	// reg		is_first2;				// 用于第一个时钟周期 pc依然保持为零
	wire	clkn;
	assign	clkn = ~i_clk;
	
	// 指令存储器
	prg_rom ROM(
		.clka(clkn),					// 读指令慢半个周期
		.addra(o_pc[15:2]),
		.douta(o_instr)
		);
	
	// PC寄存器
	dffe32 PC(					
		.i_clk(i_clk),				
		.i_rstn(i_rstn),
		.i_we(i_pc_write),
		.i_data(o_inner_pc),
		.o_data(o_pc)
		);
	
	// // pc新值选择 注意有可能第一个时钟周期就从32'h4地址开始访问
	// mux4in1 NPC_MUX(
	// 	.i_data0(pc_plus4),
	// 	.i_data1(i_next_pc),
	// 	.i_data2(i_eret_pc),
	// 	.i_data3(i_excep_pc),
	// 	.i_ctrl(i_pc_src),
	// 	.o_data(o_inner_pc)
	// 	);

	// 保证第一个时钟周期进入译码部件的指令为空
	always @(posedge i_clk or negedge i_rstn) begin
		if (~i_rstn) begin
			// reset
			is_first	<= 1'b1;
		end
		else begin
			is_first	<= 1'b0;
		end
	end

	always @(*) begin
//		if(~i_rstn) begin
			o_inner_pc	= 32'b0;
//		end
//		else begin
			if (i_pc_write) begin
				case(i_pc_src)										// 根据pc来源更新pc值
					2'b01:		o_inner_pc = i_next_pc;				// 跳转		
					2'b10:		o_inner_pc = i_eret_pc;				// 中断返回
					2'b11:		o_inner_pc = i_excep_pc;				// 中断处理
					default:	o_inner_pc = is_first ? o_pc : o_pc_plus4;
				endcase
			end
//		end
	end
endmodule
