
`timescale 1ns / 1ps

module tb();

  reg clk_24mhz = 0;
  always
    #1 clk_24mhz = ~clk_24mhz;

  reg clk_fpga;
  always @(posedge clk_24mhz, negedge clk_24mhz)
    clk_fpga <= !clk_24mhz;   // delay must be clarified using oscilloscope

  initial
  begin
    #0 begin zxiorq_n = 1; zxrd_n = 1; zxwr_n = 1; end
    // out (PCOM), NCHN
    #2 begin zxa = 8'hBB; zxid = 6; end
    #2 begin zxiorq_n = 0; zxwr_n = 0; end
    #2 begin zxiorq_n = 1; zxwr_n = 1; end
    // out (PDAT)
    #2 begin zxa = 8'hB3; zxid = 1; end
    #2 begin zxiorq_n = 0; zxwr_n = 0; end
    #2 begin zxiorq_n = 1; zxwr_n = 1; end
    // out (PCOM), HCTR
    #2 begin zxa = 8'hBB; zxid = 1; end
    #2 begin zxiorq_n = 0; zxwr_n = 0; end
    #2 begin zxiorq_n = 1; zxwr_n = 1; end
    // out (PDAT)
    #2 begin zxa = 8'hB3; zxid = 1; end
    #2 begin zxiorq_n = 0; zxwr_n = 0; end
    #2 begin zxiorq_n = 1; zxwr_n = 1; end

    #2 begin zxa = 8'hZZ; zxid = 8'hZZ; end
  end

  logic clksel0;
  logic clksel1;
  logic warmres_n;
  logic [7:0] d;
  logic [15:0] a;
  logic iorq_n;
  logic mreq_n;
  logic rd_n;
  logic wr_n;
  logic m1_n;
  logic int_n;
  logic nmi_n;
  logic busrq_n;
  logic busak_n;
  logic z80res_n;
  logic mema14;
  logic mema15;
  logic mema16;
  logic mema17;
  logic mema18;
  logic mema21;
  logic ram0cs_n;
  logic ram1cs_n;
  logic ram2cs_n;
  logic ram3cs_n;
  logic romcs_n;
  logic memoe_n;
  logic memwe_n;
  logic [7:0] zxid;
  logic [7:0] zxa;
  logic zxa14;
  logic zxa15;
  logic zxiorq_n;
  logic zxmreq_n;
  logic zxrd_n;
  logic zxwr_n;
  logic zxcsrom_n;
  logic zxblkiorq_n;
  logic zxblkrom_n;
  logic zxgenwait_n;
  logic zxbusin;
  logic zxbusena_n;
  logic dac_bitck;
  logic dac_lrck;
  logic dac_dat;
  logic sd_clk;
  logic sd_cs;
  logic sd_do;
  logic sd_di;
  logic sd_wp;
  logic sd_det;
  logic ma_clk;
  logic ma_cs;
  logic ma_do;
  logic ma_di;
  logic mp3_xreset;
  logic mp3_clk;
  logic mp3_dat;
  logic mp3_sync;
  logic mp3_req;
  logic led_diag;

  // assign d = 8'hZZ;

  wire [15:0] cpu_a;
  wire [7:0] cpu_d;
  wire [15:0] top_a;
  wire [7:0] sram_d;
  
  assign a = busak_n ? cpu_a : top_a;
  assign d = busak_n ? cpu_d : sram_d;
  
  z80_simple cpu
  (
    .clk    (clk_fpga),
    .busrq_n(busrq_n),
    .busak_n(busak_n),
    .d      (cpu_d),
    .a      (cpu_a)
  );

  sram_simple sram
  (
    .a      (a),
    .d      (sram_d)
  );
  
  top top
  (
    .clk_fpga   (clk_fpga),
    .clk_24mhz  (clk_24mhz),
    .clksel0    (clksel0),
    .clksel1    (clksel1),
    .warmres_n  (warmres_n),
    .d          (d),
    .a          (top_a),
    .iorq_n     (iorq_n),
    .mreq_n     (mreq_n),
    .rd_n       (rd_n),
    .wr_n       (wr_n),
    .m1_n       (m1_n),
    .int_n      (int_n),
    .nmi_n      (nmi_n),
    .busrq_n    (busrq_n),
    .busak_n    (busak_n),
    .z80res_n   (z80res_n),
    .mema14     (mema14),
    .mema15     (mema15),
    .mema16     (mema16),
    .mema17     (mema17),
    .mema18     (mema18),
    .mema21     (mema21),
    .ram0cs_n   (ram0cs_n),
    .ram1cs_n   (ram1cs_n),
    .ram2cs_n   (ram2cs_n),
    .ram3cs_n   (ram3cs_n),
    .romcs_n    (romcs_n),
    .memoe_n    (memoe_n),
    .memwe_n    (memwe_n),
    .zxid       (zxid),
    .zxa        (zxa),
    .zxa14      (zxa14),
    .zxa15      (zxa15),
    .zxiorq_n   (zxiorq_n),
    .zxmreq_n   (zxmreq_n),
    .zxrd_n     (zxrd_n),
    .zxwr_n     (zxwr_n),
    .zxcsrom_n  (zxcsrom_n),
    .zxblkiorq_n(zxblkiorq_n),
    .zxblkrom_n (zxblkrom_n),
    .zxgenwait_n(zxgenwait_n),
    .zxbusin    (zxbusin),
    .zxbusena_n (zxbusena_n),
    .dac_bitck  (dac_bitck),
    .dac_lrck   (dac_lrck),
    .dac_dat    (dac_dat),
    .sd_clk     (sd_clk),
    .sd_cs      (sd_cs),
    .sd_do      (sd_do),
    .sd_di      (sd_di),
    .sd_wp      (sd_wp),
    .sd_det     (sd_det),
    .ma_clk     (ma_clk),
    .ma_cs      (ma_cs),
    .ma_do      (ma_do),
    .ma_di      (ma_di),
    .mp3_xreset (mp3_xreset),
    .mp3_clk    (mp3_clk),
    .mp3_dat    (mp3_dat),
    .mp3_sync   (mp3_sync),
    .mp3_req    (mp3_req),
    .led_diag   (led_diag)
  );

endmodule

module z80_simple
(
  input wire clk,
  input wire busrq_n,
  output reg busak_n,
  output wire [7:0] d,
  output wire [15:0] a
);

  assign d = busak_n ? id : 8'hZZ;
  assign a = busak_n ? ia : 16'hZZZZ;

  reg [7:0] id;
  reg [15:0] ia;
  reg [3:0] delay;
  reg [1:0] bi = 0;

  always_ff @(posedge clk)
  begin
    id <= $urandom();
    ia <= $urandom();
    
    if (busrq_n)
      delay <= 4'd4;
    else
      delay--;
    
    bi <= {bi[0], !busrq_n && (~|delay || bi[0])};
  end

  always_ff @(posedge clk, negedge clk)
    if (!clk && bi[1])
      busak_n <= 0;
    else if (clk && !bi[0])
      busak_n <= 1;
endmodule

module sram_simple
(
  input wire [15:0] a,
  output wire [7:0] d
);

  assign d = a[7:0];

endmodule

module rom256x16
(
  input wire inclock,
  input wire [7:0] rdaddress,
  output reg [15:0] q,
  input wire [7:0] wraddress,
  input wire [15:0] data,
  input wire wren
);

  always_ff @(posedge inclock)
    case (rdaddress)
    8'h00:   q <= {8'h50, 8'b00000001};
    8'h01:   q <= 16'h1122;
    8'h02:   q <= 16'h2260;
    8'h03:   q <= 16'h5811;
    8'h04:   q <= 16'h1122;
    8'h05:   q <= 16'h1000;
    8'h06:   q <= 16'h4040;
    
      // 8'h07:   q <= {8'h88, 8'b00000001};
      // 8'h08:   q <= 16'h33AA;
      // 8'h09:   q <= 16'hAA90;
      // 8'h0A:   q <= 16'h8A33;
      // 8'h0B:   q <= 16'h33AA;
      // 8'h0C:   q <= 16'h1000;
      // 8'h0D:   q <= 16'h4040;

      // 8'h0E:   q <= {8'h40, 8'b00000001};
      // 8'h0F:   q <= 16'h0100;
      // 8'h10:   q <= 16'h0050;
      // 8'h11:   q <= 16'h4801;
      // 8'h12:   q <= 16'h0100;
      // 8'h13:   q <= 16'h0800;
      // 8'h14:   q <= 16'h2020;

      default: q <= 16'h0000;
    endcase

endmodule
