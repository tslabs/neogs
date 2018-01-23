
module hus
(
  input wire clk,
  input wire reset,
  output wire busrq_n,
  input wire busak,
  input wire [7:0] zxd,
  input wire [7:0] zxa,
  input wire zxa14,
  input wire zxa15,
  input wire zxiorq,
  input wire zxwr,
  output wire led
);

  assign busrq_n = 1'b1;
	wire zxiowr = zxiorq && zxwr;
  wire [15:0] rdat;
  assign led = |rdat;
  wire [5:0] chn_num = 6'd32;

// Audio clock counter
  localparam AU_CNT = 10'd544;   // (24000/44.1)
  reg [10:0] au_cnt;
  wire au_stb = (au_cnt == AU_CNT);

  always_ff @(posedge clk)
    if (au_stb)
      au_cnt = 10'd0;
    else
      au_cnt <= au_cnt + 1'b1;

// States processing
  enum reg [1:0]
  {
    ST_OFF,   // FSM disabled
    ST_INIT,  // begin of working cycle
    ST_BURST, // samples reading burst
    ST_MATH   // channels processing
  } state;

  wire st_init = (state == ST_INIT);
  wire st_burst = (state == ST_BURST);
  wire st_math = (state == ST_MATH);

  always_ff @(posedge clk)
    if (reset)
      state <= ST_OFF;
    else
      case (state)
        ST_OFF:
          if (1)
            state <= ST_INIT;

        ST_INIT:
          if (1)
            state <= ST_BURST;

        ST_BURST:
          if (burst_end)
            state <= ST_MATH;
      endcase

// Channel counter (used in both burst and math)
  reg [5:0] chn_cnt;
  
  always_ff @(posedge clk)
    if (st_init || burst_end)
      chn_cnt <= 6'd0;
    else if (st_burst || math_next)
      chn_cnt <= chn_cnt + 1'b1;

// Burst samples reading
  wire burst_end = st_burst && (chn_cnt == chn_num);

    if (st_init)
      chn_cnt <= 6'b0;
    else if (st_burst && !burst_end)
      burst_cnt <= burst_cnt + 1'b1;

// Channels processing
  wire math_end = st_math && (chn_cnt == chn_num);

  always_ff @(posedge clk)
    if (st_init)

// Double clock rate data reading
  wire [7:0] dcr_addr = {
    
// 16 bit RAM with async data out (ACEX 1K)
  ram16a hfile
  (
    .clock     (clk),
    .rdaddress (zxa),
    .wraddress (zxa),
    .q         (rdat),
    .data      ({zxd, ~zxd}),
    .wren      (!zxiowr_n)
  );

endmodule
