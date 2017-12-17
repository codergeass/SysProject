vlib work
vlib msim

vlib msim/blk_mem_gen_v8_3_1
vlib msim/xil_defaultlib

vmap blk_mem_gen_v8_3_1 msim/blk_mem_gen_v8_3_1
vmap xil_defaultlib msim/xil_defaultlib

vcom -work blk_mem_gen_v8_3_1 -64 -93 \
"../../../ipstatic/blk_mem_gen_v8_3_1/simulation/blk_mem_gen_v8_3.vhd" \

vcom -work xil_defaultlib -64 -93 \
"../../../../SysProject.srcs/sources_1/ip/prg_rom_1/sim/prg_rom.vhd" \

