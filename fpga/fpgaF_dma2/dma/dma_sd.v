// part of NeoGS project
//
// (c) NedoPC 2007-2009
//
// SD-card dma controller
//
// includes dma address regs, dma control reg
/*

 Read from sd-card modes:

  1. Full burst: first all 512 bytes are read into 512b buffer, then dma-bursted into main memory.
     Not as fast in latency, but steals minimum of CPU cycles, though stops cpu for 1024+ clocks (if no other DMAs are active)

  2. As soon as possible: initiates DMA as soon as new byte is arrived into 512b buffer.
     Makes bursts of 2-3 bytes, when applicable (more bytes arriven since beginning of dma_req up to acknowledge in dma_ack)

 Write to sd-card modes:

  1. Full burst: all 512 bytes are read in one burst, transmission starts as soon as first byte arrives to the buffer.
     Uses minimum of CPU cycles (1024+) but in one chunk.

  2. DMA initiated as soon as spi is again ready to initiate new transfer (kind a throttling). Probably DMA pulls 2 or 4 bytes at once.

Structure:
 
 - FIFO based on mem512b and two pointers
 
 - SD controller - FSM which either reads or writes SD-card SPI iface
 
 - DMA controller - FSM which either reads or writes DMA iface
 
 - overall control - Controls operation of everything above, controls muxing of data to the
   SD write port and FIFO write port, tracks operation end, maintains DMA_ADDRESS registers.

*/


