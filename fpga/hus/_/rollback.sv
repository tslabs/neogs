altdpram ch_tab
  (
    .inclock        (clk_24mhz),
    .rdaddress      (ch_radr_next),
    .q              (ch_rdat),
    .wraddress      (ch_wadr_next),
    .data           (ch_wdat),
    .wren           (ch_we),
    .aclr           (1'b0),
    .byteena        (1'b1),
    .inclocken      (1'b1),
    .outclock       (1'b1),
    .outclocken     (1'b1),
    .rdaddressstall (1'b0),
    .rden           (1'b1),
    .wraddressstall (1'b0)
  );

  defparam
    ch_tab.indata_aclr = "OFF",
    ch_tab.indata_reg = "INCLOCK",
    ch_tab.intended_device_family = "ACEX1K",
    ch_tab.lpm_type = "altdpram",
    ch_tab.outdata_aclr = "OFF",
    ch_tab.outdata_reg = "UNREGISTERED",
    ch_tab.rdaddress_aclr = "OFF",
    ch_tab.rdaddress_reg = "INCLOCK",
    ch_tab.rdcontrol_aclr = "OFF",
    ch_tab.rdcontrol_reg = "UNREGISTERED",
    ch_tab.width = 16,
    ch_tab.widthad = 8,
    ch_tab.wraddress_aclr = "OFF",
    ch_tab.wraddress_reg = "INCLOCK",
    ch_tab.wrcontrol_aclr = "OFF",
    ch_tab.wrcontrol_reg = "INCLOCK";

  altdpram ch_st_tab
  (
    .inclock        (clk_24mhz),
    .rdaddress      (st_radr_next),
    .q              (st_rdat),
    .wraddress      (st_wadr_next),
    .data           (st_wdat_next),
    .wren           (st_we_next),
    .aclr           (1'b0),
    .byteena        (1'b1),
    .inclocken      (1'b1),
    .outclock       (1'b1),
    .outclocken     (1'b1),
    .rdaddressstall (1'b0),
    .rden           (1'b1),
    .wraddressstall (1'b0)
  );

  defparam
    ch_st_tab.indata_aclr = "OFF",
    ch_st_tab.indata_reg = "INCLOCK",
    ch_st_tab.intended_device_family = "ACEX1K",
    ch_st_tab.lpm_type = "altdpram",
    ch_st_tab.outdata_aclr = "OFF",
    ch_st_tab.outdata_reg = "UNREGISTERED",
    ch_st_tab.rdaddress_aclr = "OFF",
    ch_st_tab.rdaddress_reg = "INCLOCK",
    ch_st_tab.rdcontrol_aclr = "OFF",
    ch_st_tab.rdcontrol_reg = "UNREGISTERED",
    ch_st_tab.width = 16,
    ch_st_tab.widthad = 8,
    ch_st_tab.wraddress_aclr = "OFF",
    ch_st_tab.wraddress_reg = "INCLOCK",
    ch_st_tab.wrcontrol_aclr = "OFF",
    ch_st_tab.wrcontrol_reg = "INCLOCK";

  scfifo dac_fifo
  (
    .clock (clk_24mhz),
    .data  (dac_fifo_in),
    .q     (dac_fifo_out),
    .rdreq (dac_fifo_rreq),
    .wrreq (dac_fifo_wreq),
    .empty (dac_fifo_empty),
    .full  (dac_fifo_full)
  );

  defparam
    dac_fifo.intended_device_family = "ACEX1K",
    dac_fifo.lpm_numwords = 256,
    dac_fifo.lpm_showahead = "OFF",
    dac_fifo.lpm_type = "scfifo",
    dac_fifo.lpm_width = 16,
    dac_fifo.lpm_widthu = 8,
    dac_fifo.overflow_checking = "OFF",
    dac_fifo.underflow_checking = "OFF",
    dac_fifo.use_eab = "ON";

module ram256x16
(
  input wire inclock,
  input wire [7:0] rdaddress,
  output reg [15:0] q,
  input wire [7:0] wraddress,
  input wire [15:0] data,
  input wire wren
);

  reg [15:0] mem[0:255];

  always_ff @(posedge inclock)
  begin
    q <= mem[rdaddress];

    if (wren)
      mem[wraddress] <= data;
  end

endmodule


module fifo256x16
(
  input wire clock,
  input wire [15:0] data,
  output wire [15:0] q,
  input wire rdreq,
  input wire wrreq,
  output wire empty,
  output wire full
);

  reg [8:0] cnt = 1'b0;
  reg [7:0] rptr = 1'b0;
  reg [7:0] wptr = 1'b0;

  assign empty = ~|cnt;
  assign full = cnt[8];

  always_ff @(posedge clock)
  begin
    if (rdreq)
      rptr++;

    if (wrreq)
      wptr++;

    if (rdreq ^^ wrreq)
      cnt <= cnt + (wrreq ? 1'b1 : -1'd1);
  end

  ram256x16 fifo_ram
  (
    .inclock        (clock),
    .rdaddress      (rptr),
    .q              (q),
    .wraddress      (wptr),
    .data           (data),
    .wren           (wrreq)
  );

endmodule
