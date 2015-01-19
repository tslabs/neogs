onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color {Violet Red} -format Logic /tb/rst_n
add wave -noupdate -format Literal -radix hexadecimal /tb/zdata
add wave -noupdate -format Literal -radix hexadecimal /tb/zaddr
add wave -noupdate -format Logic /tb/rd_n
add wave -noupdate -format Logic /tb/wr_n
add wave -noupdate -format Logic /tb/mreq_n
add wave -noupdate -format Logic /tb/iorq_n
add wave -noupdate -format Logic /tb/busrq_n
add wave -noupdate -format Logic /tb/busak_n
add wave -noupdate -color Magenta -format Logic /tb/mem_dma_bus
add wave -noupdate -color Magenta -format Literal -radix hexadecimal /tb/mem_dma_addr
add wave -noupdate -color Magenta -format Literal -radix hexadecimal /tb/mem_dma_wd
add wave -noupdate -color Magenta -format Literal -radix hexadecimal /tb/mem_dma_rd
add wave -noupdate -color Magenta -format Logic /tb/mem_dma_oe
add wave -noupdate -color Magenta -format Logic /tb/mem_dma_we
add wave -noupdate -color Gold -format Logic /tb/clk
add wave -noupdate -color Cyan -format Logic /tb/dma_req
add wave -noupdate -color Cyan -format Logic /tb/dma_rnw
add wave -noupdate -color Cyan -format Logic /tb/dma_ack
add wave -noupdate -color Cyan -format Logic /tb/dma_end
add wave -noupdate -color Cyan -format Literal -radix hexadecimal /tb/dma_addr
add wave -noupdate -color Cyan -format Literal -radix hexadecimal /tb/dma_wd
add wave -noupdate -color Cyan -format Literal -radix hexadecimal /tb/dma_rd
add wave -noupdate -format Logic /tb/mytest/first
add wave -noupdate -format Logic /tb/mytest/idle
add wave -noupdate -format Literal -radix hexadecimal /tb/mytest/wr_ptr
add wave -noupdate -format Literal -radix hexadecimal /tb/mytest/rd_ptr
add wave -noupdate -color Coral -format Literal -expand /tb/req
add wave -noupdate -color Coral -format Literal /tb/rnw
add wave -noupdate -color Coral -format Literal -radix binary -expand /tb/ack
add wave -noupdate -color Coral -format Literal -expand /tb/done
add wave -noupdate -color Coral -format Literal -radix hexadecimal /tb/addr
add wave -noupdate -color Coral -format Literal -radix hexadecimal /tb/wd
add wave -noupdate -color Coral -format Literal -radix hexadecimal /tb/rd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {529204 ns} 0}
configure wave -namecolwidth 164
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 20
configure wave -gridperiod 40
configure wave -griddelta 10
configure wave -timeline 0
update
WaveRestoreZoom {1053388 ns} {1054516 ns}
