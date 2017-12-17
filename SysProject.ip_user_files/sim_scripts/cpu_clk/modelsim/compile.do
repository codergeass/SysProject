vlib work
vlib msim

vlib msim/xil_defaultlib

vmap xil_defaultlib msim/xil_defaultlib

vlog -work xil_defaultlib -64 -incr \
"../../../../SysProject.srcs/sources_1/ip/cpu_clk/cpu_clk_clk_wiz.v" \
"../../../../SysProject.srcs/sources_1/ip/cpu_clk/cpu_clk.v" \


vlog -work xil_defaultlib "glbl.v"

