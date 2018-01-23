
setactivelib -work
quiet on

vlcomp -dbg "$dsn/../tb.sv"
vlcomp -dbg "$dsn/../../top.sv"
asim -advdataflow -t ps -cc -cc_dest $dsn/coverage -cc_hierarchy -cc_all tb

wave

// Clocks
wave /clk_fpga
//wave /clk_24mhz

// ZX-BUS
//wave /top/port_we
//wave /top/zxa
//wave /top/zxid
//wave /top/zxiorq_n
//wave /top/zxwr_n
//wave /top/rsel

// HUS FSM
wave /top/fsm_en
wave /top/fsm_state

wave /top/ch_addr
wave /top/ch_rreg
wave /top/ch_rdat

wave /top/st_addr
wave /top/st_rreg
wave /top/st_rdat
wave /top/st_waddr
wave /top/st_wdat
wave /top/st_we

wave /top/cur_addr
wave /top/mf_req
wave /top/ch_inc
wave /top/st_sub_addr
//wave /top/addr_inc_raw
wave /top/addr_inc
wave /top/sub_addr_new
wave /top/sa_ovf_f
wave /top/beg_addr
wave /top/end_addr
//wave /top/new_addr_raw
wave /top/na_ovf_f
//wave /top/new_addr_ovh
wave /top/new_addr

//wave /top/rtg_en
//wave /top/ch_rtg_f
//wave /top/rtg_f
//wave /top/ch_nact_f
//wave /top/st_rrq_f
//wave /top/ch_sm
//wave /top/ch_sg
//wave /top/ch_bw
//wave /top/ch_md
//wave /top/st_dir
//wave /top/ch_cnt
//wave /top/ch_last_f
//wave /top/ovf_f
//wave /top/ch_act_nx
//wave /top/ch_dir_nx
wave /top/ch_vol
wave /top/st_samp_old
wave /top/st_samp_new
wave /top/ch_tab
//wave /top/ch_waddr
//wave /top/ch_wdat
//wave /top/ch_we
wave /top/st_tab

// Z80
wave /cpu/busrq_n
wave /cpu/bi
wave /cpu/busak_n
wave /d
wave /a

//wave /top/st_addr

clear
run @900 ns
endsim

quiet off
