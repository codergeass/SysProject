`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/22 09:47:46
// Design Name: 
// Module Name: fetch_sim
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


module fetch_sim(
	);
	//input
	reg clk = 0;
	reg rstn = 0;
	reg pc_we = 0;
	reg [1:0] pc_src = 2'b00;
	reg [31:0] next_pc = 8'h00000000;
	reg [31:0] eret_pc = 8'h00000000;
	reg [31:0] excep_pc = 8'h00000000;
	
	//output
	wire [31:0] pc;
	wire [31:0] inner_pc;
	wire [31:0] pc_plus4;
	wire [31:0] instr;
	
	
	//instantiate the Unit under test
	fetch FETCH(
			.i_clk(clk),
			.i_rstn(rstn),
			.i_pc_src(pc_src),
			.i_pc_write(pc_we),
			.i_next_pc(next_pc),
			.i_eret_pc(eret_pc),
			.i_excep_pc(excep_pc),
			.o_pc(pc),
			.o_inner_pc(inner_pc),
			.o_pc_plus4(pc_plus4),
			.o_instr(instr)
			);
	
	initial begin
		#25 rstn = 1; pc_we = 1;
		#200 next_pc = 8'h00004;
		#25 pc_src = 2'b01;
		#50 pc_src = 2'b00;
		#200 eret_pc = 8'h00004;
		#50 pc_src = 2'b10;
		#50 pc_src = 2'b00;
		#200 excep_pc = 8'h00004;
		#50 pc_src = 2'b11;
		#50 pc_src = 2'b00;
	end
	
	always #25 clk = ~clk;
endmodule
