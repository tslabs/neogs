// part of NeoGS project (c) 2007-2009 NedoPC
//
// ZXBUS interface module
// Features:
// I. provides IORQGE generation via zxblkiorq_n output on addresses $xxB3, $xxBB and $xx33
// II.  Asynchronously outs data_reg_in or data_bit and command bit to zxbus
// III. Asynchronouly latches in data_reg_out and command_reg_out from zxbus
// IV.  Synchronously updates data_bit and command_bit according to zxbus activity,
//       or sets it to *_bit_in value when *_bit_wr is 1
// V.   Generates nmi_n negative 8-clock pulse when $010xxxxx is written to $xx33 port.
//      Initiates internal reset when $100xxxxx is written to $xx33 port
//      Toggles LED when $001xxxxx is written
// VI.  Manages zx-dma
//

module zxbus(

	zxid, // zxbus DATA BUS in/out [7:0]
	zxa, // zxbus ADDRESS 7-0 in [7:0]
	zxa14,zxa15, // zxbus ADDRESS 14,15
	zxiorq_n,zxmreq_n, // zxbus /IORQ,/MREQ
	zxrd_n,zxwr_n, // zxbus /RD, /WR
	zxcsrom_n, // zxbus /CSROM
	zxblkiorq_n, // active low - signals to generate IORQGE
	zxblkrom_n, // active low - signals to block onboard zx ROM
	zxgenwait_n, // active low - signals to generate /WAIT to ZXBUS
	zxbusin, // controls 74hct245 buffer direction (1 - input from bus, 0 - output to zx)
	zxbusena_n, // 74hct245 buffer enable signal


	// ports related
	command_reg_out, // output data of command register (asynchronous)

	data_reg_out, // output data of data register (asynchronous)
	data_reg_in, // input data of data register (asynchronous)

	data_bit, // data bit out (synchronous to cpu_clock)
	command_bit, // command bit out (synchronous to cpu_clock)

	data_bit_in, // input data to be written to data bit
	command_bit_in, // input data to be written to command bit

	data_bit_wr, // write strobe (positive), which writes data from data_bit_in to data_bit (sync to cpu_clock)
	command_bit_wr, // write strobe (positive), which writes data from command_bit_in to command_bit (sync to cpu_clock)
	//

	// DMA related
	dma_on, // input, must be 1 for DMA to operate

	wait_ena, // input, asynchronously resets wait trigger (signal synchronous to cpu_clock of NGS)

	dmaread,  // for use in dma_zx module
	dmawrite, //

	dma_data_written,  // output, stores data last written by ZX
	dma_data_toberead, // input, shows data for ZX to read



	rst_from_zx_n, // reset out to NGS z80 indicating board must be reset
	nmi_n, // nmi out to NGS z80 (2^NMI_CNT_SIZE cpu_clock periods low pulse) - synchronous!

	led_toggle,

	rst_n, // chip-wide reset input (some critical init)

	cpu_clock // NGS Z80 CPU clock in (clk_fpga on schematics)

);

	parameter NMI_CNT_SIZE = 2;

	localparam GSCOM  = 8'hBB;
	localparam GSSTAT = GSCOM;
	localparam GSDAT  = 8'hB3;
	localparam GSCTR  = 8'h33;

// INPUTS/OUTPUTS of module

	inout wire [7:0] zxid;

	input [7:0] zxa;
	input zxa14,zxa15;
	input zxiorq_n,zxmreq_n;
	input zxrd_n,zxwr_n;

	input zxcsrom_n;

	output reg zxblkiorq_n,zxblkrom_n,zxbusin,zxbusena_n,zxgenwait_n;

	output reg [7:0] command_reg_out;

	output reg [7:0] data_reg_out;

	input [7:0] data_reg_in;

	output reg data_bit;

	output reg command_bit;

	input data_bit_in;
	input command_bit_in;

	input data_bit_wr;
	input command_bit_wr;


	input dma_on;

	output dmaread;  // =1 when dma enabled and ZX reads from 0000-3fff and ROM is ON (csrom_n active)
	output dmawrite; // =1 when dma enabled and ZX writes to 0000-3fff (no ROM dependent)

	input wait_ena;

	output reg [7:0] dma_data_written;
	input      [7:0] dma_data_toberead;


	output reg rst_from_zx_n;

	output reg nmi_n;

	output reg led_toggle;

	input cpu_clock;

	input rst_n;

