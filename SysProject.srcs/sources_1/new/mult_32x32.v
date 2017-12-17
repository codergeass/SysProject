`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/01/03 13:28:54
// Design Name: 
// Module Name: mult_32x32
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


module mult_32x32(
	i_clk,
	i_rstn,
	i_cancel,
	i_sign,
	i_start,
	i_data0,
	i_data1,
	o_ready,
	o_result
	);
	input	i_clk;
	input	i_rstn;
	input	i_cancel;
	input	i_sign;					// 有符号运算标识	
	input	i_start;				// 开始信号	
	input	[31:0] i_data0;			
	input	[31:0] i_data1;			
	
   	output	o_ready;				// 运算完毕状态 用于控制运算结束
		
	output	[63:0] o_result;			// 乘法运算结果
	
	reg		[31:0] src0;				// 锁存的源操作数
	reg		[31:0] src1;				// 锁存的源操作数

	//reg		[63:0] regs[0:62];		// 用于乘法运算

	reg		[ 2:0] count;			// 乘法运算完毕计数器 用时五个时钟周期
	
	reg		r_sign;					// 锁存符号状态
	reg		finish;					// 运算结束标识
		
	wire	sign_diff;
	
	wire	[31:0] abs_data0;
	wire	[31:0] abs_data1;
	wire	[63:0] mult_result;
	
	assign sign_diff = i_sign & i_data0[31]^i_data1[31];
	
	assign abs_data0 = sign_diff ? ~i_data0+1 : i_data0;
	assign abs_data1 = sign_diff ? ~i_data1+1 : i_data1;
	
	assign o_ready = !count;
	// assign o_result = r_sign & o_ready ? ~regs[0]+1 : regs[0];
	assign o_result = r_sign & finish ? ~mult_result+1 : mult_result;

//	// 流水线式算法 用时六个时钟周期
//	always @(posedge i_clk or negedge i_rstn) begin
//		if (~i_rstn | i_cancel) begin : regs_clr
//			integer i;
//			for(i = 0;i < 64;i = i+1)
//				regs[i] <= 0;
//			count	<= 0;
//			r_sign	<= 0;
//			// finish	<= 0;
//		end
//		else begin
//			// 第一个时钟周期
//			if (o_ready & i_start) begin : regs_ini
//				regs[62] <= abs_data1[ 0] ? {32'b0, abs_data0} : 64'b0;
//				regs[61] <= abs_data1[ 1] ? {31'b0, abs_data0,  1'b0} : 64'b0;
//				regs[60] <= abs_data1[ 2] ? {30'b0, abs_data0,  2'b0} : 64'b0;
//				regs[59] <= abs_data1[ 3] ? {29'b0, abs_data0,  3'b0} : 64'b0;
//				regs[58] <= abs_data1[ 4] ? {28'b0, abs_data0,  4'b0} : 64'b0;
//				regs[57] <= abs_data1[ 5] ? {27'b0, abs_data0,  5'b0} : 64'b0;
//				regs[56] <= abs_data1[ 6] ? {26'b0, abs_data0,  6'b0} : 64'b0;
//				regs[55] <= abs_data1[ 7] ? {25'b0, abs_data0,  7'b0} : 64'b0;
//				regs[54] <= abs_data1[ 8] ? {24'b0, abs_data0,  8'b0} : 64'b0;
//				regs[53] <= abs_data1[ 9] ? {23'b0, abs_data0,  9'b0} : 64'b0;
//				regs[52] <= abs_data1[10] ? {22'b0, abs_data0, 10'b0} : 64'b0;
//				regs[51] <= abs_data1[11] ? {21'b0, abs_data0, 11'b0} : 64'b0;
//				regs[50] <= abs_data1[12] ? {20'b0, abs_data0, 12'b0} : 64'b0;
//				regs[49] <= abs_data1[13] ? {19'b0, abs_data0, 13'b0} : 64'b0;
//				regs[48] <= abs_data1[14] ? {18'b0, abs_data0, 14'b0} : 64'b0;
//				regs[47] <= abs_data1[15] ? {17'b0, abs_data0, 15'b0} : 64'b0;
//				regs[46] <= abs_data1[16] ? {16'b0, abs_data0, 16'b0} : 64'b0;
//				regs[45] <= abs_data1[17] ? {15'b0, abs_data0, 17'b0} : 64'b0;
//				regs[44] <= abs_data1[18] ? {14'b0, abs_data0, 18'b0} : 64'b0;
//				regs[43] <= abs_data1[19] ? {13'b0, abs_data0, 19'b0} : 64'b0;
//				regs[42] <= abs_data1[20] ? {12'b0, abs_data0, 20'b0} : 64'b0;
//				regs[41] <= abs_data1[21] ? {11'b0, abs_data0, 21'b0} : 64'b0;
//				regs[40] <= abs_data1[22] ? {10'b0, abs_data0, 22'b0} : 64'b0;
//				regs[39] <= abs_data1[23] ? { 9'b0, abs_data0, 23'b0} : 64'b0;
//				regs[38] <= abs_data1[24] ? { 8'b0, abs_data0, 24'b0} : 64'b0;
//				regs[37] <= abs_data1[25] ? { 7'b0, abs_data0, 25'b0} : 64'b0;
//				regs[36] <= abs_data1[26] ? { 6'b0, abs_data0, 26'b0} : 64'b0;
//				regs[35] <= abs_data1[27] ? { 5'b0, abs_data0, 27'b0} : 64'b0;
//				regs[34] <= abs_data1[28] ? { 4'b0, abs_data0, 28'b0} : 64'b0;
//				regs[33] <= abs_data1[29] ? { 3'b0, abs_data0, 29'b0} : 64'b0;
//				regs[32] <= abs_data1[30] ? { 2'b0, abs_data0, 30'b0} : 64'b0;
//				regs[31] <= abs_data1[31] ? { 1'b0, abs_data0, 31'b0} : 64'b0;

//				r_sign	<= sign_diff;
//				count	<= 5;
//				// finish	<= 1'b0;
//			end
//			// else if (~finish & o_ready) begin
				
//			// 	finish	<= 1;
//			// end
//			// 计算周期
//			else if (~o_ready) begin : compute
//				integer i1, i2, i3, i4;
//				for(i1 = 0;i1 < 16;i1 = i1+1)
//					regs[30-i1] <= regs[2*(30-i1)+1] + regs[2*(30-i1)+2];
//				for(i2 = 0;i2 < 8;i2 = i2+1)
//					regs[14-i2] <= regs[2*(14-i2)+1] + regs[2*(14-i2)+2];
//				for(i3 = 0;i3 < 4;i3 = i3+1)
//					regs[6-i3] <= regs[2*(6-i3)+1] + regs[2*(6-i3)+2];
//				for(i4 = 0;i4 < 2;i4 = i4+1)
//					regs[2-i4] <= regs[2*(2-i4)+1] + regs[2*(2-i4)+2];
//				regs[0]	<= regs[1] + regs[2];
//				count	<= count-1;
//				// finish	<= o_ready;
//			end
//		end
//	end

	// 第一个时钟周期用于锁存两个源操作数
	// 避免时序达不到乘法器要求
	always @(posedge i_clk or negedge i_rstn) begin
		if (~i_rstn) begin
			// reset
			src0	<= 0;
			src1	<= 0;
			count	<= 0;
			r_sign	<= 0;
			finish	<= 0;
		end
		else if (o_ready & i_start) begin
			src0	<= abs_data0;
			src1	<= abs_data1;
			count	<= 5;
			r_sign	<= sign_diff;
			finish	<= 1'b0;
		end
		else if (~o_ready) begin
			count	<= count-1;
		end
		else if (~finish & o_ready) begin
			finish		<= 1'b1;
		end
	end


	// 使用4个时钟周期
	// 第5个时钟周期输出ready信号
	multu32x32 MULTU(
		.CLK(i_clk),
		.A(src0),
		.B(src1),
		.CE(~o_ready & ~finish),
		.SCLR(~i_rstn | i_cancel),
		.P(mult_result)
	);

endmodule