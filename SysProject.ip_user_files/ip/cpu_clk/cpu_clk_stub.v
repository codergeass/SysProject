// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Mon Jan 09 17:03:50 2017
// Host        : FLY-X220 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               D:/CoderGeass/Desktop/WORK/0Work/vivado_verilog_work/SysProject/SysProject.srcs/sources_1/ip/cpu_clk/cpu_clk_stub.v
// Design      : cpu_clk
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module cpu_clk(clk_in1, clk_out1)
/* synthesis syn_black_box black_box_pad_pin="clk_in1,clk_out1" */;
  input clk_in1;
  output clk_out1;
endmodule
