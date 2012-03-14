onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/rst_n
add wave -noupdate /tb/clk
add wave -noupdate -radix hexadecimal /tb/sram_addr
add wave -noupdate -radix hexadecimal /tb/sram_data
add wave -noupdate /tb/sram_cs_n
add wave -noupdate /tb/sram_oe_n
add wave -noupdate /tb/sram_we_n
add wave -noupdate /tb/main/led_diag
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {998400 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {691722134100 ps}