module dma_sd(

	input  wire clk,
	input  wire rst_n,

	// control to spi module of SD-card
	//
	output reg        sd_start,
	input  wire       sd_rdy,
	input  wire [7:0] sd_receiveddata,
	output wire [7:0] sd_datatosend,
	//
	output reg        sd_override, // when 1, override sd_start and sd_datatosend to the sd spi module



	// signals for ports.v
	//
	input  wire [7:0] din,  // input and output from ports.v
	output reg  [7:0] dout,
	//
	input  wire       module_select, // =1 - module selected for read-write operations from ports.v
	input  wire       write_strobe,  // one-cycle positive write strobe - writes to the selected registers from din
	//
	input  wire [1:0] regsel, // 2'b00 - high address, 2'b01 - middle address, 2'b10 - low address, 2'b11 - control register

	// signals for DMA controller/DMA sequencer
	//
	output reg  [20:0] dma_addr,
	output wire  [7:0] dma_wd,   // data written to DMA
	input  wire  [7:0] dma_rd,   // data read from DMA
	output reg         dma_rnw,
	//
	output wire        dma_req,
	input  wire        dma_ack,
	input  wire        dma_end
);
	localparam _HAD = 2'b00; // high address
	localparam _MAD = 2'b01; // mid address
	localparam _LAD = 2'b10; // low address
	localparam _CST = 2'b11; // control and status


	reg dma_snr;   // Send-NotReceive. Send to SDcard (==1) or Receive (==0) from it.
	reg dma_burst; // whether burst transfers are on





	// control dout bus
	always @*
	case( regsel[1:0] )
		_HAD: dout = { 3'b000, dma_addr[20:16] };
		_MAD: dout =           dma_addr[15:8];
		_LAD: dout =           dma_addr[7:0];
		_CST: dout = { dma_on, 5'bXXXXX, dma_burst, dma_snr};
	endcase

	// ports.v write access & dma_addr control
	always @(posedge clk, negedge rst_n)
	if( !rst_n ) // async reset
	begin
		dma_on    <= 1'b0;
		dma_snr   <= 1'b0; // receive is less dangerous since it won't destroy SDcard info
		dma_burst <= 1'b0;
	end
	else // posedge clk
	begin
		// dma_on control
		if( module_select && write_strobe && (regsel==_CST) )
		begin
			dma_on    <= din[7];
			dma_burst <= din[1];
			dma_snr   <= din[0];
		end
		else if( dma_finish )
		begin
			dma_on <= 1'b0;
		end

		// dma_addr control
		if( dma_ack && dma_on )
			dma_addr <= dma_addr + 21'd1; // increment on beginning of DMA transfer
		else if( module_select && write_strobe )
		begin
			if( regsel==_HAD )
				dma_addr[20:16] <= din[4:0];
			else if( regsel==_MAD )
				dma_addr[15:8]  <= din[7:0];
			else if( regsel==_LAD )
				dma_addr[7:0]   <= din[7:0];
		end
	end



// fifo,dma,sd control FSMs/etc.
	
	reg init;
	wire wr_stb,rd_stb;
	wire wdone,rdone,empty;

	wire [7:0] fifo_wd; // data for FIFO to be written
	wire [7:0] fido_rd; // data read from FIFO

	// MUX data to FIFO
	assign fifo_wd       = dma_snr ? dma_rd  : sd_receiveddata;
	// MUX data to SDcard
	assign sd_datatosend = dma_snr ? fifo_rd : 8'hFF;
	
	// connect dma in to fifo out without muxing
	assign dma_wd = fifo_rd;

	fifo512_oneshot fifo512_oneshot ( .clk(clk),
	                                  .rst_n(rst_n),

	                                  .init(init),

	                                  .wr_stb(wr_stb),
	                                  .rd_stb(rd_stb),

	                                  .wdone(wdone),
	                                  .rdone(rdone),
	                                  .empty(empty),

	                                  .wd(fifo_wd),
	                                  .rd(fifo_rd)
	                                );
	// fifo control
	reg sd_wr_stb,sd_rd_stb;   // set in SD FSM
	reg dma_wr_stb,dma_rd_stb; // set in DMA FSM
	//	
	assign wr_stb = sd_wr_stb | dma_wr_stb;
	assign rd_stb = sd_rd_stb | dma_rd_stb;

	// dma control
	wire dma_put_req;
	wire dma_get_req;
	
	assign dma_req = dma_put_req | dma_get_req;



	reg sd_go; // start strobe for SD FSM
	reg sd_idle; // whether SD FSM is idle

	reg dma_go;
	reg dma_idle;






	// SD-card controlling FSM
	
	reg [2:0] sd_state, sd_next_state;
	
	localparam SD_IDLE   = 3'b000;
	localparam SD_READ1  = 3'b100;
	localparam SD_READ2  = 3'b101;
	localparam SD_WRITE1 = 3'b110;
	localparam SD_WRITE2 = 3'b111;
	
	always @(posedge clk, negedge rst_n)
	begin
		if( !rst_n )
		begin
			sd_state = SD_IDLE;
		end
		else // posedge clk
		begin
			sd_state <= sd_next_state;
		end
	end

	always @*
	begin
		case( sd_state )
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		SD_IDLE:begin
			if( sd_go )
			begin
				if( sd_snr ) // send to SD
				begin
					sd_next_state = SD_WRITE1;
				end
				else // !sd_snr: read from SD
				begin
					sd_next_state = SD_READ1;
				end
			end
			else
			begin
				sd_next_state = SD_IDLE;
			end
		end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		SD_READ1:begin
			if( wdone )
			begin
				sd_next_state = SD_IDLE;
			end
			else // !wdone - can still send bytes to the fifo
			begin
				if( !sd_rdy ) // not ready with previous byte - wait here
				begin
					sd_next_state = SD_READ1;
				end
				else // sd_rdy - can proceed further
				begin
					sd_next_state = SD_READ2;
				end
			end
		end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		SD_READ2:begin
			sd_next_state = SD_READ1;
		end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		SD_WRITE1:begin
			if( rdone )
			begin
				sd_next_state = SD_IDLE;
			end
			else
			begin
				if( sd_rdy && !empty ) // whether sd ready and we can take next byte from fifo
				begin
					sd_next_state = SD_WRITE2;
				end
				else // can't start next byte: wait
				begin
					sd_next_state = SD_WRITE1;
				end
			end
		end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		SD_WRITE2:begin
			sd_next_state = SD_WRITE1;
		end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		default:begin
			sd_next_state = SD_IDLE;
		end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		endcase
	end

	always @(posedge clk, negedge rst_n)
	begin
		if( !rst_n )
		begin
			sd_wr_stb   = 1'b0;
			sd_rd_stb   = 1'b0;
			sd_start    = 1'b0;
			sd_override = 1'b0;
		
			sd_idle     = 1'b0;
		end
		else // posedge clk
		begin
			case( sd_next_state )
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			SD_IDLE:begin
				sd_wr_stb   <= 1'b0;
				sd_rd_stb   <= 1'b0;
				sd_start    <= 1'b0;
				sd_override <= 1'b0;
				
				sd_idle     <= 1'b1;
			end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			SD_READ1:begin
				sd_override <= 1'b1; // takeover SD card SPI iface
				sd_start    <= 1'b0;
				sd_wr_stb   <= 1'b0;
				
				sd_idle     <= 1'b0;
			end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			SD_READ2:begin
				sd_start  <= 1'b1; // trigger new SPI exchange
				sd_wr_stb <= 1'b1; // trigger FIFO write
			end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			SD_WRITE1:begin
				sd_override <= 1'b1;
				sd_start    <= 1'b0;
				sd_rd_str   <= 1'b0;
				
				sd_idle     <= 1'b0;
			end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			SD_WRITE2:begin
				sd_start  <= 1'b1;
				sd_rd_stb <= 1'b1;
			end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			endcase
		end
	end
	





	// DMA-controlling FSM

	reg [3:0] dma_state, dma_next_state
	
	localparam DMA_IDLE
	localparam DMA_PUT_WAIT
	localparam DMA_PUT_RUN

	always @(posedge clk, negedge rst_n)
	begin
		if( !rst_n )
		begin
			dma_state = DMA_IDLE;
		end
		else // posedge clk
		begin
			dma_state <= dma_next_state;
		end
	end

	always @*
	begin
		case( dma_state )
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		DMA_IDLE:begin
			if( dma_go )
			begin
				if( dma_snr )
				begin
					........dma_state = DMA_GET_WAIT;
				end
				else // !dma_snr
				begin
					dma_next_state = DMA_PUT_WAIT;
				end
			end
			else
			begin
				dma_next_state = DMA_IDLE;
			end
		end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		DMA_PUT_WAIT:begin
			if( rdone )
			begin
				dma_next_state = DMA_IDLE;
			end
			else // !rdone
			begin
				if( !empty ) // fifo is not empty
				begin
					dma_next_state = DMA_PUT_RUN;
				end
				else // fifo empty
				begin
					dma_next_state = DMA_PUT_WAIT;
				end
			end
		end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		DMA_PUT_RUN:begin
			if( rdone )
			begin
				dma_next_state = DMA_IDLE;
			end
			else
			begin
				if( empty )
				begin
					dma_next_state = DMA_PUT_WAIT;
				end
				else // !empty
				begin
					dma_next_state = DMA_PUT_RUN;
				end
			end
		end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		endcase
	end
	
	always @(posedge clk, negedge rst_n)
	begin
		if( !rst_n )
		begin
		
		end
		else // posedge clk
		begin
			case( dma_next_state )
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			endcase
		end
	end






























endmodule




// this is "one-shot" fifo: after each 512 bytes both written and read back, it must be initialized by means of 'init'
//
module fifo512_oneshot(

	input  wire clk,
	input  wire rst_n,
	
	input  wire init, // initializes fifo: wptr=rptr=0
	
	input  wire wr_stb, // write strobe: writes data from wd to the current wptr, increments wptr
	input  wire rd_stb, // read strobe: increments rptr
	
	output wire wdone, // write done - all 512 bytes are written (end of write operation)
	output wire rdone, // read done - all 512 bytes are read (end of read operation)
	output wire empty, // fifo empty: when wptr==rptr (rd_stb must not be issued when empty is active, otherwise everytrhing desyncs)
	
	input  wire [7:0] wd, // data to be written
	output wire [7:0] rd  // data just read from rptr address
);

	reg [9:0] wptr;
	reg [9:0] rptr;

	always @(posedge clk, negedge rst_n)
	begin
		if( !rst_n )
		begin
			wptr = 10'd0;
			rptr = 10'd0;
		end
		else
		begin // posedge clk
		
			if( init )
			begin
				wptr <= 10'd0;
			end
			else if( wr_stb )
			begin
				wptr <= wptr + 10'd1;
			end
		
		
			if( init )
			begin
				rptr <= 10'd0;
			end
			else if( rd_stb )
			begin
				rptr <= rptr + 10'd1;
			end
		
		end
	end

	assign wdone = wptr[9];
	assign rdone = rptr[9];
	assign empty = ( wptr==rptr );



	mem512b fifo512_oneshot_mem512b( .clk(clk),

	                                 .rdaddr(rptr[8:0]),
	                                 .dataout(rd),

	                                 .wraddr(wptr[8:0]),
	                                 .datain(wd),
	                                 .we(wr_stb)
	                               );
endmodule
