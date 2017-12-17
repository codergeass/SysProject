onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib multu32x32_opt

do {wave.do}

view wave
view structure
view signals

do {multu32x32.udo}

run -all

quit -force
