quit -sim

vlog -incr tb_4way.v
vlog -incr dma_tester.v

vlog -incr ../dma_sequencer2.v
vlog -incr ../dma_access.v

vlog -incr ../sim_models/ram.v
vlog -incr ../sim_models/rom.v

vcom ../sim_models/T80_Pack.vhd
vcom ../sim_models/T80_MCode.vhd
vcom ../sim_models/T80_Reg.vhd
# vcom ../sim_models/T80_RegX.vhd
vcom ../sim_models/T80a.vhd
vcom ../sim_models/t80.vhd



vsim -novopt work.tb

do wave.do

