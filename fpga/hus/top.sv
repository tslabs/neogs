
// top-level module

`timescale 1ns / 1ps

module top
(
  // clocks
  input wire clk_24mhz,
  input wire clk_fpga,    // the same that drives Z80 CLK input

 // clock selection
  output wire clksel0,
  output wire clksel1,

  // warm reset
  input wire warmres_n,

 // Z80 data
  inout wire [7:0] d,

 // Z80 address
  output wire [15:0] a, // !!! must be inout

 // Z80 control
  input wire iorq_n,
  input wire mreq_n,
  input wire rd_n,
  input wire wr_n,
  input wire m1_n,
  output wire int_n,
  output wire nmi_n,
  output wire busrq_n,
  input wire busak_n,
  output reg z80res_n,

  // SRAM
  output reg mema14,
  output reg mema15,
  output reg mema16,
  output reg mema17,
  output reg mema18,
  output reg mema21,
  output reg ram0cs_n,
  output reg ram1cs_n,
  output reg ram2cs_n,
  output reg ram3cs_n,
  output reg romcs_n,
  output reg memoe_n,
  output reg memwe_n,

  // ZXBUS
  inout wire [7:0] zxid,
  input wire [7:0] zxa,
  input wire zxa14,
  input wire zxa15,
  input wire zxiorq_n,
  input wire zxmreq_n,
  input wire zxrd_n,
  input wire zxwr_n,
  input wire zxcsrom_n,
  output wire zxblkiorq_n,
  output wire zxblkrom_n,
  output wire zxgenwait_n,
  output wire zxbusin,    // 74hct245 direction (1 - ZX to card, 0 - card to ZX)
  output wire zxbusena_n,

  // audio-DAC
  output wire dac_bitck,
  output wire dac_lrck,
  output wire dac_dat,

  // SD card
  output wire sd_clk,
  output wire sd_cs,
  output wire sd_do,
  input wire sd_di,
  input wire sd_wp,
  input wire sd_det,

  // MP3 chip control
  output wire ma_clk,
  output wire ma_cs,
  output wire ma_do,
  input wire ma_di,

  // MP3 chip data
  output wire mp3_xreset,
  output wire mp3_clk,
  output wire mp3_dat,
  output wire mp3_sync,
  input wire mp3_req,

  // LED driver
  output reg led_diag
);

  assign zxblkiorq_n = !zxport_hit;
  assign zxblkrom_n = !zxblkrom;
  assign zxbusena_n = !zxbusena;
  assign zxid = zxd;
  assign zxbusin = !zxdout_en;
  assign zxgenwait_n = !zxwait;

  assign {mema21, mema18, mema17, mema16, mema15, mema14} = 6'h0;

  assign d = 8'hZZ;
  assign a = busak_n ? 16'hZZZZ : ram_addr[15:0];

  assign dac_bitck  = dac_clk_cnt[1];    // 6MHz
  assign dac_lrck   = dac_clk_cnt[7];
  assign dac_dat    = dac_data[16];

  assign sd_clk     = 1'b1;
  assign sd_cs      = 1'b1;
  assign sd_do      = 1'b1;
  assign ma_clk     = 1'b1;
  assign ma_cs      = 1'b1;
  assign ma_do      = 1'b1;
  assign mp3_xreset = 1'b1;
  assign mp3_clk    = 1'b1;
  assign mp3_dat    = 1'b1;
  assign mp3_sync   = 1'b1;

  assign led_diag = !led;

/* -------------------------------------------------------------------------------------------- */


/* --- Z80 --- */
  assign z80res_n = 1'bZ;
  assign int_n = 1'b1;
  assign nmi_n = 1'b1;
  assign busrq_n = !busrq;


/* --- SRAM --- */
  assign ram0cs_n = 1'b1;
  assign ram1cs_n = 1'b1;
  assign ram2cs_n = 1'b1;
  assign ram3cs_n = 1'b1;
  assign romcs_n = 1'b1;
  assign memoe_n = 1'b1;
  assign memwe_n = 1'b1;

  // Z80 CLK selection
  assign {clksel1, clksel0} = 2'b11;


/* --- ZXBUS --- */
  // card ports and IORGE
  wire zxport_hit = pcomm || pdata || pctrl;

  localparam GSCOM  = 8'hBB;  // W:   command, R: status
  localparam GSDAT  = 8'hB3;  // R/W: data
  localparam GSCTR  = 8'h33;  // W:   control

  wire pcomm = zxa == GSCOM;
  wire pdata = zxa == GSDAT;
  wire pctrl = zxa == GSCTR;

  // ROM replacement window
  wire zxblkrom = rom_win_addr && rom_win_en;

  reg rom_win_en = 1'b0;
  wire rom_win_addr = {zxa15, zxa14} == 2'b00;

  // host CPU ~WAIT
  wire zxwait = 1'b0;

  // ZXBUS data
  wire zxiord = !zxiorq_n && !zxrd_n;
  wire zxiowr = !zxiorq_n && !zxwr_n;
  wire zxbusena = (zxiord || zxiowr) && zxport_hit;
  wire zxdout_en = zxiord && zxport_hit;
  wire [7:0] zxd = zxdout_en ? dout : 8'hZZ;


/* --- Internal ports --- */
  reg [1:0] zxiowr_r;
  reg [3:0] rsel;

  reg [12:0] tk_cnt;
  reg [7:0] sm_vol;
  reg [7:0] num_ch;

  enum
  {
    P_CCTR,   // 00 CPU control
    P_HCTR,   // 01 HUS control
    P_TCNTL,  // 02 Tick Count Low
    P_TCNTH,  // 03 Tick Count High
    P_ATIML,  // 04 Audio Timer Low
    P_ATIMH,  // 05 Audio Timer High
    P_NCHN,   // 06 Number of Channels
    P_SVOL    // 07 Samples Volume
  } INT_PORT;

  reg fsm_en = 1'b0;

  wire port_we = zxiowr_r == 2'b01;

  always @(posedge clk_fpga)
  begin
    zxiowr_r <= {zxiowr_r[0], zxiowr && zxport_hit};

    if (port_we)
    begin
      if (pcomm)
        rsel <= zxid[3:0];

      else if (pdata)
        case (rsel)
          P_HCTR:   fsm_en        <= zxid[0];
          P_TCNTL:  tk_cnt        <= zxid;
          P_TCNTH:  tk_cnt[12:8]  <= zxid[4:0];
          P_ATIML:  au_tim        <= zxid;
          P_ATIMH:  au_tim[11:8]  <= zxid[3:0];
          P_SVOL:   sm_vol        <= zxid;
          P_NCHN:   num_ch        <= zxid[5:0];
        endcase
    end
  end

  logic [7:0] dout;

  always_comb
    case (rsel)
      default:
        dout = 8'hAA;
    endcase


/* --- Interpolator --- */
  enum bit [2:0]
  {
    IST_0,
    IST_1,
    IST_2,
    IST_3,
    IST_4,
    IST_5,
    IST_6,
    IST_7
  } IPL_STATE;

  enum bit [0:0]
  {
    IMD_MONO,
    IMD_STEREO
  } IPL_MODE;

  wire ipl_busy = ipl_state == IST_0;
  logic [7:0] ipl_samp[0:1];
  logic [7:0] ipl_mp;
  logic [7:0] ipl_vol[0:1];
  logic ipl_mode;
  reg [7:0] ipl_mul_arg[0:1];
  reg [15:0] ipl_mul;

  logic ipl_req;
  logic ipl_res;

  reg [2:0] ipl_state = IST_0;
  reg [21:0] ipl_sum[1:0];

  logic [7:0] arg_sgn;
  wire [7:0] arg_usgn = arg_sgn[7] ? (256 - arg_sgn) : arg_sgn;

  always_latch
    case (ipl_state)
      IST_0:
        arg_sgn = ipl_samp[0];

      IST_1:
        arg_sgn = ipl_samp[1];
    endcase

  always @(posedge clk_fpga)
    if (ipl_res)
    begin
      ipl_sum[0] <= 'd0;
      ipl_sum[1] <= 'd0;
    end

    else
      case (ipl_state)
        IST_0:
          if (ipl_req)
          begin
            ipl_mul_arg[0] <= arg_usgn;
            ipl_mul_arg[1] <= 128 - ipl_mp;

            ipl_state <= IST_1;
          end

        IST_1:
        begin
            ipl_mul_arg[0] <= arg_usgn;
            ipl_mul_arg[1] <= ipl_mp;
            ipl_state <= IST_2;
        end
            // if (ipl_mode == IMD_MONO)

      endcase

  always @(posedge clk_fpga)
    ipl_mul <= ipl_mul_arg[0] * ipl_mul_arg[1];



/* --- FSM --- */
  initial
  begin
    ch_tab[8'h00] = {8'h00, 8'b00000111};
    ch_tab[8'h01] = 16'h1000;
    ch_tab[8'h02] = 16'h000C;
    ch_tab[8'h03] = 16'h0810;
    ch_tab[8'h04] = 16'h1000;
    ch_tab[8'h05] = 16'h0500;
    ch_tab[8'h06] = 16'h4040;

    // ch_tab[8'h07] = {8'h00, 8'b00000101};
    // ch_tab[8'h08] = 16'h2000;
    // ch_tab[8'h09] = 16'h0008;
    // ch_tab[8'h0A] = 16'h0420;
    // ch_tab[8'h0B] = 16'h2000;
    // ch_tab[8'h0C] = 16'h0800;
    // ch_tab[8'h0D] = 16'h4040;

    for (int i = 7; i < 256; i++)
      ch_tab[i] = 0;

    // for (int i = 0; i < 256; i++)
      // st_tab[i] = 0;
  end


  enum bit [3:0]
  {
    FST_0,
    FST_1,
    FST_2,
    FST_3,
    FST_4,
    FST_5,
    FST_6,
    FST_7,
    FST_8,
    FST_9,
    FST_10,
    FST_11,
    FST_12,
    FST_13,
    FST_14,
    FST_15
  } FSM_STATE;

  enum bit [0:0]
  {
    DIR_FWD,
    DIR_BCK
  } CH_DIR;

  enum bit [1:0]
  {
    MD_OFF,
    MD_NO,
    MD_FWD,
    MD_BIDI
  } CH_MODE;

  enum bit [2:0]
  {
    CH_CTR,   // 0
    CH_ADRH,  // 1
    CH_ENDL,  // 2
    CH_LPL,   // 3
    CH_LPH,   // 4
    CH_INC,   // 5
    CH_VOL    // 6
  } CH_REG;
  
  enum bit [2:0]
  {
    ST_ST,    // 0
    ST_ADRH,  // 1
    ST_SADR,  // 2
    ST_S0,    // 3
    ST_S1     // 4
  } ST_REG;
  
  reg [15:0] ch_tab[0:255]; // ChTab memory array
  reg [15:0] ch_rdat;       // ChTab read data
  reg [15:0] ch_wdat;       // ChTab write data
  reg [7:0]  ch_addr;        // ChTab entry address
  reg [2:0]  ch_rreg;        // ChTab reg to be read
  reg [7:0]  ch_waddr;       // ChTab addr to be written
  reg ch_we;                // ChTab write enable

  reg [15:0] st_tab[0:255]; // ChStTab memory array
  reg [15:0] st_rdat;       // ChStTab read data
  reg [15:0] st_wdat;       // ChStTab write data
  reg [7:0]  st_addr;        // ChStTab entry address
  reg [2:0]  st_rreg;        // ChStTab reg to be read
  reg [7:0]  st_waddr;       // ChStTab addr to be written
  reg st_we;                // ChStTab write enable


  // internal tabs memory
  always_comb
  begin
    ch_rdat = ch_tab[ch_addr + ch_rreg];
    st_rdat = st_tab[st_addr + st_rreg];

    if (ch_we)
      ch_tab[ch_waddr] = ch_wdat;

    if (st_we)
      st_tab[st_waddr] = st_wdat;
  end


  reg [3:0] fsm_state;      // HUS FSM state
  reg [5:0] ch_cnt;         // counter for channels

  reg [21:0] cur_addr;      // address of RAM to read
  reg [21:0] end_addr;      // address of loop end
  reg [21:0] beg_addr;      // address of loop start
  reg [11:0] st_sub_addr;   // current sub-address
  reg [15:0] ch_inc;        // increment 4.12
  reg [7:0] ch_vol[0:1];    // L/R volume
  reg [15:0] st_samp_old;
  reg [15:0] st_samp_new;

  reg ch_sm;                // sample stereo mode
  reg ch_sg;                // sample signedness
  reg ch_bw;                // sample bitwidth
  reg st_dir;               // sample current direction
  reg [1:0] ch_md;          // channel mode
  reg rtg_en;               // retriggers processing - 1st iteration after inactivity
  reg rtg_f;
  reg ovf_f;

  wire ch_rtg_f = ch_rdat[2] && rtg_en;
  wire st_rrq_f = st_rdat[2];
  wire ch_nact_f = (ch_rdat[1:0] == 2'b00) || (!ch_rtg_f && !st_rdat[0]);
  wire ch_last_f = ch_cnt == num_ch;
  wire sa_ovf_f = |addr_inc_raw;
  wire na_ovf_f = |new_addr_ovh[6:0] && !new_addr_ovh[7];
  wire ch_act_nx = na_ovf_f ? ch_md[1] : 1'b1;
  wire ch_dir_nx = (na_ovf_f && ch_md[0]) ^ st_dir;

  // Notice for addressing:
  // - end and loop points MUST be a multiple of sample unit (1/2/4 bytes)
  // - if sample is 16-bit all points must be incremented by 1 to address MSBs of sample data

  wire [12:0] sub_addr_new = st_sub_addr + ch_inc[11:0];

  wire [4:0] addr_inc_raw = ch_inc[15:12] + sub_addr_new[12];
  wire [1:0] sample_bw = {ch_sm, ch_bw};
  wire [6:0] addr_inc = (sample_bw == 2'b00) ? addr_inc_raw : ((sample_bw == 2'b11) ? (addr_inc_raw << 2) : (addr_inc_raw << 1));
  wire [1:0] addr_unit = (sample_bw == 2'b00) ? 1 : ((sample_bw == 2'b11) ? 4 : 2);

  wire [21:0] new_addr_raw = (st_dir == DIR_FWD) ?  (cur_addr + addr_inc) : (cur_addr - addr_inc);
  wire [7:0] new_addr_ovh = (st_dir == DIR_FWD) ? (new_addr_raw - end_addr) : (end_addr - new_addr_raw);
  wire [21:0] new_addr_raw2 = (ch_md == MD_FWD) ? (beg_addr + new_addr_ovh - addr_unit) : ((st_dir == DIR_FWD) ? (end_addr - new_addr_ovh) : (end_addr + new_addr_ovh));
  wire [21:0] new_addr = !na_ovf_f ? new_addr_raw : new_addr_raw2;


  // clock FSM part
  always @(posedge clk_fpga)
    if (!fsm_en)
    begin
      ch_addr <= 1'd0;
      ch_rreg <= 1'd0;

      st_addr <= 1'd0;
      st_rreg <= 1'd0;

      st_we <= 1'b0;

      ch_cnt <= 1'd0;
      rtg_en <= 1'b1;

      fsm_state <= FST_0;
    end

    else
      case (fsm_state)

        // initial channel scenario branching
        FST_0:
        begin
          st_we <= 1'b0;

          // skip inactive channel
          if (ch_nact_f)
          begin
            ch_addr += 3'd7;
            st_addr += 3'd5;

            ch_cnt++;

            fsm_state <= ch_last_f ? FST_15 : FST_0;
          end

          // process active channel
          else
          begin
            ch_bw <= ch_rdat[7];
            ch_sm <= ch_rdat[6];
            ch_sg <= ch_rdat[5];
            ch_md <= ch_rdat[1:0];
            rtg_f <= ch_rtg_f;

            cur_addr[7:0] <= ch_rtg_f ? ch_rdat[15:8] : st_rdat[15:8];
            st_sub_addr <= 12'b0;
            st_dir <= ch_rtg_f ? DIR_FWD : st_rdat[1];

            ch_rreg <= ch_rtg_f ? CH_ADRH : CH_INC;
            st_rreg <= st_rrq_f ? ST_ADRH : ST_SADR;

            fsm_state <= ch_rtg_f ? FST_1 : (st_rrq_f ? FST_4 : FST_6);
          end
        end

        FST_1:
        begin
          cur_addr[21:8] <= ch_rdat[13:0];

          if (!mf_busy)
          begin
            st_waddr <= st_addr + 3'd1;
            st_wdat[13:0] <= ch_rdat[13:0];
            st_we <= 1'b1;

            mf_req <= 1'b1;

            ch_rreg <= 3'd5;

            fsm_state <= FST_2;
          end
        end

        FST_2:
        begin
          ch_inc <= ch_rdat;

          ch_rreg <= 3'd6;

          st_waddr <= st_addr;
          st_wdat[15:8] <= cur_addr[7:0];
          st_wdat[2] <= 1'b1;
          st_wdat[1] <= st_dir;
          st_wdat[0] <= 1'b1;
          st_we <= 1'b1;

          mf_req <= 1'b0;
          if (mf_req == 1'b1) $display("%x", cur_addr);

          fsm_state <= FST_3;
        end

        FST_3:
        begin
          ch_vol[1] <= ch_rdat[15:8];
          ch_vol[0] <= ch_rdat[7:0];

          if (!rtg_f)
            st_samp_old <= st_rdat;

          ch_rreg <= sa_ovf_f ? ((st_dir == DIR_FWD) ? 3'd2 : 3'd3) : 3'd0;
          st_rreg <= 3'd0;

          st_waddr <= st_addr + 3'd2;
          st_wdat[11:0] <= sub_addr_new;
          st_we <= 1'b1;

          if (!sa_ovf_f)
          begin
            ch_addr += 3'd7;
            st_addr += 3'd5;
            ch_cnt++;
          end

          fsm_state <= sa_ovf_f ? FST_9 : (ch_last_f ? FST_15 : FST_0);
        end

        FST_4:
        begin
          ch_inc <= ch_rdat;
          cur_addr[21:8] <= st_rdat[13:0];

          st_waddr <= st_addr;
          st_wdat[15:8] <= cur_addr[7:0];
          st_wdat[2] <= 1'b0;
          st_wdat[1] <= st_dir;
          st_wdat[0] <= 1'b1;
          st_we <= 1'b1;

          if (!mf_busy)
          begin
            st_rreg <= 3'd2;

            mf_req <= 1'b1;

            fsm_state <= FST_5;
          end
        end

        FST_5:
        begin
          st_sub_addr <= st_rdat[11:0];

          ch_rreg <= 3'd6;
          st_rreg <= 3'd4;
          st_we <= 1'b0;

          mf_req <= 1'b0;
          if (mf_req == 1'b1) $display("%x", cur_addr);

          fsm_state <= FST_3;
        end

        FST_6:
        begin
          ch_inc <= ch_rdat;
          st_sub_addr <= st_rdat[11:0];

          ch_rreg <= 3'd6;
          st_rreg <= 3'd3;

          fsm_state <= FST_7;
        end

        FST_7:
        begin
          ch_vol[1] <= ch_rdat[15:8];
          ch_vol[0] <= ch_rdat[7:0];
          st_samp_old <= st_rdat;

          ch_rreg <= (st_dir == DIR_FWD) ? 3'd2 : 3'd3;
          st_rreg <= 3'd4;

          fsm_state <= FST_8;
        end

        FST_8:
        begin
          if (st_dir == DIR_FWD)
            end_addr[15:0] <= ch_rdat;
          else
            end_addr[7:0] <= ch_rdat[15:8];

          st_samp_new <= st_rdat;

          ch_rreg <= sa_ovf_f ? ((st_dir == DIR_FWD) ? 3'd3 : 3'd4) : 3'd0;
          st_rreg <= sa_ovf_f ? 3'd1 : 3'd0;

          st_waddr <= st_addr + 3'd2;
          st_wdat[11:0] <= sub_addr_new;
          st_we <= 1'b1;

          if (!sa_ovf_f)
          begin
            ch_addr += 3'd7;
            st_addr += 3'd5;
            ch_cnt++;
          end

          fsm_state <= sa_ovf_f ? FST_10 : (ch_last_f ? FST_15 : FST_0);
        end

        FST_9:
        begin
          if (st_dir == DIR_FWD)
            end_addr[15:0] <= ch_rdat;
          else
            end_addr[7:0] <= ch_rdat[15:8];

          ch_rreg <= (st_dir == DIR_FWD) ? 3'd3 : 3'd4;
          
          if (!rtg_f)
          begin
            st_waddr <= st_addr + 3'd3;
            st_wdat[11:0] <= st_samp_old;
            st_we <= 1'b1;
          end

          else
            st_we <= 1'b0;

          fsm_state <= FST_11;
        end

        FST_10, FST_11:
        begin
          if (st_dir == DIR_FWD)
            end_addr[21:16] <= ch_rdat[5:0];
          else
            end_addr[21:8] <= ch_rdat[13:0];

          beg_addr[7:0] <= ch_rdat[15:8];

          st_we <= 1'b0;

          if (fsm_state == FST_10)
            cur_addr[21:8] <= st_rdat[13:0];

          ch_rreg <= 3'd4;

          fsm_state <= FST_12;
        end

        FST_12, FST_13:
        begin
          if ((ch_md == MD_FWD) && na_ovf_f && (fsm_state == FST_12))
          begin
            beg_addr[21:8] <= ch_rdat[13:0];
            fsm_state <= FST_13;
          end

          else
          begin
            ch_rreg <= 3'd0;
            st_rreg <= 3'd0;

            st_waddr <= st_addr;
            st_wdat[15:8] <= new_addr[7:0];
            st_wdat[2] <= 1'b1;
            st_wdat[1] <= ch_dir_nx;
            st_wdat[0] <= ch_act_nx;
            st_we <= 1'b1;

            if (!ch_act_nx)
            begin
              ch_addr += 3'd7;
              st_addr += 3'd5;
              ch_cnt++;
            end

            fsm_state <= ch_act_nx ? FST_14 : (ch_last_f ? FST_15 : FST_0);
          end
        end

        FST_14:
        begin
          ch_rreg <= 3'd0;
          st_rreg <= 3'd0;

          st_waddr <= st_addr + 3'd1;
          st_wdat[13:0] <= new_addr[21:8];
          st_we <= 1'b1;

          ch_addr += 3'd7;
          st_addr += 3'd5;
          ch_cnt++;

          fsm_state <= ch_last_f ? FST_15 : FST_0;
        end

        FST_15:
        begin
          ch_addr <= 1'd0;
          ch_rreg <= 1'd0;

          st_addr <= 1'd0;
          st_rreg <= 1'd0;
          st_we <= 1'b0;

          ch_cnt <= 1'd0;
          rtg_en <= 1'b0;
          st_we <= 1'b0;

          fsm_state <= FST_0;
        end

      endcase













/* --- Memory fetcher --- */

  enum bit [1:0]
  {
    MST_0,
    MST_1,
    MST_2,
    MST_3
  } MST;

  reg [2:0] mf_state = MST_0;

  wire mf_busy = mf_state != MST_0;
  wire busrq = mf_brq && (mf_sm || busak_n);

  reg mf_req;
  reg mf_brq = 1'b0;
  reg mf_sm;
  reg mf_bw;
  reg [21:0] ram_addr;
  reg [7:0] mf_data[0:1];

  always @(posedge clk_fpga)
    case (mf_state)
      MST_0:
        if (mf_req)
        begin
          ram_addr <= cur_addr;
          mf_brq <= 1'b1;
          mf_sm <= ch_sm;
          mf_bw <= ch_bw;

          mf_state <= MST_1;
        end

      MST_1:
        if (!busak_n)
        begin
          mf_brq <= 1'b0;

          mf_state <= MST_2;
        end

      MST_2:
        begin
          mf_data[0] <= d;
          mf_data[1] <= d;
          ram_addr <= ram_addr + (mf_bw ? 2 : 1);

          mf_state <= mf_sm ? MST_3 : MST_0;
        end

      MST_3:
        begin
          mf_data[1] <= d;

          mf_state <= MST_0;
        end
    endcase













/* --- Audio DAC --- */
  reg [11:0] au_tim;
  reg [11:0] au_cnt;
  reg [7:0] dac_clk_cnt = 8'b11111110;
  reg [16:0] dac_data;

  wire dac_load_stb = au_cnt == au_tim;
  wire dac_fifo_rreq = dac_load_stb && !dac_fifo_empty;
  wire dac_clk_stall = (dac_clk_cnt[6:0] == 7'b1111110) && !dac_fifo_rreq;

  always @(posedge clk_fpga)
  begin
    // counter for audio frequency strobe
    au_cnt <= dac_load_stb ? 1'b0 : (au_cnt + 1'd1);

    // DAC clock generator
    if (!dac_clk_stall)
      dac_clk_cnt <= {dac_clk_cnt[7], (dac_clk_cnt[6:2] == 5'd17) ? 5'd31 : dac_clk_cnt[6:2], dac_clk_cnt[1:0]} + 1'd1;

    // DAC data
    // Data is SIGNED! 0x8000 = -Vref, 0x7FFF = +Vref
    if (&dac_clk_cnt[6:0])
      dac_data <= {1'b0, dac_fifo_out};
    else if (&dac_clk_cnt[1:0])
      dac_data <= {dac_data[15:0], 1'b0};
  end


/* --- DAC FIFO --- */
  reg [15:0] dac_fifo_in;
  reg [15:0] dac_fifo_out;
  reg dac_fifo_wreq;
  wire dac_fifo_empty = ~|cnt;
  wire dac_fifo_full = cnt[8];

  reg [8:0] cnt = 1'b0;
  reg [7:0] rptr = 1'b0;
  reg [7:0] wptr = 1'b0;

  reg [15:0] fifo[0:255];

  always_ff @(posedge clk_fpga)
  begin
    if (dac_fifo_rreq)
      rptr++;

    if (dac_fifo_wreq)
      wptr++;

    if (dac_fifo_rreq ^^ dac_fifo_wreq)
      cnt <= cnt + (dac_fifo_wreq ? 1'b1 : -1'd1);

    dac_fifo_out <= fifo[rptr];

    if (dac_fifo_wreq)
      fifo[wptr] <= dac_fifo_in;
  end


/* --- LED --- */
  reg [31:0] led_cnt;
  reg led;

  always @(posedge clk_fpga)
  begin
    if (&led_cnt[20:0])
      led <= ~led;

    led_cnt++;
  end

endmodule
