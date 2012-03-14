module rom(
	input [15:0] addr,
	output reg [7:0] data,
	input ce_n
);

	always @*
	begin
		if( ce_n )
			data <= 8'bZZZZZZZZ;
		else
//			data <= 8'h00; // NOPs
      case(addr)
         16'h0000: data<=8'h21; // ld hl,aa55
         16'h0001: data<=8'h55;
         16'h0002: data<=8'haa;
         16'h0003: data<=8'h22; // ld (8001),hl
         16'h0004: data<=8'h01;
         16'h0005: data<=8'h80;
         16'h0006: data<=8'h3a; // ld a,(8001)
         16'h0007: data<=8'h01;
         16'h0008: data<=8'h80;
         16'h0009: data<=8'hd3; // out (0),a
         16'h000a: data<=8'h00;
         16'h000b: data<=8'h3a; // ld a,(8002)
         16'h000c: data<=8'h02;
         16'h000d: data<=8'h80;
         16'h000e: data<=8'hd3; // out (ff),a
         16'h000f: data<=8'hff;
         16'h0010: data<=8'hc3; // jp 0
         16'h0011: data<=8'h00;
         16'h0012: data<=8'h00;
         default: data<=8'h00;
      endcase

	end




endmodule

