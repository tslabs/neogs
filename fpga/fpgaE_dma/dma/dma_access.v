// part of NeoGS project
//
// (c) NedoPC 2007-2008
//
// modelling is in tb_dma1.*
// look also at dma_access.png

module dma_access(

	input            clk,

	input            rst_n,


	input            dma_req,  // DMA request
	input     [20:0] dma_addr, // DMA address (2mb)
	input            dma_rnw,  // DMA READ/nWRITE
	input      [7:0] dma_wd,   // DMA data to write
	output reg [7:0] dma_rd,   // DMA data just read

	output reg       dma_busynready, // DMA BUSY/nREADY
	output reg       dma_ack, // positive pulse as dma_busynready goes high
	output reg       dma_end, // positive pulse as dma_busynready goes low

	output wire        mem_dma_bus,  // DMA taking over the bus
	output wire [20:0] mem_dma_addr, // DMA address going to the bus
	output wire  [7:0] mem_dma_wd,   // DMA data going to the bus
	input        [7:0] mem_dma_rd,   // DMA data going from the bus
	output wire        mem_dma_rnw,  // DMA bus direction (1=read, 0=write)
	output reg         mem_dma_oe,   // DMA read strobe going to the bus
	output reg         mem_dma_we,   // DMA write pulse going to the bus


	output reg       busrq_n, // CPU       signals
	input            busak_n  //    control
);

	reg dma_bus;

	reg [20:0] int_dma_addr;
	reg        int_dma_rnw;
	reg  [7:0] int_dma_wd;
	wire [7:0] int_dma_rd;

	assign mem_dma_bus  = dma_bus;
	assign mem_dma_addr = int_dma_addr;
	assign mem_dma_wd   = int_dma_wd;
	assign mem_dma_rnw  = int_dma_rnw;
	assign int_dma_rd   = mem_dma_rd;



	localparam IDLE     = 0;
	localparam START    = 1;
	localparam WACK     = 2;
	localparam READ1    = 3;
	localparam READ2    = 4;
	localparam WRITE1   = 5;
	localparam WRITE2   = 6;


	reg [3:0] state;
	reg [3:0] next_state;




	// for simulation purposes
	initial
	begin
		state       <= IDLE;
		busrq_n     <= 1'b1;
		mem_dma_oe  <= 1'b1;
		mem_dma_we  <= 1'b1;
	end


// FSM
	always @(posedge clk, negedge rst_n)
	begin
		if( !rst_n )
			state <= IDLE;
		else
			state <= next_state;
	end


	always @*
	begin
		case( state )
//////////////////////////////////////////////////////////////////////////////////////////
		IDLE:
		begin
			if( dma_req==1'b1 )
				next_state <= START;
			else
				next_state <= IDLE;
		end
//////////////////////////////////////////////////////////////////////////////////////////
		START:
		begin
			next_state <= WACK;
		end
//////////////////////////////////////////////////////////////////////////////////////////
		WACK:
		begin
			if( busak_n == 1'b1 ) ///// ACHTUNG WARNING!!! probably use here registered busak?
				next_state <= WACK;
			else // busak_n == 1'b0
			begin
				if( int_dma_rnw == 1'b1 ) // read
					next_state <= READ1;
				else // int_dma_rnw == 1'b0 - write
					next_state <= WRITE1;
			end
		end
//////////////////////////////////////////////////////////////////////////////////////////
		READ1:
		begin
			next_state <= READ2;
		end
//////////////////////////////////////////////////////////////////////////////////////////
		READ2:
		begin
			if( dma_req == 1'b0 )
				next_state <= IDLE;
			else // dma_req == 1'b1
			begin
				if( dma_rnw == 1'b1 ) // next is read
					next_state <= READ1;
				else // dma_rnw == 1'b0 - next is write
					next_state <= WRITE1;
			end
		end
//////////////////////////////////////////////////////////////////////////////////////////
		WRITE1:
		begin
			next_state <= WRITE2;
		end
//////////////////////////////////////////////////////////////////////////////////////////
		WRITE2:
		begin
			if( dma_req == 1'b0 )
				next_state <= IDLE;
			else // dma_req == 1'b1
			begin
				if( dma_rnw == 1'b1 ) // next is read
					next_state <= READ1;
				else // dma_rnw == 1'b0 - next is write
					next_state <= WRITE1;
			end
		end
//////////////////////////////////////////////////////////////////////////////////////////
		endcase
	end


	always @(posedge clk, negedge rst_n)
	begin
		if( !rst_n )
		begin
			busrq_n        <= 1'b1;
			dma_busynready <= 1'b0;
			dma_ack        <= 1'b0;
			dma_end        <= 1'b0;
			dma_bus        <= 1'b0;
			mem_dma_oe     <= 1'b1;
		end
		else case( next_state )
//////////////////////////////////////////////////////////////////////////////////////////
		IDLE:
		begin
			dma_end        <= 1'b0;

			busrq_n        <= 1'b1;
			dma_bus        <= 1'b0;
			mem_dma_oe     <= 1'b1;
		end
//////////////////////////////////////////////////////////////////////////////////////////
		START:
		begin
//			dma_bus        <= 1'b0; // if rst=0>1 and dma_ack=1 --> ??? is this really needed?


			busrq_n        <= 1'b0;

			dma_busynready <= 1'b1;
			dma_ack        <= 1'b1;

			int_dma_rnw    <= dma_rnw;
			int_dma_addr   <= dma_addr;
			int_dma_wd     <= dma_wd;
		end
//////////////////////////////////////////////////////////////////////////////////////////
		WACK:
		begin
			dma_ack <= 1'b0;
		end
//////////////////////////////////////////////////////////////////////////////////////////
		READ1:
		begin
			dma_bus    <= 1'b1; // take over the bus
			mem_dma_oe <= 1'b0;
			if( dma_busynready == 1'b0 ) // if we are here from READ2 or WRITE2
			begin
				dma_busynready <= 1'b1;
				dma_ack        <= 1'b1;
				dma_end        <= 1'b0;
				int_dma_rnw    <= 1'b1;
				int_dma_addr   <= dma_addr;
			end
		end
//////////////////////////////////////////////////////////////////////////////////////////
		READ2:
		begin
			dma_busynready <= 1'b0;
			dma_ack        <= 1'b0;
			dma_end        <= 1'b1;
			dma_rd <= int_dma_rd;
		end
//////////////////////////////////////////////////////////////////////////////////////////
		WRITE1:
		begin
			dma_bus    <= 1'b1; // take over the bus
			mem_dma_oe <= 1'b1;

			if( dma_busynready == 1'b0 ) // from READ2 or WRITE2
			begin
				dma_busynready <= 1'b1;
				dma_ack        <= 1'b1;
				dma_end        <= 1'b0;
				int_dma_rnw    <= 1'b0;
				int_dma_addr   <= dma_addr;
				int_dma_wd     <= dma_wd;
			end
		end
//////////////////////////////////////////////////////////////////////////////////////////
		WRITE2:
		begin
			dma_busynready <= 1'b0;
			dma_ack        <= 1'b0;
			dma_end        <= 1'b1;
		end
//////////////////////////////////////////////////////////////////////////////////////////
		endcase
	end




// mem_dma_we generator

	always @(negedge clk,negedge rst_n)
	begin
		if( !rst_n )
			mem_dma_we <= 1'b1;
		else
		begin
			if( dma_bus )
			begin
				if( !int_dma_rnw )
					mem_dma_we <= ~mem_dma_we;
			end
			else
				mem_dma_we <= 1'b1;
		end
	end


endmodule

