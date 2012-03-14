// part of NeoGS project
//
// (c) NedoPC 2007-2009
//
// ZX dma controller
//
// includes dma address regs, dma control reg
//
// CURRENTLY ONLY READ ON ZXBUS SIDE FROM NGS MEM, error in WAIT generation! zx_dma2.v - further development

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

	reg [2:0] zxdmaread_sync;  // syncing appropriate zxbus signals
	reg [2:0] zxdmawrite_sync;

	reg zxread_begin, zxwrite_begin; // 1-cycle positive pulses based on synced in zxdmaread and zxdmawrite
	reg zxread_end,   zxwrite_end;   //


	reg dma_prereq; // to help assert dma_req one cycle earlier



	reg [1:0] waena_state,waena_next; // and wait_ena generation

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
	always @(posedge clk)
	begin
		zxdmaread_sync[2:0]  <= { zxdmaread_sync[1:0],  zxdmaread  };
		zxdmawrite_sync[2:0] <= { zxdmawrite_sync[1:0], zxdmawrite };
	end

	always @*
	begin
		zxread_begin  <= zxdmaread_sync[1]  && (!zxdmaread_sync[2]);
		zxwrite_begin <= zxdmawrite_sync[1] && (!zxdmawrite_sync[2]);

		zxread_end  <= (!zxdmaread_sync[1])  && zxdmaread_sync[2];
		zxwrite_end <= (!zxdmawrite_sync[1]) && zxdmawrite_sync[2];
	end



	// temporary: dma_rnw always at read state
	always @* dma_rnw = 1'b1;



	// FSM for wait_enable

	localparam waenaIDLE = 0;
	localparam waenaWAIT = 1;

	always @(posedge clk, negedge rst_n)
	if( !rst_n )
		waena_state <= waenaIDLE;
	else if( !dma_on )
		waena_state <= waenaIDLE;
	else
		waena_state <= waena_next;

	always @*
	case( waena_state )
		waenaIDLE:
			if( zxread_end && (!dma_end) )
				waena_next <= waenaWAIT;
			else
				waena_next <= waenaIDLE;
		waenaWAIT:
			if( dma_end )
				waena_next <= waenaIDLE;
			else
				waena_next <= waenaWAIT;
	endcase

	always @(posedge clk, negedge rst_n)
	if( !rst_n )
		wait_ena <= 1'b0;
	else if( !dma_on )
		wait_ena <= 1'b0;
	else
	case( waena_next )
		waenaIDLE:
			wait_ena <= 1'b0;
		waenaWAIT:
			wait_ena <= 1'b1;
	endcase



	// FSM for dma request

	localparam dmarqIDLE = 0;
	localparam dmarqREQ1 = 1;
	localparam dmarqREQ2 = 2;

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
			if( zxread_begin )
				dmarq_next <= dmarqREQ1;
			else
				dmarq_next <= dmarqIDLE;
		dmarqREQ1:
			if( dma_ack && (!zxread_begin) )
				dmarq_next <= dmarqIDLE;
			else if( (!dma_ack) && zxread_begin )
				dmarq_next <= dmarqREQ2;
			else // nothing or both zxread_begin and dma_ack
				dmarq_next <= dmarqREQ1;
		dmarqREQ2:
			if( dma_ack )
				dmarq_next <= dmarqREQ1;
			else
				dmarq_next <= dmarqREQ2;
	endcase

	always @(posedge clk, negedge rst_n)
	if( !rst_n )
		dma_prereq <= 1'b0;
	else
	case( dmarq_next )
		dmarqIDLE:
			dma_prereq <= 1'b0;
		dmarqREQ1:
			dma_prereq <= 1'b1;
		dmarqREQ2:
			dma_prereq <= 1'b1;
	endcase

	always @* dma_req <= (dma_prereq | zxread_begin) & dma_on;


	// pick up data from DMA

	always @(posedge clk) if( dma_end ) dma_rd_temp <= dma_rd;

	always @(posedge clk)
	begin
		if( zxread_end && dma_end ) // simultaneously coming zxread_end and dma_end: get data directly from dma
			dma_rd_data <= dma_rd;
		else if( dma_end && wait_ena ) // dma_end was after zxread_end: get data directly from dma
			dma_rd_data <= dma_rd;
		else if( zxread_end )
			dma_rd_data <= dma_rd_temp; // we can always corrupt dma_rd_data at zxread_end strobe, even if we
			                            // will overwrite it with newer arrived data later
	end


endmodule

