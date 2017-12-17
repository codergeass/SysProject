`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/01/04 09:35:15
// Design Name: 
// Module Name: int_ctrl_sim
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


module int_ctrl_sim(

    );
    reg i_clk = 0;
    reg i_rstn = 0;
    reg i_inta = 0;
    reg i_ir0 = 0;
    reg i_ir1 = 0;
    reg i_ir2 = 0;
    reg i_ir3 = 0;
    reg i_ir4 = 0;
    reg i_ir5 = 0;
    
    reg [5:0] i_int_source = 0;
    
    wire o_inta0;
    wire o_inta1;
    wire o_inta2;
    wire o_inta3;
    wire o_inta4;
    wire o_inta5;
    
    wire o_intr;
    wire [5:0] o_int_source;
    
    int_ctrl INT_CTRL_TEST(
    	i_clk,
    	i_rstn,
    	i_inta,
    	i_int_source,
    	i_ir0,
    	i_ir1,
    	i_ir2,
    	i_ir3,
    	i_ir4,
    	i_ir5,
    	o_inta0,
    	o_inta1,
    	o_inta2,
    	o_inta3,
    	o_inta4,
    	o_inta5,
    	o_intr,
    	o_int_source
    	);
    	
    initial begin
    	#5 i_rstn = 1;
    	#15
    	#5  i_ir0 = 1;
    	#10	i_inta = 1; i_int_source = 5'b1;
    	#10 i_inta = 0; i_int_source = 5'b0;
    end
    
    always #5 i_clk = ~i_clk;
endmodule
