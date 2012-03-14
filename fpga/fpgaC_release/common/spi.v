// part of NeoGS project (c) 2007-2008 NedoPC
//

// clock:   ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^ (positive edges)
// counter: |00|00|10|11|12|13|14|15|16|17|18|19|1A|1B|1C|1D|1E|1F|00|00|00 // internal!
// sck:   ___________/``\__/``\__/``\__/``\__/``\__/``\__/``\__/``\_______
// sdo:   --------< do7 X do6 X do5 X do4 X do3 X do2 X do1 X do0 >-------
// sdi:   --------< di7 X di6 X di5 X di4 X di3 X di2 X di1 X di0 >-------
// bsync: ________/`````\_________________________________________________
// start: _____/``\_______________________________________________________
// din:   -----<IN>-------------------------------------------------------
// dout:   old old old old old old old old old old old old old | new new new

// data on sdo must be latched by slave on rising sck edge. data on sdo changes on falling edge of sck
//
// data from sdi is latched by master on positive edge of sck, while slave changes it on falling edge.
//  WARNING: slave must emit valid di7 bit BEFORE first pulse on sck!
//
// bsync is 1 while do7 is outting, otherwise it is 0
//
// start is synchronous pulse, which starts all transfer and also latches din data on the same clock edge
//  as it is registered high. start can be given anytime (only when halfspeed=0),
//  so it is functioning then as synchronous reset
//
// dout updates with freshly received data at the clock edge in which sck goes high for the last time, thus
//  latching last bit on sdi.
//
// data transfer rate could be as fast as one byte every 16 clock pulses. To achieve that, start must be pulsed
//  high simultaneously with the last high pulse of sck
//
// when halfspeed=1, there must be at least 34 clock pulses between starts

module spi(

	clock, // system clock

	sck,   // SPI bus outputs
	sdo,   //
	sdi,   //
	bsync, // and bsync for vs1001

	start, // positive strobe that starts transfer

	halfspeed, // =0 - sck full speed (1/2 of clock), =1 - half (1/4 of clock)

	din,  // input
	dout  // and output 8bit busses
);

	input clock;


	output sck;
	wire   sck;

	output sdo;

	input sdi;

	output reg bsync;

	input start;

	input halfspeed;

	input [7:0] din;

	output reg [7:0] dout;



	// internal regs

	reg [4:0] counter; // governs transmission

	wire enable_n; // =1 when transmission in progress

	reg [6:0] shiftin; // shifting in data from sdi before emitting it on dout

	reg [7:0] shiftout; // shifting out data to the sdo

	wire ena_shout_load; // enable load of shiftout register

	reg g_ena;


	initial // for simulation only!
	begin
		counter = 5'b10000;
		shiftout = 8'd0;
		shiftout = 7'd0;
		bsync = 1'd0;
		dout <= 1'b0;
	end




	// sck is low bit of counter
	assign sck = counter[0];

	// enable_n is high bit of counter
	assign enable_n = counter[4];

	// sdo is high bit of shiftout
	assign sdo = shiftout[7];

	assign ena_shout_load = (start | sck) & g_ena;




	always @(posedge clock)
	begin
		if( g_ena )
		begin
			if( start )
			begin
				counter <= 5'b00000; // enable_n = 0; sck = 0;
				bsync <= 1'b1; // begin bsync pulse
			end
			else
			begin
				if( !sck ) // on the rising edge of sck
				begin
      	                  shiftin[6:0] <= { shiftin[5:0], sdi };

					if( (&counter[3:1]) && (!enable_n) )
						dout <= { shiftin[6:0], sdi }; // update dout at the last sck rising edge
				end
				else // on the falling edge of sck
				begin
					bsync <= 1'b0;
				end

				if( !enable_n )
					counter <= counter + 5'd1;
			end
		end
	end


	// shiftout treatment is done so just to save LCELLs in acex1k
	always @(posedge clock)
	begin
		if( ena_shout_load )
		begin
			if( start )
				shiftout <= din;
			else // sck
				shiftout[7:0] <= { shiftout[6:0], shiftout[0] }; // last bit remains after end of exchange
		end
	end


	// half speed - governed by g_ena
	always @(posedge clock)
	begin
		if( halfspeed )
		begin
			if( start )
				g_ena <= 1'b0;
			else if( enable_n )
				g_ena <= 1'b1;
			else
				g_ena <= ~g_ena;
		end
		else
			g_ena <= 1'b1;
	end



endmodule
