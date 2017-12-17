`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/26 14:32:42
// Design Name: 
// Module Name: div32x32
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 32位除法器 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module div_32x32(
	i_clk,
	i_rstn,
	i_cancel,
	i_sign,
	i_start,
	i_data0,
	i_data1,
	o_ready,
	o_quotient,
	o_remainder
	);
	

	input	i_clk;
	input	i_rstn;
	input	i_cancel;
	input	i_sign;					// 有符号运算标识	
	input	i_start;				// 开始信号	
	input	[31:0] i_data0;			// 被除数
	input	[31:0] i_data1;			// 除数

	output	o_ready;				// 迭代运算完毕状态 用于控制迭代运算结束
	
	output	[31:0] o_quotient;		// 商
	output	[31:0] o_remainder;		// 余数
	
	reg	[64:0]	dividend;			// 迭代运算扩展的被除数
	reg	[64:0]	divisor;			// 迭代运算的除数
	reg	[31:0]	quotient;			// 迭代运算的商
	reg	[ 5:0]	count;				// 迭代次数计数
	
	reg	r_sign;						// 根据被除数是否有符号决定余数的符号
	reg	sign_diff;					// 根据除数和被除数符号决定商的符号
	reg finish;						// 迭代运算完成信号

	wire [31:0]	data0;				// 去符号被除数
	wire [31:0]	data1;				// 去符号除数
	wire [64:0] sub_remainder;		// 被除数减去除数后的部分余数
	
	assign	o_remainder = dividend[31:0];
	assign	o_quotient = quotient;
	
	assign	data0 = (i_data0[31] & i_sign) ? (~(i_data0)+1) : i_data0;
	assign	data1 = (i_data1[31] & i_sign) ? (~(i_data1)+1) : i_data1;

	assign	sub_remainder = dividend - divisor;
	assign	o_ready = !count;

	always@(posedge i_clk or negedge i_rstn) begin
		if (~i_rstn | i_cancel) begin
			count		<= 0;
			quotient	<= 0;
			dividend	<= 0;
			divisor		<= 0;
			r_sign		<= 0;
			sign_diff	<= 0;
			finish		<= 1;
		end
		else begin
			if (o_ready & i_start) begin					// 迭代运算初始化
				count		<= 33;						// 迭代次数初始化
				quotient	<= 0;						// 商初始化
				dividend	<= {33'b0, data0};			// 对被除数进行扩展
				divisor		<= {1'b0, data1, 32'b0};		// 对除数进行移位并扩展
				r_sign		<= i_data0[31] & i_sign;
				sign_diff	<= i_data0[31]^i_data1[31] & i_sign;
				finish		<= 0;
			end
			else if(~finish & o_ready) begin				// 迭代运算完毕
				if(sign_diff)							// 根据有无符号 得到正确的结果
					quotient <= (~quotient) + 1;
				if(r_sign)
					dividend[31:0] <= (~dividend[31:0]) + 1;
				finish		<= 1;
			end
			else if (~o_ready) begin						// 依次进行迭代
				if(sub_remainder[64]==1) begin			// 如果部分余数是负数
					quotient <= (quotient<<1);			// 不更新迭代中的部分余数即被除数
				end
				else begin
					dividend <= sub_remainder;
					quotient <= (quotient<<1) + 1;
				end
									
				divisor	<= divisor>>1;
				count <= count - 1;						// 迭代32次
			end
		end
	end


endmodule
