vsim -novopt work.tb_dma2
view wave

add wave {sim:/tb_dma2/dmaers[1]/g/*}
add wave -divider
add wave {sim:/tb_dma2/dmaers[2]/g/*}
add wave -divider
add wave sim:/tb_dma2/*


