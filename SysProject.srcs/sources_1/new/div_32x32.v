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
// 32λ������ 
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
	input	i_sign;					// �з��������ʶ	
	input	i_start;				// ��ʼ�ź�	
	input	[31:0] i_data0;			// ������
	input	[31:0] i_data1;			// ����

	output	o_ready;				// �����������״̬ ���ڿ��Ƶ����������
	
	output	[31:0] o_quotient;		// ��
	output	[31:0] o_remainder;		// ����
	
	reg	[64:0]	dividend;			// ����������չ�ı�����
	reg	[64:0]	divisor;			// ��������ĳ���
	reg	[31:0]	quotient;			// �����������
	reg	[ 5:0]	count;				// ������������
	
	reg	r_sign;						// ���ݱ������Ƿ��з��ž��������ķ���
	reg	sign_diff;					// ���ݳ����ͱ��������ž����̵ķ���
	reg finish;						// ������������ź�

	wire [31:0]	data0;				// ȥ���ű�����
	wire [31:0]	data1;				// ȥ���ų���
	wire [64:0] sub_remainder;		// ��������ȥ������Ĳ�������
	
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
			if (o_ready & i_start) begin					// ���������ʼ��
				count		<= 33;						// ����������ʼ��
				quotient	<= 0;						// �̳�ʼ��
				dividend	<= {33'b0, data0};			// �Ա�����������չ
				divisor		<= {1'b0, data1, 32'b0};		// �Գ���������λ����չ
				r_sign		<= i_data0[31] & i_sign;
				sign_diff	<= i_data0[31]^i_data1[31] & i_sign;
				finish		<= 0;
			end
			else if(~finish & o_ready) begin				// �����������
				if(sign_diff)							// �������޷��� �õ���ȷ�Ľ��
					quotient <= (~quotient) + 1;
				if(r_sign)
					dividend[31:0] <= (~dividend[31:0]) + 1;
				finish		<= 1;
			end
			else if (~o_ready) begin						// ���ν��е���
				if(sub_remainder[64]==1) begin			// ������������Ǹ���
					quotient <= (quotient<<1);			// �����µ����еĲ���������������
				end
				else begin
					dividend <= sub_remainder;
					quotient <= (quotient<<1) + 1;
				end
									
				divisor	<= divisor>>1;
				count <= count - 1;						// ����32��
			end
		end
	end


endmodule
