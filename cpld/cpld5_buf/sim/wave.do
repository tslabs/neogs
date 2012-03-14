onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb/clk20
add wave -noupdate -format Logic /tb/clk24
add wave -noupdate -format Literal /tb/clksel
add wave -noupdate -format Logic /tb/clkout
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /tb/clkin
add wave -noupdate -format Logic /tb/coldres_n
add wave -noupdate -format Logic /tb/warmres_n
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /tb/config_n
add wave -noupdate -format Logic /tb/DUT/\\config_n~reg0\\
add wave -noupdate -format Logic /tb/DUT/\\coldres_n~dataout\\
add wave -noupdate -format Logic /tb/DUT/\\d\[0\]~7\\
add wave -noupdate -format Logic /tb/DUT/\\rescfg_write_n~12\\
add wave -noupdate -format Logic /tb/status_n
add wave -noupdate -format Logic /tb/conf_done
add wave -noupdate -format Logic /tb/init_done
add wave -noupdate -format Logic /tb/cs
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /tb/mreq_n
add wave -noupdate -format Logic /tb/iorq_n
add wave -noupdate -format Logic /tb/rd_n
add wave -noupdate -format Logic /tb/wr_n
add wave -noupdate -format Literal -radix hexadecimal /tb/zaddr
add wave -noupdate -format Literal -radix hexadecimal /tb/zdata
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /tb/mema14
add wave -noupdate -format Logic /tb/mema15
add wave -noupdate -format Logic /tb/mema19
add wave -noupdate -format Logic /tb/memoe_n
add wave -noupdate -format Logic /tb/memwe_n
add wave -noupdate -format Logic /tb/romcs_n
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /tb/in_ramcs0_n
add wave -noupdate -format Logic /tb/in_ramcs1_n
add wave -noupdate -format Logic /tb/in_ramcs2_n
add wave -noupdate -format Logic /tb/in_ramcs3_n
add wave -noupdate -format Logic /tb/mema19
add wave -noupdate -format Logic /tb/out_ramcs0_n
add wave -noupdate -format Logic /tb/out_ramcs1_n
add wave -noupdate -divider <NULL>
add wave -noupdate -format Literal -radix hexadecimal /tb/mdata
add wave -noupdate -format Logic /tb/ma6
add wave -noupdate -format Logic /tb/ma7
add wave -noupdate -format Logic /tb/ma10
add wave -noupdate -format Logic /tb/ma11
add wave -noupdate -format Logic /tb/ma12
add wave -noupdate -format Logic /tb/ma13
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4645620 ps} 0}
configure wave -namecolwidth 281
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 154165
configure wave -gridperiod 100000
configure wave -griddelta 8
configure wave -timeline 1
update
WaveRestoreZoom {959450 ps} {6871047 ps}