// internal regs and wires

	wire [7:0] dbin; // input data from zx data bus
	reg [7:0] dbout; // output to the zx data bus

	wire [7:0] zxlowaddr; // low address on ZX address bus
	wire zxdataport; // =1 when data port address selected ($B3)
	wire zxcommport; // =1 when command port address selected ($BB)
	wire zxrstport;  // =1 when reset/nmi port address selected ($33)

	wire zxiord_n; // = iorq_n | rd_n
	wire zxiowr_n; // = iorq_n | wr_n



	wire dmaread;  // =1 when dma enabled and ZX reads from 0000-3fff and ROM is ON (csrom_n active)
	wire dmawrite; // =1 when dma enabled and ZX writes to 0000-3fff (no ROM dependent)
	wire romaddr;  // =1 when rom address is on zxbus


	reg [2:0] rddataport; // for                    data_bit
	reg [2:0] wrdataport; //    synchronous       of        and
	reg [2:0] wrcommport; //               control             command_bit

	reg async_rst_toggle; // asynchronous toggles on writes to port $33
	reg async_nmi_toggle;
	reg async_led_toggle;

	reg [2:0] sync_rst_toggle; // syncing toggles in and detect edges
	reg [2:0] sync_nmi_toggle; // generate z80res or nmi on every edge
	reg [2:0] sync_led_toggle; // LED toggle on every edge

	reg prezxrst1,prezxrst2; // reset out (rst_from_zx_n) must have some negation delay when rst_n asserts

	reg [NMI_CNT_SIZE:0] nmi_counter; // counter to make 2^NMI_CNT_SIZE cpu_clock's pulses, plus stopbit

// actual code
//---------------------------------------------------------------------------

// zx data bus control

	assign dbin[7:0] = zxid;

	// control tri-state in-outs of internal zx data bus (zxid)
/*	always @*
	begin
		if( (!zxbusin) && (!zxbusena_n) )
			zxid <= dbout[7:0];
		else
			zxid <= 8'bZZZZZZZZ;
	end
*/
	assign zxid = ( !zxbusin && !zxbusena_n ) ? dbout : 8'bZZZZ_ZZZZ;


	// control both state of zxid and state of external '245 buffer
	always @*
	begin
		if( ((!zxiord_n) && ( zxdataport || zxcommport )) || dmaread )
			zxbusin = 1'b0;
		else
			zxbusin = 1'b1;

		if( ( ((!zxiowr_n) || (!zxiord_n) ) && ( zxdataport || zxcommport || zxrstport )) || dmaread || dmawrite )
			zxbusena_n <= 1'b0;
		else
			zxbusena_n <= 1'b1;
	end

	// control data to be out on the bus
	always @*
	begin
		if( dmaread )
			dbout = dma_data_toberead;
		else
			case( {zxdataport,zxcommport} )
				3'b10:	dbout <= data_reg_in;
				3'b01:	dbout <= { data_bit, 6'bXXXXXX, command_bit };
				default:	dbout <= 8'hXX;
			endcase
	end
// +




// zx address decoder, IORQGE generator

	assign zxdataport = (zxa == GSDAT); // =1 when $B3
	assign zxcommport = (zxa == GSCOM); // =1 when $BB
	assign zxrstport  = (zxa == GSCTR); // =1 when $33

	always @*
	begin
		if( zxdataport || zxcommport || zxrstport ) // address if any of ports is on bus
			zxblkiorq_n <= 1'b0;                  // generate IORQGE!
		else
			zxblkiorq_n <= 1'b1;
	end
// +


