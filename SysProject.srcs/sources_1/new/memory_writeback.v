`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/01 21:01:46
// Design Name: 
// Module Name: memory_writeback
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 存储器访问-写回间的寄存器 产生写回周期
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module memory_writeback(
	i_clk,
	i_rstn,
	i_reg_dst,
	i_reg_data,
	i_reg_write,
	i_mem2reg,
	// i_interface_read,
	// i_data_width,
	// i_unsign,
	// i_load_addr,
	i_hi,
	// i_lo,
	i_hi_lo_write,
	o_reg_dst,
	o_reg_data,
	o_reg_write,
	o_mem2reg,
	o_hi,
	// o_lo,
	o_hi_lo_write
	);
	
	input	i_clk;
	input	i_rstn;
	
	// input	[ 1:0] i_data_width;
	// input	[ 1:0] i_load_addr;
	input	[ 4:0] i_reg_dst;
	input	[31:0] i_reg_data;
	input	[31:0] i_hi;
	// input	[31:0] i_lo;

	// input	i_unsign;
	input	i_reg_write;
	input	i_mem2reg;
	// input	i_interface_read;
	input	i_hi_lo_write;
	
	output	reg	[ 4:0] o_reg_dst;
	output	reg	[31:0] o_reg_data;
	output	reg	[31:0] o_hi;
	// output	reg [31:0] o_lo;

	output	reg	o_reg_write;
	output	reg o_mem2reg;
	output	reg o_hi_lo_write;

	reg		[31:0] reg_data;
	reg		[ 1:0] data_width;
	reg		[ 1:0] addr;
	// reg		unsign;
	// reg		interface_read;

	// assign o_reg_data = reg_data;

	// assign o_reg_data = i_mem2reg ? load_word_data : reg_data;
	///////////////////////////////////////////////////////////
	// 将存储器取数选择设置在这一级 减轻MEM 和 ID两级的负荷
	// !!!!!!!!!!!!!!!!!数据相关时有问题!!!!!!!!!!!!!!!!!!!!!!!
	///////////////////////////////////////////////////////////
	// wire	sign_ext_byte0;
	// wire	sign_ext_byte1;
	// wire	sign_ext_byte2;
	// wire	sign_ext_byte3;
	// wire	sign_ext_half0;
	// wire	sign_ext_half1;
	
	// wire	[31:0] load_byte_data, load_half_data, load_word_data;
	
	// // 取数数据扩展填充数据
	// assign	sign_ext_byte0 = unsign ? 1'b0 : reg_data[ 7];
	// assign	sign_ext_byte1 = unsign ? 1'b0 : reg_data[15];
	// assign	sign_ext_byte2 = unsign ? 1'b0 : reg_data[23];
	// assign	sign_ext_byte3 = unsign ? 1'b0 : reg_data[31];
	
	// assign	sign_ext_half0 = unsign ? 1'b0 : reg_data[15];
	// assign	sign_ext_half1 = unsign ? 1'b0 : reg_data[31];
 
	// // 取数字节数据
	// mux4in1 LOAD_BYTE_DATA_OP(
	// 	.i_data0({{24{sign_ext_byte0}}, reg_data[ 7:0 ]}),
	// 	.i_data1({{24{sign_ext_byte1}}, reg_data[15:8 ]}),
	// 	.i_data2({{24{sign_ext_byte2}}, reg_data[23:16]}),
	// 	.i_data3({{24{sign_ext_byte3}}, reg_data[31:24]}),
	// 	.i_ctrl(addr[1:0]),
	// 	.o_data(load_byte_data)
	// 	);
	
	// // 取数半字数据
	// // 考虑了接口取半字的情况
	// mux4in1 LOAD_HALF_DATA_OP(
	// 	.i_data0({{16{sign_ext_half0}}, reg_data[15:0 ]}),
	// 	.i_data1({{16{sign_ext_half1}}, reg_data[31:16]}),
	// 	.i_data2({{16{sign_ext_half0}}, reg_data[15:0 ]}),
	// 	.i_data3({{16{sign_ext_half0}}, reg_data[15:0 ]}),
	// 	.i_ctrl({interface_read, addr[1]}),
	// 	.o_data(load_half_data)
	// 	);
	
	// // 根据数据宽度选择合适的取数数据
	// // [00] 字节 [01]半字 [10]字
	// mux4in1 LOAD_DATA_OP(
	// 	.i_data0(load_byte_data),
	// 	.i_data1(load_half_data),
	// 	.i_data2(reg_data),
	// 	.i_data3(reg_data),
	// 	.i_ctrl(data_width),
	// 	.o_data(load_word_data)
	// 	);

	always @(posedge i_clk or negedge i_rstn) begin
		if (~i_rstn) begin
			// reset
			o_reg_dst	<= 0;
			o_reg_data	<= 0;
			// data_width	<= 0;
			// unsign		<= 0;
			// addr		<= 0;

			o_reg_write	<= 0;
			o_mem2reg	<= 0;
			
			o_hi		<= 0;
			// o_lo		<= 0;
			o_hi_lo_write	<= 0;
			// interface_read	<= 0;
		end
		else begin
			o_reg_dst	<= i_reg_dst;
			o_reg_data	<= i_reg_data;
			// data_width	<= i_data_width;
			// unsign		<= i_unsign;
			// addr		<= i_load_addr;

			o_reg_write	<= i_reg_write;
			o_mem2reg	<= i_mem2reg;

			o_hi		<= i_hi;
			// o_lo		<= i_lo;
			o_hi_lo_write	<= i_hi_lo_write;
			// interface_read	<= i_interface_read;
		end
	end
	
endmodule
