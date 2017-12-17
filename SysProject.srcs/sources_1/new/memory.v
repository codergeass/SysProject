`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/20 13:35:28
// Design Name: 
// Module Name: memory
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// �洢��
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module memory(
	i_clk, 
	i_rstn, 
	i_addr, 
	i_data,
	i_mem_write, 
	i_mem2reg,
	i_unsign,
	i_data_width,
	i_interface_read,
	i_interface_write,
	i_interface_data,
	o_mem_data
	);

	input	i_clk;
	input	i_rstn;

	input	[31:0] i_addr;
	input	[31:0] i_data;

	input	i_mem_write, i_mem2reg;
	input	i_unsign;
	input	[ 1:0] i_data_width;

	input	i_interface_read;
	input	i_interface_write;
	
	input	[15:0] i_interface_data;
	
	output	[31:0] o_mem_data;

	// wire	[31:0] store_byte_data;
	// wire	[31:0] store_half_data;
	wire	[31:0] store_word_data;
	wire	[31:0] out_data;
	 
	// wire	[31:0] load_byte_data;
	// wire	[31:0] load_half_data;
	wire	[31:0] load_word_data;
	
	// wire	[23:0] sign_ext_byte;
	// wire	[15:0] sign_ext_half;
	// wire	[31:0] byte_data;
	// wire	[31:0] half_data;

	wire	[ 3:0] write;				// ����д�����ź�
	wire	[ 3:0] write_in;				// д����ѡ�����ź�
	// wire	[ 3:0] byte_write_which;		// ����д����λ�ò���д�ź�
	// wire	[ 3:0] half_write_which;		// ����д����λ�ò���д�ź�

	wire	sign_ext_byte0;
	wire	sign_ext_byte1;
	wire	sign_ext_byte2;
	wire	sign_ext_byte3;
	// wire	sign_ext_half0;
	// wire	sign_ext_half1;

	wire	sign_ext_interface;

	wire	[2:0] store_ctrl;
	wire	[2:0] load_ctrl;

	// wire	byte_sign;					// ȡ����չ����
	// wire	half_sign;					// ȡ����չ����
	wire	clkn;

	assign	write =  write_in & {4{i_mem_write & ~i_interface_write}};

	assign	clkn = ~i_clk;	// ��Ϊʹ��CycloneоƬ�Ĺ����ӳ٣�RAM�ĵ�ַ����������ʱ��������׼����,
							// ʹ��ʱ�����������ݶ����������Բ��÷���ʱ�ӣ�ʹ�ö������ݱȵ�ַ׼
							// ����Ҫ���Լ���ʱ�ӣ��Ӷ��õ���ȷ��ַ��

	// ȡ��������չ�������
	assign	sign_ext_byte0 = i_unsign ? 1'b0 : out_data[ 7];
	assign	sign_ext_byte1 = i_unsign ? 1'b0 : out_data[15];
	assign	sign_ext_byte2 = i_unsign ? 1'b0 : out_data[23];
	assign	sign_ext_byte3 = i_unsign ? 1'b0 : out_data[31];
	
	assign store_ctrl = 	i_data_width[1] ? 3'b111 :
						{ i_data_width[0], i_addr[1:0] };

	assign load_ctrl = 	i_interface_read ? 3'b101 : 
						store_ctrl;
	
	// assign	sign_ext_half0 = i_unsign ? 1'b0 : out_data[15];
	// assign	sign_ext_half1 = i_unsign ? 1'b0 : out_data[31];
	
	assign	sign_ext_interface = i_unsign ? 1'b0 : i_interface_data[15];

	// assign	byte_sign = i_unsign ? 1'b0 : load_word_data[ 7];
	// assign	half_sign = i_unsign ? 1'b0 : load_word_data[15];
	
	// ȡ��������չ�������
	// assign	sign_ext_byte = {24{byte_sign}};
	// assign	sign_ext_half = {16{half_sign}};

	// // �����Ƿ���з�����չ��ȡ�����ݽ�����չ
	// assign byte_data = i_unsign ? {24'b0, load_word_data[ 7:0]} : {sign_ext_byte, load_word_data[ 7:0]};
	// assign half_data = i_unsign ? {16'b0, load_word_data[15:0]} : {sign_ext_half, load_word_data[15:0]};

	// // ѡ���ֽ�д�����ź�
	// mux4in1 #(.WIDTH(4)) BYTE_WRITE_OP(
	// 	.i_data0(4'b0001),
	// 	.i_data1(4'b0010),
	// 	.i_data2(4'b0100),
	// 	.i_data3(4'b1000),
	// 	.i_ctrl(i_addr[1:0]),
	// 	.o_data(byte_write_which)
	// 	);

	// // ѡ�����д�����ź�
	// mux2in1 #(.WIDTH(4)) HALF_WRITE_OP(
	// 	.i_data0(4'b0011),
	// 	.i_data1(4'b1100),
	// 	.i_ctrl(i_addr[1]),
	// 	.o_data(half_write_which)
	// 	);

	// // �������ݿ��ѡ����ʵ�д�ź�
	// mux4in1 #(.WIDTH(4)) WRITE_OP(
	// 	.i_data0(byte_write_which),
	// 	.i_data1(half_write_which),
	// 	.i_data2(4'b1111),
	// 	.i_data3(4'b1111),
	// 	.i_ctrl(i_data_width),
	// 	.o_data(write_in)
	// 	);

	// ʹ��һ��ѡ�� ��С�ӳ�
	mux8in1 #(.WIDTH(4)) WRITE_OP(
		.i_data0(4'b0001),
		.i_data1(4'b0010),
		.i_data2(4'b0100),
		.i_data3(4'b1000),
		.i_data4(4'b0011),
		.i_data5(4'b0000),
		.i_data6(4'b1100),
		.i_data7(4'b1111),
		.i_ctrl(store_ctrl),
		.o_data(write_in)
		);

	// // �����ֽ�����
	// mux4in1 STORE_BYTE_DATA_OP(
	// 	.i_data0({24'b0, i_data[7:0]}),
	// 	.i_data1({16'b0, i_data[7:0], 8'b0}),
	// 	.i_data2({8'b0, i_data[7:0], 16'b0}),
	// 	.i_data3({i_data[7:0], 24'b0}),
	// 	.i_ctrl(i_addr[1:0]),
	// 	.o_data(store_byte_data)
	// 	);
	
	// // ������������
	// mux2in1 STORE_HALF_DATA_OP(
	// 	.i_data0({16'b0, i_data[15:0]}),
	// 	.i_data1({i_data[15:0], 16'b0}),
	// 	.i_ctrl(i_addr[1]),
	// 	.o_data(store_half_data)
	// 	);
	
	// // �������ݿ��ѡ����ʵĴ�������
	// // [00] �ֽ� [01]���� [10]��
	// mux4in1 STORE_DATA_OP(
	// 	.i_data0(store_byte_data),
	// 	.i_data1(store_half_data),
	// 	.i_data2(i_data),
	// 	.i_data3(i_data),
	// 	.i_ctrl(i_data_width),
	// 	.o_data(store_word_data)
	// 	);

	// ʹ��һ��ѡ�� ��С�ӳ�
	mux8in1 STORE_DATA_OP(
		.i_data0({24'b0, i_data[7:0]}),
		.i_data1({16'b0, i_data[7:0], 8'b0}),
		.i_data2({8'b0, i_data[7:0], 16'b0}),
		.i_data3({i_data[7:0], 24'b0}),
		.i_data4({16'b0, i_data[15:0]}),
		.i_data5(32'b0),
		.i_data6({i_data[15:0], 16'b0}),
		.i_data7(i_data),
		.i_ctrl(store_ctrl),
		.o_data(store_word_data)
		);

	// // ȡ���ֽ�����
	// mux4in1 LOAD_BYTE_DATA_OP(
	// 	.i_data0({sign_ext_byte, out_data[ 7:0 ]}),
	// 	.i_data1({sign_ext_byte, out_data[15:8 ]}),
	// 	.i_data2({sign_ext_byte, out_data[23:16]}),
	// 	.i_data3({sign_ext_byte, out_data[31:24]}),
	// 	.i_ctrl(i_addr[1:0]),
	// 	.o_data(load_byte_data)
	// 	);
	
	// // ȡ����������
	// mux2in1 LOAD_HALF_DATA_OP(
	// 	.i_data0({sign_ext_half, out_data[15:0 ]}),
	// 	.i_data1({sign_ext_half, out_data[31:16]}),
	// 	.i_ctrl(i_addr[1]),
	// 	.o_data(load_half_data)
	// 	);

	// // ȡ���ֽ�����
	// mux4in1 LOAD_BYTE_DATA_OP(
	// 	.i_data0({{24{sign_ext_byte0}}, out_data[ 7:0 ]}),
	// 	.i_data1({{24{sign_ext_byte1}}, out_data[15:8 ]}),
	// 	.i_data2({{24{sign_ext_byte2}}, out_data[23:16]}),
	// 	.i_data3({{24{sign_ext_byte3}}, out_data[31:24]}),
	// 	.i_ctrl(i_addr[1:0]),
	// 	.o_data(load_byte_data)
	// 	);
	
	// // ȡ����������
	// mux2in1 LOAD_HALF_DATA_OP(
	// 	.i_data0({{16{sign_ext_half0}}, out_data[15:0 ]}),
	// 	.i_data1({{16{sign_ext_half1}}, out_data[31:16]}),
	// 	// .i_data2({{16{sign_ext_half0}}, out_data[15:0 ]}),
	// 	// .i_data3({{16{sign_ext_half0}}, out_data[15:0 ]}),
	// 	.i_ctrl(i_addr[1]),
	// 	.o_data(load_half_data)
	// 	);
	
	// // �������ݿ��ѡ����ʵ�ȡ������
	// // [00] �ֽ� [01]���� [10]��
	// mux4in1 LOAD_DATA_OP(
	// 	.i_data0(load_byte_data),
	// 	.i_data1(load_half_data),
	// 	.i_data2(out_data),
	// 	.i_data3(out_data),
	// 	.i_ctrl(i_data_width),
	// 	.o_data(load_word_data)
	// 	);

	// ʹ��һ��ѡ�� ��С�ӳ�
	mux8in1 LOAD_DATA_OP(
		.i_data0({{24{sign_ext_byte0}}, out_data[ 7:0 ]}),
		.i_data1({{24{sign_ext_byte1}}, out_data[15:8 ]}),
		.i_data2({{24{sign_ext_byte2}}, out_data[23:16]}),
		.i_data3({{24{sign_ext_byte3}}, out_data[31:24]}),
		.i_data4({{16{sign_ext_byte1}}, out_data[15:0 ]}),
		.i_data5({{16{sign_ext_interface}}, i_interface_data}),
		.i_data6({{16{sign_ext_byte3}}, out_data[31:16]}),
		.i_data7(out_data),
		.i_ctrl(load_ctrl),
		.o_data(load_word_data)
		);
	
	// ѡ���д����
	// mux4in1 MEM2REG( 
	// 	.i_data0(i_addr), 
	// 	.i_data1(32'b0), 
	// 	.i_data2(out_data), 
	// 	.i_data3({16'b0, i_interface_data}), 
	// 	.i_ctrl({i_mem2reg, i_interface_read}), 
	// 	.o_data(o_mem_data)
	// 	);
	
	mux2in1 MEM2REG( 
		.i_data0(i_addr), 
		.i_data1(load_word_data), 
		.i_ctrl(i_mem2reg), 
		.o_data(o_mem_data)
		);

	// ���ݴ洢��
	ram RAM (
		.clka(clkn), 
		.addra(i_addr[15:2]), 
		.dina(store_word_data), 
		.wea(write), 
		.douta(out_data)
		);

endmodule
