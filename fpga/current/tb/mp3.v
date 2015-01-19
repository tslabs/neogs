// (c) NedoPC 2013
//
// MP3 data receiver for testing MP3 and SD dmas

`timescale 1ns/100ps

module mp3
(
	input  wire  clk,
	input  wire  sync,
	input  wire  data,

	output reg   req
);

	integer bitcnt;

	reg [7:0] buffer;
	reg [7:0] tmp;


	int waitcnt;



	initial req = 1'b1;


	always @(posedge clk)
	begin
		if( sync )
			bitcnt = 7;

		if( sync && !req )
		begin
			$display("mp3: byte started while req=0!");
			$stop;
		end

		if( !(bitcnt<=7 && bitcnt>=0) )
		begin
			$display("mp3: sync error!");
			$stop;
		end

		buffer[bitcnt] = data;

		if( bitcnt=='d0 )
		begin
			tmp = tb.sdmp3_chk.pop_front();
			
			if( tmp!==buffer )
			begin
				$display("mp3: data mismatch!");
				$stop;
			end
		end
		
		bitcnt = bitcnt - 1;
	end



	always @(negedge clk)
	begin
		if( bitcnt=='d0 )
		begin
			if( $random>32'hd000_0000 )
			begin
				req <= 1'b0;

				waitcnt = 1+($random&63);

				repeat( waitcnt ) @(posedge tb.clk_fpga);

				req <= 1'b1;
			end
		end
	end


endmodule


