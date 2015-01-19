// part of NeoGS project
//
// (c) NedoPC 2013
//
// mp3 data dma controller

module dma_mp3
(
	input  wire clk,
	input  wire rst_n,

	output wire [ 7:0] md_din,   // mp3 data interface
	output wire        md_start, //
	input  wire        md_rdy,   //
	input  wire        md_dreq,  //


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
	input  wire  [7:0] dma_rd,   // data read from DMA
	output wire        dma_rnw,
	//
	output reg         dma_req,
	input  wire        dma_ack,
	input  wire        dma_end,

	output wire        int_req
);
	reg dma_on;

	wire dma_finish;

	wire w511;
	wire rdone;

	reg [3:0] state,next_state;


	assign int_req = dma_finish;

	assign dma_rnw = 1'b1;





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




	localparam _IDLE  = 4'd0;
	localparam _START = 4'd1;
	localparam _DMARD = 4'd2;
	localparam _MP3W1 = 4'd3;
	localparam _MP3W2 = 4'd4;
	localparam _MP3W3 = 4'd5;
	localparam _STOP  = 4'd6;


	always @(posedge clk, negedge dma_on)
	if( !dma_on )
		state <= _IDLE;
	else
		state <= next_state;

	always @*
	case( state )
	_IDLE: next_state = _START;

	_START: next_state = _DMARD;

	_DMARD:begin
		if( dma_req )
			next_state = _DMARD;
		else
			next_state = _MP3W1;
	end

	_MP3W1: next_state = _MP3W2;

	_MP3W2:begin
		if( md_rdy && md_dreq )
			next_state = _MP3W3;
		else
			next_state = _MP3W2;
	end

	_MP3W3:begin
		if( rdone )
			next_state = _STOP;
		else
			next_state = _MP3W2;
	end

	_STOP: next_state = _STOP;

	endcase


	assign md_start = ( state==_MP3W3 );

	assign dma_finish = ( state==_STOP );



	always @(posedge clk, negedge dma_on)
	if( !dma_on )
		dma_req <= 1'b0;
	else if( state==_START )
		dma_req <= 1'b1;
	else if( dma_ack && w511 )
		dma_req <= 1'b0;




	dma_fifo_oneshot dma_fifo_oneshot
	(
		.clk  (clk   ),
		.rst_n(dma_on),
        
		.wr_stb( dma_end  ),
		.rd_stb( md_start || state==_MP3W1 ),
        
		.wdone(     ),
		.rdone(rdone),
		.empty(     ),
		.w511 (w511 ),
        
		.wd(dma_rd),
		.rd(md_din)
	);


endmodule

