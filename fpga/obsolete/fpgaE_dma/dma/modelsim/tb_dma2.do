vsim -novopt work.tb_dma1
view wave

add wave sim:/tb_dma1/rst_n
add wave sim:/tb_dma1/clk
add wave sim:/tb_dma1/iorq_n
add wave sim:/tb_dma1/mreq_n
add wave sim:/tb_dma1/rd_n
add wave sim:/tb_dma1/wr_n
add wave sim:/tb_dma1/busrq_n
add wave sim:/tb_dma1/busak_n
add wave -hexadecimal sim:/tb_dma1/zaddr
add wave -hexadecimal sim:/tb_dma1/zdata
add wave sim:/tb_dma1/myram/ce_n
add wave sim:/tb_dma1/myram/oe_n
add wave sim:/tb_dma1/myram/we_n

add wave -divider

add wave sim:/tb_dma1/mydma/dma_req
add wave sim:/tb_dma1/mydma/dma_rnw
add wave sim:/tb_dma1/mydma/dma_busynready
add wave sim:/tb_dma1/mydma/dma_ack
add wave sim:/tb_dma1/mydma/dma_end
add wave sim:/tb_dma1/mydma/mem_dma_bus
add wave -hexadecimal sim:/tb_dma1/mydma/dma_addr
add wave -hexadecimal sim:/tb_dma1/mydma/dma_wd
add wave -hexadecimal sim:/tb_dma1/mydma/dma_rd

run
run
