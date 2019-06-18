onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib CGROM_opt

do {wave.do}

view wave
view structure
view signals

do {CGROM.udo}

run -all

quit -force
