// part of NeoGS project
//
// (c) NedoPC 2007-2009
//
// ZX dma controller
//
// includes dma address regs, dma control reg

module dma_zx(

	input clk,
	input rst_n,


	// ZXBUS-related signals

	input zxdmaread,  // async strobes made directly from zxbus signals
	input zxdmawrite, //

	input      [7:0] dma_wr_data, // data written by ZXBUS here
	output reg [7:0] dma_rd_data, // to be output to the ZXBUS from here

	output reg wait_ena, // for zxbus module, to stop temporarily ZX Z80




	// different global & control signals

	output reg dma_on,


	// signals from ports.v

	input      [7:0] din,  // input and output from ports.v
	output reg [7:0] dout,

	input module_select, // =1 - module selected for read-write operations from ports.v
	input write_strobe, // one-cycle positive write strobe - writes to the selected registers from din

	input [1:0] regsel, // 2'b00 - high address, 2'b01 - middle address, 2'b10 - low address, 2'b11 - control register


	// signals for DMA controller

      output reg [20:0] dma_addr,
      output reg  [7:0] dma_wd,
      input       [7:0] dma_rd,
      output reg        dma_rnw,

      output reg dma_req,
      input      dma_ack,
      input      dma_end

);

	reg [7:0] dma_rd_temp; // temporarily buffered read data from DMA module

	reg zxdmaread_sync;  // syncing appropriate zxbus signals - stage 1
	reg zxdmawrite_sync; //

	reg [1:0] zxdmaread_strobe;  // syncing zxbus signals: stage 2 and change detection
	reg [1:0] zxdmawrite_strobe; //


	reg zxread_beg, zxwrite_beg; // 1-cycle positive pulses based on synced in zxdmaread and zxdmawrite
	reg zxread_end, zxwrite_end; //


	reg dma_prireq; // primary dma request
	reg dma_prirnw; // primary rnw for dma request

	reg waitena_reg; // registered wait_ena
	reg waitena_fwd; // forwarded early wait_ena: output wait_ena made from both this signals


	reg [3:0] zdma_state, zdma_next; // main FSM for zx-dma

	reg [1:0] dmarq_state,dmarq_next; // DMA req gen



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



	// syncing in zxdmaread and zxdmawrite, making _begin and _end pulses
	always @(negedge clk) // forcing signals syncing in!
	begin
		zxdmaread_sync  <= zxdmaread;
		zxdmawrite_sync <= zxdmawrite;
	end

	always @(posedge clk)
	begin
		zxdmaread_strobe[1:0]  <= { zxdmaread_strobe[0],  zxdmaread_sync  };
		zxdmawrite_strobe[1:0] <= { zxdmawrite_strobe[0], zxdmawrite_sync };
	end

	always @*
	begin
		zxread_beg  <= zxdmaread_strobe[0]  && (!zxdmaread_strobe[1]);
		zxwrite_beg <= zxdmawrite_strobe[0] && (!zxdmawrite_strobe[1]);

		zxread_end  <= (!zxdmaread_strobe[0])  && zxdmaread_strobe[1];
		zxwrite_end <= (!zxdmawrite_strobe[0]) && zxdmawrite_strobe[1];
	end





	// main FSM for zx-dma control

	localparam zdmaIDLE       = 0;
	localparam zdmaREAD       = 1; // read cycle has begun
	localparam zdmaENDREAD1   = 2; // end read cycle: wait for zxread_end
	localparam zdmaENDREAD2   = 3; // end read cycle: data from dma_rd_temp to dma_rd_data
	localparam zdmaSTARTWAIT  = 4; // assert wait_ena
	localparam zdmaFWDNOWAIT1 = 5; // forward data from dma_rd to dma_rd_data, negate wait_ena, if any, go to zdmaREAD if zxread_beg
	localparam zdmaFWDNOWAIT2 = 6; // forward data from dma_rd to dma_rd_data, negate wait_ena, if any, go to zdmaREAD always
	localparam zdmaWAITED     = 7; // waited until dma_end
	localparam zdmaWRITEWAIT  = 8; // write wait

	always @(posedge clk, negedge rst_n)
	if( !rst_n )
		zdma_state <= zdmaIDLE;
	else if( !dma_on )
		zdma_state <= zdmaIDLE;
	else
		zdma_state <= zdma_next;


	always @*
	begin

		case( zdma_state )

		zdmaIDLE:
			if( zxread_beg )
				zdma_next = zdmaREAD;
			else if( zxwrite_end )
				zdma_next = zdmaWRITEWAIT;
			else
				zdma_next = zdmaIDLE;

		zdmaREAD:
			if( dma_end && zxread_end ) // both signal simultaneously
				zdma_next = zdmaFWDNOWAIT1;
			else if( zxread_end )
				zdma_next = zdmaSTARTWAIT;
			else if( dma_end )
				zdma_next = zdmaENDREAD1;
			else
				zdma_next = zdmaREAD;

		zdmaENDREAD1:
			if( zxread_end )
				zdma_next = zdmaENDREAD2;
			else
				zdma_next = zdmaENDREAD1;

		zdmaENDREAD2:
			if( zxread_beg )
				zdma_next = zdmaREAD;
			else
				zdma_next = zdmaIDLE;

		zdmaSTARTWAIT:
			if( dma_end && zxread_beg )
				zdma_next = zdmaFWDNOWAIT2;
			else if( dma_end )
				zdma_next = zdmaFWDNOWAIT1;
			else if( zxread_beg )
				zdma_next = zdmaWAITED;
			else if( zxwrite_beg ) // to prevent dead locks!
				zdma_next = zdmaIDLE;
			else
				zdma_next = zdmaSTARTWAIT;

		zdmaFWDNOWAIT1:
			if( zxread_beg )
				zdma_next = zdmaREAD;
			else
				zdma_next = zdmaIDLE;

		zdmaFWDNOWAIT2:
			zdma_next = zdmaREAD;

		zdmaWAITED:
			if( dma_end )
				zdma_next = zdmaFWDNOWAIT2;
			else
				zdma_next = zdmaWAITED;


		zdmaWRITEWAIT:
			if( dma_ack )
				zdma_next = zdmaIDLE;
			else if( zxread_beg )
				zdma_next = zdmaIDLE;
			else
				zdma_next = zdmaWRITEWAIT;


		endcase
	end

	//control read data forwarding
	always @(posedge clk)
		if( dma_end ) dma_rd_temp <= dma_rd;

	always @(posedge clk)
		case( zdma_next )
			zdmaENDREAD2:
				dma_rd_data <= dma_rd_temp;
			zdmaFWDNOWAIT1:
				dma_rd_data <= dma_rd;
			zdmaFWDNOWAIT2:
				dma_rd_data <= dma_rd;
		endcase


	// control wait_ena
	always @(posedge clk, negedge rst_n)
		if( !rst_n )
			waitena_reg <= 1'b0;
		else if( !dma_on )
			waitena_reg <= 1'b0;
		else if( (zdma_next == zdmaSTARTWAIT) || (zdma_next == zdmaWRITEWAIT) )
			waitena_reg <= 1'b1;
		else if( (zdma_state == zdmaFWDNOWAIT1) || (zdma_state == zdmaFWDNOWAIT2) || (zdma_state == zdmaIDLE) )
			waitena_reg <= 1'b0;

	always @*
		waitena_fwd = ( (zdma_state==zdmaREAD) && zxread_end && (!dma_end) ) || ( (zdma_state==zdmaIDLE) && zxwrite_end );

	always @*
		wait_ena = waitena_reg | waitena_fwd;





	// FSM for dma requests

	localparam dmarqIDLE   = 0;
	localparam dmarqRDREQ1 = 1;
	localparam dmarqRDREQ2 = 2;
	localparam dmarqWRREQ  = 3;

	always @(posedge clk, negedge rst_n)
	if( !rst_n )
		dmarq_state <= dmarqIDLE;
	else if( !dma_on )
		dmarq_state <= dmarqIDLE;
	else
		dmarq_state <= dmarq_next;

	always @*
	case( dmarq_state )

		dmarqIDLE:
			if( zxread_beg )
				dmarq_next <= dmarqRDREQ1;
			else if( zxwrite_end )
				dmarq_next <= dmarqWRREQ;
			else
				dmarq_next <= dmarqIDLE;

		dmarqRDREQ1:
			if( zxwrite_beg )
				dmarq_next <= dmarqIDLE; // to prevent dead ends!
			else if( dma_ack && (!zxread_beg) )
				dmarq_next <= dmarqIDLE;
			else if( (!dma_ack) && zxread_beg )
				dmarq_next <= dmarqRDREQ2;
			else // nothing or both zxread_beg and dma_ack
				dmarq_next <= dmarqRDREQ1;

		dmarqRDREQ2:
			if( dma_ack )
				dmarq_next <= dmarqRDREQ1;
			else
				dmarq_next <= dmarqRDREQ2;

		dmarqWRREQ:
			if( dma_ack || zxread_beg ) //zxread_beg - to prevent dead end!
				dmarq_next <= dmarqIDLE;
			else
				dmarq_next <= dmarqWRREQ;
	endcase

	always @(posedge clk, negedge rst_n)
	if( !rst_n )
		dma_prireq <= 1'b0;
	else
	case( dmarq_next )

		dmarqIDLE:
		begin
			dma_prireq <= 1'b0;
		end

		dmarqRDREQ1:
		begin
			dma_prireq <= 1'b1;
			dma_prirnw <= 1'b1;
		end

		dmarqRDREQ2:
		begin
			// nothing
		end

		dmarqWRREQ:
		begin
			dma_prireq <= 1'b1;
			dma_prirnw <= 1'b0;
		end

	endcase

	always @* dma_req <= (dma_prireq | zxread_beg | zxwrite_end ) & dma_on;

	always @*
		if( zxread_beg )
			dma_rnw <= 1'b1;
		else if( zxwrite_end )
			dma_rnw <= 1'b0;
		else
			dma_rnw <= dma_prirnw;

	always @* dma_wd <= dma_wr_data;


endmodule

