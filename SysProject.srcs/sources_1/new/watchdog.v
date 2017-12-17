`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/30 10:37:53
// Design Name: 
// Module Name: watchdog
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 看门狗
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module watchdog(
	i_clk,
	i_rstn,
	i_we,
	i_data,
	o_reset
	);

	input	i_clk;
	input	i_rstn;
	input	i_we;				// 写使能
	
	input	[15:0] i_data;

	output	reg o_reset;			// 看门狗输出复位信号

	reg		[15:0] count;		// 计时器
	reg		[ 2:0] count_reset;	// 复位信号时钟周期个数 计时器
	
	always @(posedge ~i_clk or negedge i_rstn) begin
		if (~i_rstn) begin
			// reset
			count		<= 16'hffff;
			count_reset	<= 4;
			o_reset		<= 1;
		end
		else if (i_we) begin
				count	<= i_data;			// 初始值直接送入计数寄存器
		end 
		else begin
			if (!count) begin
				if (!count_reset) begin
					o_reset		<= 1'b1;		// 看门狗输出重启信号
					count_reset	<= 4;		// 复位计数器恢复
					count		<= 16'hffff;
				end
				else begin
					o_reset		<= 1'b0;		// 看门狗输出清零信号
					count_reset	<= count_reset - 1;
				end
			end
			else begin
				count	<= count - 1;		// 计数 计数值减1
			end
		end
	end

endmodule
