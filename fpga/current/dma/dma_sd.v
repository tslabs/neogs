// part of NeoGS project
//
// (c) NedoPC 2007-2013
//
// SD-card dma controller

/*

 supports yet:
  1. only read of SD card (512 bytes at once)
  2. only full bursing writeback of read data to memory

 SD read algo:
 send FFs always. Check replies.
 After first non-FF reply receive 512 bytes into FPGA mem then into RAM
  
*/


module dma_sd
(
	input  wire clk,
	input  wire rst_n,

	// control to spi module of SD-card
	//
	output wire       sd_start,
	input  wire       sd_rdy,
	input  wire [7:0] sd_recvdata,

	
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
	output reg  [21:0] dma_addr,
	output wire  [7:0] dma_wd,   // data written to DMA
	output wire        dma_rnw,
	//
	output wire        dma_req,
	input  wire        dma_ack,
	input  wire        dma_end,

	output wire        int_req
);

	reg dma_on;

	wire dma_finish;

	reg [3:0] state, next_state;

	wire wdone,rdone;
	
	reg int_dma_req;



	assign int_req = dma_finish;



	localparam _HAD = 2'b00; // high address
	localparam _MAD = 2'b01; // mid address
	localparam _LAD = 2'b10; // low address
	localparam _CST = 2'b11; // control and status



	// control dout bus
	always @*
	case( regsel[1:0] )
		_HAD: dout = { 2'b00,  dma_addr[21:16] };
		_MAD: dout =           dma_addr[15:8];
		_LAD: dout =           dma_addr[7:0];
		_CST: dout = { dma_on, 7'bXXX_XXXX };
	endcase


	// dma_on control
	always @(posedge clk, negedge rst_n)
	if( !rst_n )
		dma_on <= 1'b0;
	else if( dma_finish )
		dma_on <= 1'b0;
	else if( module_select && write_strobe && (regsel==_CST) )
		dma_on <= din[7];


	// dma_addr control
	always @(posedge clk)
	if( dma_req && dma_ack && dma_on )
		dma_addr <= dma_addr + 22'd1; // increment on successfull DMA transfer
	else if( module_select && write_strobe )
	begin
		if( regsel==_HAD )
			dma_addr[21:16] <= din[5:0];
		else if( regsel==_MAD )
			dma_addr[15:8]  <= din[7:0];
		else if( regsel==_LAD )
			dma_addr[7:0]   <= din[7:0];
	end






	// controlling FSM

	localparam _IDLE   = 4'd0;
	localparam _WRDY1  = 4'd1;
	localparam _WRDY2  = 4'd2;
	localparam _RECV1  = 4'd3;
	localparam _RECV2  = 4'd4;
	localparam _CRC1   = 4'd5;
	localparam _CRC2   = 4'd6;
	localparam _DMAWR  = 4'd7;
	localparam _STOP   = 4'd8;


	always @(posedge clk, negedge dma_on)
	if( !dma_on )
		state = _IDLE;
	else // posedge clk
		state <= next_state;

	always @*
	case( state )

	_IDLE: next_state = _WRDY1;
	
	_WRDY1:begin
		next_state = _WRDY2;
	end
	
	_WRDY2:begin	
		if( 	!sd_rdy )
		                next_state = _WRDY2;
		else	 if( sd_recvdata==8'hFF )
		    	    next_state = _WRDY1;
		else         if( sd_recvdata==8'hFE )
		    	    next_state = _RECV1;
		else	
		    	    next_state = _STOP;
	end         
                    	
	_RECV1:begin	
		if( !wdone )
			next_state = _RECV2;
		else
			next_state = _CRC1;
	end

	_RECV2:begin
		if( !sd_rdy )
			next_state = _RECV2;
		else
			next_state = _RECV1;
	end

	_CRC1:begin // 1st CRC byte is already started in last _RECV1 state
		if( !sd_rdy )
			next_state = _CRC1;
		else
			next_state = _CRC2;
	end

	_CRC2:begin // here just start 2nd CRC byte receive
		next_state = _DMAWR;
	end

	_DMAWR:begin
		if( int_dma_req )
			next_state = _DMAWR;
		else
			next_state = _STOP;
	end

	_STOP:begin
		next_state = _STOP; // rely on dma_on going to 0 and resetting everything
	end
	
	endcase


	// sd_start
	assign sd_start = ( state==_WRDY1 || state==_RECV1 || state==_CRC2 );

	
	// dma_finish
	assign dma_finish = ( state==_STOP );

	
	

	

	// only dma writes
	assign dma_rnw = 1'b0;

	assign dma_req = int_dma_req;

	always @(posedge clk, negedge dma_on)
	if( !dma_on )
		int_dma_req <= 1'b0;
	else if( state==_CRC2 )
		int_dma_req <= 1'b1;
	else if( rdone && dma_ack )
		int_dma_req <= 1'b0;



	// fifo
	dma_fifo_oneshot dma_fifo_oneshot
	(
		.clk  (clk   ),
		.rst_n(dma_on),
        
		.wr_stb( state==_RECV2 && sd_rdy ),
		.rd_stb( (dma_req && dma_ack) || state==_CRC2 ),
        
		.wdone(wdone),
		.rdone(rdone),
		.empty(     ),
		.w511 (     ),
        
		.wd(sd_recvdata),
		.rd(dma_wd     )
	);
	
	

endmodule




