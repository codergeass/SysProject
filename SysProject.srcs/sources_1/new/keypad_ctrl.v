`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/30 10:37:53
// Design Name: 
// Module Name: keypad_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 4x4���̿�����
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module keypad_ctrl(
	i_clk,
//	i_scanclk,
	i_rstn,
	i_re,
	i_op,
	i_inta,
	i_col,
	o_row,
	o_ir,
	o_data
	);
	input	i_clk;
//	input	i_scanclk;
	input	i_rstn;
	input	i_re;				// ��ʹ��
	input	i_inta;				// �ж���Ӧ
	
	input	[3:0] i_col;			// ���̽���
	output	[3:0] o_row;			// ���̽���

	input	i_op;				// ���Ĵ���ѡ��

	output	o_ir;
	
	output	[15:0] o_data;

	reg		readstatus;			// ��״̬�Ĵ����ź�����
	reg		readreset;			// ��״̬�Ĵ��������ź�

	wire	[15:0] key_data;		// ��ֵ�Ĵ���
	wire	[15:0] key_sta;		// ״̬�Ĵ��� 1��ʾ�а�������

	wire	key_down;
	wire	scan_clk;
	wire	ir;

	wire	[3:0] key_val;
	
	assign	o_data = i_re ? (i_op ? key_sta : key_data) : 16'b0;
	
	// assign	o_ir = key_sta[0];

//	// �ж������źŲ����븴λ
//	// ��ʱ���½��ز���
//	always @(negedge i_clk or posedge i_rstn) begin
//		if (~i_rstn) begin
//			o_ir	<= 1'b0;
//		end
//		else begin
//			if (i_inta) begin
//				o_ir	<= 1'b0;
//			end 
//			else if (ir) begin
//				o_ir	<= 1'b1;
//			end
			
//		end
//	end
	
	always @(posedge i_clk or negedge i_rstn) begin
		if (~i_rstn) begin
			// reset
			readstatus	<= 1'b0;
			readreset	<= 1'b0;
		end
		else if (i_re & i_op) begin
			readstatus	<= 1'b1;
			readreset	<= readstatus;
		end
		else begin
			readstatus	<= 1'b0;
			readreset	<= readstatus;
		end
	end

	// ��ֵ�Ĵ���
	assign key_data = {12'b0, key_val};
	// dffe16	VAL_REG(
	// 	.i_clk(i_clk),
	// 	.i_rstn(i_rstn),
	// 	.i_we(i_we),
	// 	.i_data(i_data),
	// 	.o_data(key_data)
	// 	);

	// ״̬�Ĵ���
	assign key_sta = readreset ? 16'b0 : {15'b0, key_down};
	//  dffe16	STA_REG(
	//  	.i_clk(i_clk),
	//  	.i_rstn(i_rstn),
	//  	.i_we(i_we),
	//  	.i_data({15'b0, key_down}),
	//  	.o_data(key_sta)
	//  	);

	// ��Ƶ��230Hz
	clk_div #(.COUNT(50000)) CLK_DIV(
		.i_clk(i_clk),
		.i_rstn(i_rstn),
		.o_clk(scan_clk)
		);

	// ɨ�����
	key4x4_scan KEY_SCAN(
		.i_clk(i_clk),
		.i_scanclk(scan_clk),
//		.i_scanclk(i_clk),	//sim
		// .i_rstn(i_rstn),
		.i_readreset(readreset),
		.i_col(i_col),
		.o_row(o_row),
		.o_ir(o_ir),
		.o_key_down(key_down),
		.o_key_val(key_val)
		);

endmodule


module key4x4_scan(
	i_clk,
	i_scanclk,
	i_readreset,
	i_col,
	o_row,
	o_ir,
	o_key_down,
	o_key_val
	);
	
	input	i_clk;						// IO ʱ��
	input	i_scanclk;					// ɨ��ʱ��
	input	i_readreset;				// ������״̬��λ

	input	[3:0] i_col;
	output	reg o_ir = 0;
	output	reg o_key_down;				// �а��������ź�	
	output	reg [3:0] o_row;				// �Ӽ��� ѡ����
	output	reg [3:0] o_key_val;			// ��ֵ

	reg		[ 1:0] state = 2'b0;			// ɨ��״̬ 00 01 10 11

	always @(posedge i_scanclk) begin
		case(state)
			2'b00: begin
				o_row	<= 4'b1110;
				state	<= 2'b01;
				case(i_col)
					4'b1110:	begin	o_key_down	<= 1'b1; o_key_val	<= 4'h1; o_ir = 1'b1;	end
					4'b1101:	begin	o_key_down	<= 1'b1; o_key_val	<= 4'h2; o_ir = 1'b1;	end
					4'b1011:	begin	o_key_down	<= 1'b1; o_key_val	<= 4'h3; o_ir = 1'b1;	end
					4'b0111:	begin	o_key_down	<= 1'b1; o_key_val	<= 4'ha; o_ir = 1'b1;	end
					default:	begin	o_ir <= 1'b0;	o_key_down	<= 1'b0; end
				endcase
			end
			2'b01: begin
				o_row	<= 4'b1101;
				state	<= 2'b10;
				case(i_col)
					4'b1110:	begin	o_key_down	<= 1'b1; o_key_val	<= 4'h4; o_ir = 1'b1;	end
					4'b1101:	begin	o_key_down	<= 1'b1; o_key_val	<= 4'h5; o_ir = 1'b1;	end
					4'b1011:	begin	o_key_down	<= 1'b1; o_key_val	<= 4'h6; o_ir = 1'b1;	end
					4'b0111:	begin	o_key_down	<= 1'b1; o_key_val	<= 4'hb; o_ir = 1'b1;	end
					default:	begin	o_ir <= 1'b0;	o_key_down	<= 1'b0; end
					// default:	begin	o_key_down	<= 1'b0; end
				endcase
			end
			2'b10: begin
				o_row	<= 4'b1011;
				state	<= 2'b11;
				case(i_col)
					4'b1110:	begin	o_key_down	<= 1'b1; o_key_val	<= 4'h7; o_ir = 1'b1;	end
					4'b1101:	begin	o_key_down	<= 1'b1; o_key_val	<= 4'h8; o_ir = 1'b1;	end
					4'b1011:	begin	o_key_down	<= 1'b1; o_key_val	<= 4'h9; o_ir = 1'b1;	end
					4'b0111:	begin	o_key_down	<= 1'b1; o_key_val	<= 4'hc; o_ir = 1'b1;	end
					default:	begin	o_ir <= 1'b0;	o_key_down	<= 1'b0; end
					// default:	begin	o_key_down	<= 1'b0; end
				endcase
			end
			2'b11: begin
				o_row	<= 4'b0111;
				state	<= 2'b00;
				case(i_col)
					4'b1110:	begin	o_key_down	<= 1'b1; o_key_val	<= 4'h0; o_ir = 1'b1;	end
					4'b1101:	begin	o_key_down	<= 1'b1; o_key_val	<= 4'hf; o_ir = 1'b1;	end
					4'b1011:	begin	o_key_down	<= 1'b1; o_key_val	<= 4'he; o_ir = 1'b1;	end
					4'b0111:	begin	o_key_down	<= 1'b1; o_key_val	<= 4'hd; o_ir = 1'b1;	end
					default:	begin	o_ir <= 1'b0;	o_key_down	<= 1'b0; end
					// default:	begin	o_key_down	<= 1'b0; end
				endcase
			end
		endcase
	end

endmodule

// module key4x4_scan(
// 	// i_clk,
// 	i_scanclk,
// 	i_rstn,
// 	i_readreset,
// 	i_col,
// 	o_row,
// 	o_ir,
// 	o_key_down,
// 	o_key_val
// 	);
// 	// input	i_clk;
// 	input	i_scanclk;
// 	input	i_rstn;
// 	input	i_readreset;				// ������״̬��λ

// 	input	[3:0] i_col;
// 	output	reg o_ir;
// 	output	reg o_key_down;				// �а��������ź�	
// 	output	reg [3:0] o_row;			// �Ӽ��� ѡ����
// 	output	reg [3:0] o_key_val;		// ��ֵ

// 	reg		[ 1:0] state;				// ɨ��״̬ 00 01 10 11
// 	reg		[ 3:0] r_col;				// col�ź����� �����ж����ȶ����°���
// 	reg		[19:0] delay_cnt;			// ��ʱɨ��

// 	localparam DELAY_MAX = 400000;		// ��ʱɨ����� ��Լ20ms

// 	always @(posedge i_scanclk or negedge i_rstn) begin
// 		if (~i_rstn) begin
// 			o_ir		<= 1'b0;
// 			o_key_down	<= 1'b0;
// 			state		<= 2'b0;
// 			r_col		<= 4'h0;
// 			delay_cnt	<= 16'b0;
// 		end
// 		else if (i_readreset) begin
// 			o_key_down	<= 1'b0;
// 		end
// 		else begin
// 			case(state)
// 				2'b00: begin
// 					o_row	<= 4'b1110;
// 					case(i_col)
// 						4'b1110:	begin
// 								// o_key_down	<= 1'b1; o_key_val	<= 4'h1; o_ir = 1'b1;
// 								if (r_col == 4'b1110) begin
// 									if (delay_cnt >= DELAY_MAX) begin
// 										o_ir 		<= 1'b1;
// 										o_key_down	<= 1'b1; 
// 										o_key_val	<= 4'h1; 
// 										state		<= 2'b01;
// 										r_col		<= 4'b0;
// 										delay_cnt	<= 16'b0;
// 									end else begin
// 										delay_cnt	<= delay_cnt+1;
// 									end
// 								end
// 								else if (delay_cnt == 16'b0)begin
// 									r_col <= 4'b1110;
// 								end
// 								else begin
// 									o_ir		<= 1'b0;
// 									delay_cnt	<= 16'b0;
// 									state		<= 2'b01;
// 								end
// 							end
// 						4'b1101:	begin
// 								// o_key_down	<= 1'b1; o_key_val	<= 4'h2; o_ir = 1'b1;
// 								if (r_col == 4'b1101) begin
// 									if (delay_cnt >= DELAY_MAX) begin
// 										o_ir 		<= 1'b1;
// 										o_key_down	<= 1'b1; 
// 										o_key_val	<= 4'h2; 
// 										state		<= 2'b01;
// 										r_col		<= 4'b0;
// 										delay_cnt	<= 16'b0;
// 									end else begin
// 										delay_cnt	<= delay_cnt+1;
// 									end
// 								end
// 								else if (delay_cnt == 16'b0)begin
// 									r_col <= 4'b1101;
// 								end
// 								else begin
// 									o_ir		<= 1'b0;
// 									delay_cnt	<= 16'b0;
// 									state		<= 2'b01;
// 								end
// 							end
// 						4'b1011:	begin
// 							// o_key_down	<= 1'b1; o_key_val	<= 4'h3; o_ir = 1'b1;
// 								if (r_col == 4'b1011) begin
// 									if (delay_cnt >= DELAY_MAX) begin
// 										o_ir 		<= 1'b1;
// 										o_key_down	<= 1'b1; 
// 										o_key_val	<= 4'h3; 
// 										state		<= 2'b01;
// 										r_col		<= 4'b0;
// 										delay_cnt	<= 16'b0;
// 									end else begin
// 										delay_cnt	<= delay_cnt+1;
// 									end
// 								end
// 								else if (delay_cnt == 16'b0)begin
// 									r_col <= 4'b1011;
// 								end
// 								else begin
// 									o_ir		<= 1'b0;
// 									delay_cnt	<= 16'b0;
// 									state		<= 2'b01;
// 								end
// 							end
// 						4'b0111:	begin
// 							// o_key_down	<= 1'b1; o_key_val	<= 4'ha; o_ir = 1'b1;
// 								if (r_col == 4'b0111) begin
// 									if (delay_cnt >= DELAY_MAX) begin
// 										o_ir 		<= 1'b1;
// 										o_key_down	<= 1'b1; 
// 										o_key_val	<= 4'ha; 
// 										state		<= 2'b01;
// 										r_col		<= 4'b0;
// 										delay_cnt	<= 16'b0;
// 									end else begin
// 										delay_cnt	<= delay_cnt+1;
// 									end
// 								end
// 								else if (delay_cnt == 16'b0)begin
// 									r_col <= 4'b0111;
// 								end
// 								else begin
// 									o_ir		<= 1'b0;
// 									delay_cnt	<= 16'b0;
// 									state		<= 2'b01;
// 								end
// 							end
// 						default:	begin
// 								r_col		<= 4'b0;
// 								o_ir		<= 1'b0;
// 								delay_cnt	<= 16'b0;
// 								state		<= 2'b01;
// 							end
// 						// default:	begin	o_key_down	<= 1'b0; end
// 					endcase
// 				end
// 				2'b01: begin
// 					o_row	<= 4'b1101;
// 					// state	<= 2'b10;
// 					// case(i_col)
// 					// 	4'b1110:	begin	o_key_down	<= 1'b1; o_key_val	<= 4'h4; o_ir = 1'b1;	end
// 					// 	4'b1101:	begin	o_key_down	<= 1'b1; o_key_val	<= 4'h5; o_ir = 1'b1;	end
// 					// 	4'b1011:	begin	o_key_down	<= 1'b1; o_key_val	<= 4'h6; o_ir = 1'b1;	end
// 					// 	4'b0111:	begin	o_key_down	<= 1'b1; o_key_val	<= 4'hb; o_ir = 1'b1;	end
// 					// 	default:	o_ir <= 1'b0;
// 					// 	// default:	begin	o_key_down	<= 1'b0; end
// 					case(i_col)
// 						4'b1110:	begin
// 								// o_key_down	<= 1'b1; o_key_val	<= 4'h1; o_ir = 1'b1;
// 								if (r_col == 4'b1110) begin
// 									if (delay_cnt >= DELAY_MAX) begin
// 										o_ir 		<= 1'b1;
// 										o_key_down	<= 1'b1; 
// 										o_key_val	<= 4'h4; 
// 										state		<= 2'b10;
// 										r_col		<= 4'b0;
// 										delay_cnt	<= 16'b0;
// 									end else begin
// 										delay_cnt	<= delay_cnt+1;
// 									end
// 								end
// 								else if (delay_cnt == 16'b0)begin
// 									r_col <= 4'b1110;
// 								end
// 								else begin
// 									o_ir		<= 1'b0;
// 									delay_cnt	<= 16'b0;
// 									state		<= 2'b10;
// 								end
// 							end
// 						4'b1101:	begin
// 								// o_key_down	<= 1'b1; o_key_val	<= 4'h2; o_ir = 1'b1;
// 								if (r_col == 4'b1101) begin
// 									if (delay_cnt >= DELAY_MAX) begin
// 										o_ir 		<= 1'b1;
// 										o_key_down	<= 1'b1; 
// 										o_key_val	<= 4'h5; 
// 										state		<= 2'b10;
// 										r_col		<= 4'b0;
// 										delay_cnt	<= 16'b0;
// 									end else begin
// 										delay_cnt	<= delay_cnt+1;
// 									end
// 								end
// 								else if (delay_cnt == 16'b0)begin
// 									r_col <= 4'b1101;
// 								end
// 								else begin
// 									o_ir		<= 1'b0;
// 									delay_cnt	<= 16'b0;
// 									state		<= 2'b10;
// 								end
// 							end
// 						4'b1011:	begin
// 							// o_key_down	<= 1'b1; o_key_val	<= 4'h3; o_ir = 1'b1;
// 								if (r_col == 4'b1011) begin
// 									if (delay_cnt >= DELAY_MAX) begin
// 										o_ir 		<= 1'b1;
// 										o_key_down	<= 1'b1; 
// 										o_key_val	<= 4'h6; 
// 										state		<= 2'b10;
// 										r_col		<= 4'b0;
// 										delay_cnt	<= 16'b0;
// 									end else begin
// 										delay_cnt	<= delay_cnt+1;
// 									end
// 								end
// 								else if (delay_cnt == 16'b0)begin
// 									r_col <= 4'b1011;
// 								end
// 								else begin
// 									o_ir		<= 1'b0;
// 									delay_cnt	<= 16'b0;
// 									state		<= 2'b10;
// 								end
// 							end
// 						4'b0111:	begin
// 							// o_key_down	<= 1'b1; o_key_val	<= 4'ha; o_ir = 1'b1;
// 								if (r_col == 4'b0111) begin
// 									if (delay_cnt >= DELAY_MAX) begin
// 										o_ir 		<= 1'b1;
// 										o_key_down	<= 1'b1; 
// 										o_key_val	<= 4'hb; 
// 										state		<= 2'b10;
// 										r_col		<= 4'b0;
// 										delay_cnt	<= 16'b0;
// 									end else begin
// 										delay_cnt	<= delay_cnt+1;
// 									end
// 								end
// 								else if (delay_cnt == 16'b0)begin
// 									r_col <= 4'b0111;
// 								end
// 								else begin
// 									o_ir		<= 1'b0;
// 									delay_cnt	<= 16'b0;
// 									state		<= 2'b01;
// 								end
// 							end
// 						default:	begin
// 								r_col		<= 4'b0;
// 								o_ir		<= 1'b0;
// 								delay_cnt	<= 16'b0;
// 								state		<= 2'b10;
// 							end
// 						// default:	begin	o_key_down	<= 1'b0; end
// 					endcase
// 				end
// 				2'b10: begin
// 					o_row	<= 4'b1011;
// 					// state	<= 2'b11;
// 					// case(i_col)
// 					// 	4'b1110:	begin	o_key_down	<= 1'b1; o_key_val	<= 4'h7; o_ir = 1'b1;	end
// 					// 	4'b1101:	begin	o_key_down	<= 1'b1; o_key_val	<= 4'h8; o_ir = 1'b1;	end
// 					// 	4'b1011:	begin	o_key_down	<= 1'b1; o_key_val	<= 4'h9; o_ir = 1'b1;	end
// 					// 	4'b0111:	begin	o_key_down	<= 1'b1; o_key_val	<= 4'hc; o_ir = 1'b1;	end
// 					// 	default:	o_ir <= 1'b0;
// 					// 	// default:	begin	o_key_down	<= 1'b0; end
// 					// endcase
// 					case(i_col)
// 						4'b1110:	begin
// 								// o_key_down	<= 1'b1; o_key_val	<= 4'h1; o_ir = 1'b1;
// 								if (r_col == 4'b1110) begin
// 									if (delay_cnt >= DELAY_MAX) begin
// 										o_ir 		<= 1'b1;
// 										o_key_down	<= 1'b1; 
// 										o_key_val	<= 4'h7; 
// 										state		<= 2'b11;
// 										r_col		<= 4'b0;
// 										delay_cnt	<= 16'b0;
// 									end else begin
// 										delay_cnt	<= delay_cnt+1;
// 									end
// 								end
// 								else if (delay_cnt == 16'b0)begin
// 									r_col <= 4'b1110;
// 								end
// 								else begin
// 									o_ir		<= 1'b0;
// 									delay_cnt	<= 16'b0;
// 									state		<= 2'b11;
// 								end
// 							end
// 						4'b1101:	begin
// 								// o_key_down	<= 1'b1; o_key_val	<= 4'h2; o_ir = 1'b1;
// 								if (r_col == 4'b1101) begin
// 									if (delay_cnt >= DELAY_MAX) begin
// 										o_ir 		<= 1'b1;
// 										o_key_down	<= 1'b1; 
// 										o_key_val	<= 4'h8; 
// 										state		<= 2'b11;
// 										r_col		<= 4'b0;
// 										delay_cnt	<= 16'b0;
// 									end else begin
// 										delay_cnt	<= delay_cnt+1;
// 									end
// 								end
// 								else if (delay_cnt == 16'b0)begin
// 									r_col <= 4'b1101;
// 								end
// 								else begin
// 									o_ir		<= 1'b0;
// 									delay_cnt	<= 16'b0;
// 									state		<= 2'b11;
// 								end
// 							end
// 						4'b1011:	begin
// 							// o_key_down	<= 1'b1; o_key_val	<= 4'h3; o_ir = 1'b1;
// 								if (r_col == 4'b1011) begin
// 									if (delay_cnt >= DELAY_MAX) begin
// 										o_ir 		<= 1'b1;
// 										o_key_down	<= 1'b1; 
// 										o_key_val	<= 4'h9; 
// 										state		<= 2'b11;
// 										r_col		<= 4'b0;
// 										delay_cnt	<= 16'b0;
// 									end else begin
// 										delay_cnt	<= delay_cnt+1;
// 									end
// 								end
// 								else if (delay_cnt == 16'b0)begin
// 									r_col <= 4'b1011;
// 								end
// 								else begin
// 									o_ir		<= 1'b0;
// 									delay_cnt	<= 16'b0;
// 									state		<= 2'b11;
// 								end
// 							end
// 						4'b0111:	begin
// 							// o_key_down	<= 1'b1; o_key_val	<= 4'ha; o_ir = 1'b1;
// 								if (r_col == 4'b0111) begin
// 									if (delay_cnt >= DELAY_MAX) begin
// 										o_ir 		<= 1'b1;
// 										o_key_down	<= 1'b1; 
// 										o_key_val	<= 4'hc; 
// 										state		<= 2'b11;
// 										r_col		<= 4'b0;
// 										delay_cnt	<= 16'b0;
// 									end else begin
// 										delay_cnt	<= delay_cnt+1;
// 									end
// 								end
// 								else if (delay_cnt == 16'b0)begin
// 									r_col <= 4'b0111;
// 								end
// 								else begin
// 									o_ir		<= 1'b0;
// 									delay_cnt	<= 16'b0;
// 									state		<= 2'b11;
// 								end
// 							end
// 						default:	begin
// 								r_col		<= 4'b0;
// 								o_ir		<= 1'b0;
// 								delay_cnt	<= 16'b0;
// 								state		<= 2'b11;
// 							end
// 						// default:	begin	o_key_down	<= 1'b0; end
// 					endcase
// 				end
// 				2'b11: begin
// 					o_row	<= 4'b0111;
// 					// state	<= 2'b00;
// 					// case(i_col)
// 					// 	4'b1110:	begin	o_key_down	<= 1'b1; o_key_val	<= 4'h0; o_ir = 1'b1;	end
// 					// 	4'b1101:	begin	o_key_down	<= 1'b1; o_key_val	<= 4'hf; o_ir = 1'b1;	end
// 					// 	4'b1011:	begin	o_key_down	<= 1'b1; o_key_val	<= 4'he; o_ir = 1'b1;	end
// 					// 	4'b0111:	begin	o_key_down	<= 1'b1; o_key_val	<= 4'hd; o_ir = 1'b1;	end
// 					// 	default:	o_ir <= 1'b0;
// 					// 	// default:	begin	o_key_down	<= 1'b0; end
// 					// endcase
// 					case(i_col)
// 						4'b1110:	begin
// 								// o_key_down	<= 1'b1; o_key_val	<= 4'h1; o_ir = 1'b1;
// 								if (r_col == 4'b1110) begin
// 									if (delay_cnt >= DELAY_MAX) begin
// 										o_ir 		<= 1'b1;
// 										o_key_down	<= 1'b1; 
// 										o_key_val	<= 4'h0; 
// 										state		<= 2'b00;
// 										r_col		<= 4'b0;
// 										delay_cnt	<= 16'b0;
// 									end else begin
// 										delay_cnt	<= delay_cnt+1;
// 									end
// 								end
// 								else if (delay_cnt == 16'b0)begin
// 									r_col <= 4'b1110;
// 								end
// 								else begin
// 									o_ir		<= 1'b0;
// 									delay_cnt	<= 16'b0;
// 									state		<= 2'b00;
// 								end
// 							end
// 						4'b1101:	begin
// 								// o_key_down	<= 1'b1; o_key_val	<= 4'h2; o_ir = 1'b1;
// 								if (r_col == 4'b1101) begin
// 									if (delay_cnt >= DELAY_MAX) begin
// 										o_ir 		<= 1'b1;
// 										o_key_down	<= 1'b1; 
// 										o_key_val	<= 4'hf; 
// 										state		<= 2'b00;
// 										r_col		<= 4'b0;
// 										delay_cnt	<= 16'b0;
// 									end else begin
// 										delay_cnt	<= delay_cnt+1;
// 									end
// 								end
// 								else if (delay_cnt == 16'b0)begin
// 									r_col <= 4'b1101;
// 								end
// 								else begin
// 									o_ir		<= 1'b0;
// 									delay_cnt	<= 16'b0;
// 									state		<= 2'b00;
// 								end
// 							end
// 						4'b1011:	begin
// 							// o_key_down	<= 1'b1; o_key_val	<= 4'h3; o_ir = 1'b1;
// 								if (r_col == 4'b1011) begin
// 									if (delay_cnt >= DELAY_MAX) begin
// 										o_ir 		<= 1'b1;
// 										o_key_down	<= 1'b1; 
// 										o_key_val	<= 4'he; 
// 										state		<= 2'b00;
// 										r_col		<= 4'b0;
// 										delay_cnt	<= 16'b0;
// 									end else begin
// 										delay_cnt	<= delay_cnt+1;
// 									end
// 								end
// 								else if (delay_cnt == 16'b0)begin
// 									r_col <= 4'b1011;
// 								end
// 								else begin
// 									o_ir		<= 1'b0;
// 									delay_cnt	<= 16'b0;
// 									state		<= 2'b00;
// 								end
// 							end
// 						4'b0111:	begin
// 							// o_key_down	<= 1'b1; o_key_val	<= 4'ha; o_ir = 1'b1;
// 								if (r_col == 4'b0111) begin
// 									if (delay_cnt >= DELAY_MAX) begin
// 										o_ir 		<= 1'b1;
// 										o_key_down	<= 1'b1; 
// 										o_key_val	<= 4'hd; 
// 										state		<= 2'b00;
// 										r_col		<= 4'b0;
// 										delay_cnt	<= 16'b0;
// 									end else begin
// 										delay_cnt	<= delay_cnt+1;
// 									end
// 								end
// 								else if (delay_cnt == 16'b0)begin
// 									r_col <= 4'b0111;
// 								end
// 								else begin
// 									o_ir		<= 1'b0;
// 									delay_cnt	<= 16'b0;
// 									state		<= 2'b00;
// 								end
// 							end
// 						default:	begin
// 								r_col		<= 4'b0;
// 								o_ir		<= 1'b0;
// 								delay_cnt	<= 16'b0;
// 								state		<= 2'b00;
// 							end
// 						// default:	begin	o_key_down	<= 1'b0; end
// 					endcase
// 				end
// 			endcase
// 		end
// 		//////////////////////////////////////////////////////
		
// 	end

// endmodule