// zx DMA related things

	// zx ROM address decoder
	assign romaddr = ( {zxa15,zxa14}==2'b00 );

	// block zx rom access if dma is on
	always @*
	begin
		if( romaddr && dma_on )
			zxblkrom_n = 1'b0;
		else
			zxblkrom_n = 1'b1;
	end

	// control /WAIT pin of ZXBUS
	always @*
	begin
		if( dma_on && romaddr && (!zxmreq_n) ) // on write cycles, /WAIT is accepted at the same clock edge
			zxgenwait_n = ~wait_ena;         // the Z80 begins /WR, so we can't use /WR (and then /RD)
		else                                   // for /WAIT strobing
			zxgenwait_n = 1'b1;
	end

	// zx to dma write and read pulses
	assign dmaread  = dma_on & romaddr & (~zxmreq_n) & (~zxrd_n) & (~zxcsrom_n);
	assign dmawrite = dma_on & romaddr & (~zxmreq_n) & (~zxwr_n);

	// store data
	always @(negedge dmawrite) dma_data_written <= dbin; // probably GLITCHES here!!!
// +




// I/O RD and WR strobes

	assign zxiord_n = zxiorq_n | zxrd_n;
	assign zxiowr_n = zxiorq_n | zxwr_n;
// +


// write from zxbus to the data register

	always @(posedge zxiowr_n)
	begin
		if( zxdataport )
		begin
			data_reg_out <= dbin;
		end
	end
	// +

// write from zxbus to the command register

	always @(posedge zxiowr_n)
	begin
		if( zxcommport )
		begin
			command_reg_out <= dbin;
		end
	end
	// +




// SYNCHRONOUS PART
// ---------------------------------------------------

// synchronous control of port writes and reads

	always @(posedge cpu_clock) // sync in read and write states
	begin
		rddataport[2:0] <= { rddataport[1:0], zxdataport&(~zxiord_n) };
		wrdataport[2:0] <= { wrdataport[1:0], zxdataport&(~zxiowr_n) };
		wrcommport[2:0] <= { wrcommport[1:0], zxcommport&(~zxiowr_n) };
	end


	// data_bit

	wire data_bit_local_clr = (rddataport[2:1]==2'b10);
	wire data_bit_local_set = (wrdataport[2:1]==2'b10);

/*	always @(posedge cpu_clock)
	begin
		if( rddataport[2:1]==2'b10 )
		begin
			data_bit <= 1'b0; // clear on data port reading by ZX (after end of cycle)
		end
		else if( wrdataport[2:1]==2'b10 )
		begin
			data_bit <= 1'b1; // set on data port writing by ZX
		end
		else if( data_bit_wr==1'b1 )
		begin
			data_bit <= data_bit_in; // or load from internal NGS operation
		end
	end
*/
	always@(posedge cpu_clock)
	case( { data_bit_local_clr, data_bit_local_set, data_bit_wr } )
		// usual cases
		3'b100: data_bit <= 1'b0; // clear on data port reading by ZX (after end of cycle)
		3'b010: data_bit <= 1'b1; // set on data port writing by ZX
		3'b001: data_bit <= data_bit_in; // or load from internal NGS operation

		// combinational cases
		3'b101: begin
			if( data_bit_in==1'b0 )
				data_bit <= 1'b0;
			// else if data_bit_in==1'b1 -- leave unchanged
		end

		3'b011: begin
			if( data_bit_in==1'b1 )
				data_bit <= 1'b1;
			// else if data_bit_in==1'b0 -- leave unchanged
		end

		// default: unchanged
	endcase



	// command bit

	wire command_bit_local_set = (wrcommport[2:1]==2'b10);
/*
	always @(posedge cpu_clock)
	begin
		if( wrcommport[2:1]==2'b10 )
		begin
			command_bit <= 1'b1; // set on command port writing by ZX
		end
		else if( command_bit_wr==1'b1 )
		begin
			command_bit <= command_bit_in; // or load from internal NGS operation
		end
	end
*/
	always @(posedge cpu_clock)
	case( { command_bit_local_set, command_bit_wr } )

		2'b10: command_bit <= 1'b1;
		2'b01: command_bit <= command_bit_in;

		2'b11: begin
			if( command_bit_in==1'b1 )
				command_bit <= 1'b1;
		end

	endcase




///////////////////////////////
// handle reset/nmi port $33 //
///////////////////////////////

	always @(negedge rst_n,posedge zxiowr_n)
	begin
		if( !rst_n )
		begin
			async_rst_toggle <= 1'b0;
			async_nmi_toggle <= 1'b0;
			async_led_toggle <= 1'b0;
		end
		else if( zxrstport )
		begin
			if( dbin[7:5]==3'b100 )
				async_rst_toggle <= ~async_rst_toggle;

			if( dbin[7:5]==3'b010 )
				async_nmi_toggle <= ~async_nmi_toggle;

			if( dbin[7:5]==3'b001 )
				async_led_toggle <= ~async_led_toggle;
		end
	end
	// +



	always @(negedge rst_n, posedge cpu_clock)
	begin
		if( !rst_n )
		begin
			sync_rst_toggle[2:0] <= 3'd0;
			sync_nmi_toggle[2:0] <= 3'd0;
			sync_led_toggle[2:0] <= 3'd0;
			nmi_counter[NMI_CNT_SIZE:0] <= 32'hFFFFFFFF;
			prezxrst1 <= 1'b1;
			nmi_n <= 1'b1;

			led_toggle <= 1'b0;
		end
		else // rst_n=1
		begin
			sync_rst_toggle[2:0] <= { sync_rst_toggle[1:0], async_rst_toggle };
			sync_nmi_toggle[2:0] <= { sync_nmi_toggle[1:0], async_nmi_toggle };
			sync_led_toggle[2:0] <= { sync_led_toggle[1:0], async_led_toggle };

	            if( sync_rst_toggle[2] != sync_rst_toggle[1] )
	            begin
				prezxrst1 <= 1'b0;
	            end

			if( sync_nmi_toggle[2] != sync_nmi_toggle[1] )
	            begin
				nmi_counter[NMI_CNT_SIZE:0] <= 0;
	            end
			else
			begin
				if( !nmi_counter[NMI_CNT_SIZE] )
					nmi_counter <= nmi_counter + 1;
			end

			nmi_n <= nmi_counter[NMI_CNT_SIZE];


			if( sync_led_toggle[2] != sync_led_toggle[1] )
				led_toggle <= 1'b1;
			else
				led_toggle <= 1'b0;
		end
	end
	// +

	always @(posedge cpu_clock)
	begin
		prezxrst2     <= prezxrst1;
		rst_from_zx_n <= prezxrst2;
	end
	// +


endmodule

