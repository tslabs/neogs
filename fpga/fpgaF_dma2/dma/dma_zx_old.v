// part of NeoGS project
//
// (c) NedoPC 2007-2009
//
// ZX dma controller
//
// includes dma address regs, dma control reg
//

module dma_zx(

	input clk,
	input rst_n,


	// ZXBUS-related signals

	input dma_zxread_toggle;
	input dma_zxwrite_toggle;

	output reg dma_reswait_n;

	input      [7:0] dma_data_written;
	output reg [7:0] dma_data_toberead;


	// different global & control signals

	output reg dma_on;


	// signals from ports.v

	input      [7:0] din;  // input and output from ports.v
	output reg [7:0] dout;

	input module_select; // =1 - module selected for read-write operations from ports.v
	input write_strobe; // one-cycle positive write strobe - writes to the selected registers from din

	input [1:0] regsel; // 2'b00 - high address, 2'b01 - middle address, 2'b10 - low address, 2'b11 - control register


	// signals for DMA controller

      output reg [20:0] dma_addr;
      output reg  [7:0] dma_wd;
      input       [7:0] dma_rd;
      output reg        dma_rnw;

      output reg dma_req;
      input      dma_ack;
      input      dma_done;

);

	wire zxrd,zxwr; // zx read and write indicators, =1 when zx just done the thing. must be cleared.
	reg zxoldrd,zxoldwr;
	reg zxclr; // clear zxrd or zxwr
	reg [2:0] zxrdtgl, zxwrtgl; // syncing in dma_zx(read|write)_toggle

	//zxrd or zxwr first set to 1 when zx**tgl[2]!=zx**tgl[1], then it supported in 1 state from zxold** flipflop
	//by asserting zxclr=1 for 1 cycle, zxold** are both cleared.


	localparam _HAD = 2'b00; // high address
	localparam _MAD = 2'b01; // mid address
	localparam _LAD = 2'b10; // low address
	localparam _CST = 2'b11; // control and status





	// control dout bus
	always @*
	case( regsel[1:0] )
		_HAD: dout = { 3'b000, dma_addr[20:16] };
		_MAD: dout = dma_addr[15:8];
		_LAD: dout = dma_addr[7:0];
		_CST: dout = { dma_on, 7'bXXXXXXX };
	endcase

	// ports.v write access & dma_addr control
	always @(posedge clk, negedge rst_n)
	if( !rst_n ) // async reset
	begin
		dma_on <= 1'b0;
	end
	else // posedge clk
	begin
		// dma_on control
		if( module_select && write_strobe && (regsel==_CST) )
			dma_on <= din[7];

		// dma_addr control
		if( dma_ack && dma_on )
			dma_addr <= dma_addr + 20'd1; // increment on beginning of DMA transfer
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

	// dma_zx(read|write)_toggle syncing in and zxrd/zxwr strobes
	always @(posedge clk,negedge rst_n)
	if( !rst_n )
	begin
		zxoldrd <= 1'b0;
		zxoldwr <= 1'b0;
	end
	else //posedge clk
	begin
		if( dma_on )
		begin
			if( zxrdtgl[2] != zxrdtgl[1] )
				zxoldrd <= 1'b1;
			else if( zxclr )
				zxoldrd <= 1'b0;

			if( zxwrtgl[2] != zxwrtgl[1] )
				zxoldwr <= 1'b1;
			else if( zxclr )
				zxoldwr <= 1'b0;
		end
		else
		begin
			zxoldrd <= 1'b0;
			zxoldwr <= 1'b0;
		end
	end

	always @(posedge clk)
	begin
		zxrdtgl[2:0] <= { zxrdtgl[1:0], dma_zxread_toggle  };
		zxwrtgl[2:0] <= { zxwrtgl[1:0], dma_zxwrite_toggle };
	end

	assign zxrd = ( zxrdtgl[2] != zxrdtgl[1] ) | zxoldrd;
	assign zxwr = ( zxwrtgl[2] != zxwrtgl[1] ) | zxoldwr;





endmodule

