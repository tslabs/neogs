/* --- Audio DAC t/b --- */
  wire dac_fifo_wreq = !dac_fifo_full;
  // wire [15:0] dac_fifo_in = 16'b1010101010101001;
  wire [15:0] dac_fifo_in = {!aaa[6], {15{aaa[6]}}};

  reg [24:0] aaa;
  always @(posedge clk_24mhz)
    if (dac_fifo_wreq)
      aaa <= aaa + 1'd1;


