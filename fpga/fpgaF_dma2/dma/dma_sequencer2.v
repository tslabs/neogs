// part of NeoGS project (c) 2008-2009 NedoPC

// dma sequencer

/*

input interface of every DMA end-user

clocks: ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^
reqN    _______/```````````\______________/`````````````````\______________/``````````````````
ackN    ________________/``\_____________________________/``\____________________/``\__/``\__/
doneN   _________________________/``\_____________________________/``\______________/``\__/``\
rnwN    -------/```````````\--------------\_________________/--------------/````````\_____/```
adrwdN  -------< read addr >--------------< write addr&data >--------------< rdaddr X wra X rd
rdN     -------------------------<dd>-----------------------------------------------<dd>------


sequencing algorithm is round-robin with fixed initial prioritizing when multiple requests appear simultaneously while
everything was idle

*/


module dma_sequencer(

	input wire clk,
	input wire rst_n,

	// dma requests connection
	//
	input wire req0,
	input wire req1,
	input wire req2,
	input wire req3,

	input wire [20:0] addr0,
	input wire [20:0] addr1,
	input wire [20:0] addr2,
	input wire [20:0] addr3,

	input wire rnw0,
	input wire rnw1,
	input wire rnw2,
	input wire rnw3,

	input wire [7:0] wd0,
	input wire [7:0] wd1,
	input wire [7:0] wd2,
	input wire [7:0] wd3,


	output wire ack0,
	output wire ack1,
	output wire ack2,
	output wire ack3,

	output wire end0,
	output wire end1,
	output wire end2,
	output wire end3,

	output wire [7:0] rd,


//	dma controller connection
	output wire        dma_req,
	output wire [20:0] dma_addr,
	output wire        dma_rnw,
	output wire  [7:0] dma_wd,

	input  wire  [7:0] dma_rd,
	input  wire        dma_ack,
	input  wire        dma_end
);
	localparam DEVNUM = 4;



	wire [DEVNUM-1:0] reqs;
	wire       [20:0] addrs [0:DEVNUM-1];
	wire [DEVNUM-1:0] rnws;
	wire        [7:0] wds   [0:DEVNUM-1];
	wire [DEVNUM-1:0] acks;
	wire [DEVNUM-1:0] ends;


	// aggregate signals for brewity
	assign reqs[DEVNUM-1:0] = {req3,req2,req1,req0};
	assign addrs[0] = addr0;
	assign addrs[1] = addr1;
	assign addrs[2] = addr2;
	assign addrs[3] = addr3;
	assign rnws[DEVNUM-1:0] = {rnw3,rnw2,rnw1,rnw0};
	assign wds[0] = wd0;
	assign wds[1] = wd1;
	assign wds[2] = wd2;
	assign wds[3] = wd3;
	assign {ack3,ack2,ack1,ack0} = acks[DEVNUM-1:0];
	assign {end3,end2,end1,end0} = ends[DEVNUM-1:0];





	reg  [DEVNUM-1:0] cur_input_mux;  // which current input is muxed to the DMA  (input=req,ack,addr,wd)
	reg  [DEVNUM-1:0] cur_output_mux; // which current output is muxed to the DMA (output=end)

	wire [DEVNUM-1:0] next_input_mux;

	reg busy;


	always @(posedge clk, negedge rst_n)
	begin
		if( !rst_n )
			busy = 1'b0;
		else // posedge clk
		begin
			if( !busy )
				busy <= |reqs;
			else // busy
				busy <= dma_req;
		end
	end


	always @(posedge clk, negedge rst_n)
	begin
		if( !rst_n )
		begin
			cur_input_mux  = {DEVNUM{1'b0}};
		end
		else // posedge clk
		begin
			if( (!busy) || dma_ack ) // idle or dma acknoledges data receive
			begin
				cur_input_mux <= next_input_mux;
			end
		end
	end

	rr_arbiter #( .DEVNUM(DEVNUM) ) rr_arbiter(
		.reqs(reqs),
		.prev( cur_input_mux),
		.next(next_input_mux)
	);



	// output mux should follow input after dma_ack
	//
	always @(posedge clk, negedge rst_n)
	begin
		if( !rst_n )
		begin
			cur_output_mux = {DEVNUM{1'b0}};
		end
		else // posedge clk
		begin
			if( dma_ack )
				cur_output_mux <= cur_input_mux;
		end
	end





	// actual muxing of input data
	//
	wor         int_dma_req;  // wor is to do easily decoded AND-OR muxes
	wor  [20:0] int_dma_addr; //
	wand        int_dma_rnw;  // this is WAND to have it 1 in idle
	wor   [7:0] int_dma_wd;   //
	//
	genvar i;
	generate
		for(i=0;i<DEVNUM;i=i+1)
		begin : mux_dma_inputs

			assign int_dma_req  =     cur_input_mux[i]   &  reqs[i]; // wired OR happens!
			assign int_dma_addr = {21{cur_input_mux[i]}} & addrs[i]; //
			assign int_dma_rnw  =   (~cur_input_mux[i])  |  rnws[i]; // wired AND...
			assign int_dma_wd   =  {8{cur_input_mux[i]}} &   wds[i]; //
		end
	endgenerate
	//
	// output data to dma controller
	//
	assign dma_req  = int_dma_req;
	assign dma_addr = int_dma_addr;
	assign dma_rnw  = int_dma_rnw;
	assign dma_wd   = int_dma_wd;

	// actual de-muxing of output data from dma controller
	//
	assign acks = cur_input_mux  & {DEVNUM{dma_ack}};
	assign ends = cur_output_mux & {DEVNUM{dma_end}};
	//
	assign   rd = dma_rd; // read data does not need (de)muxing

endmodule






// round-robin arbiter
module rr_arbiter(
	/*input  wire [DEVNUM-1:0]*/ reqs,
	/*input  wire [DEVNUM-1:0]*/ prev,

	/*output wire [DEVNUM-1:0]*/ next
);
	parameter DEVNUM=4;


	input  wire [DEVNUM-1:0] reqs;
	input  wire [DEVNUM-1:0] prev;

	output wire [DEVNUM-1:0] next;



	genvar i;



	// arbitration if there was previous actives
	//
	wire [DEVNUM-1:0] loop;
	wire [DEVNUM-1:0] next_arb;

	generate
		for(i=0;i<DEVNUM;i=i+1)
		begin : gen_forwarders

			if( i==0 )
				rr_fwd forwarder( .prev(prev[i]),
				                  .req(reqs[i]),
				                  .next(next_arb[i]),
				                  .loop_in(loop[DEVNUM-1]),
				                  .loop_out(loop[i]) );
			else
				rr_fwd forwarder( .prev(prev[i]),
				                  .req(reqs[i]),
				                  .next(next_arb[i]),
				                  .loop_in(loop[i-1]),
				                  .loop_out(loop[i]) );
		end
	endgenerate


	// arbitration if there was no actives prior to requests
	//
	wire  [DEVNUM-1:0] next_empty;

	generate
		for(i=0;i<DEVNUM;i=i+1)
		begin : pri_enc
			if( i==0 )
			begin : pri_zero
				assign next_empty[0] = reqs[0];
			end
			else
			begin : pri_nonzero
				assign next_empty[i] = reqs[i] & ( ~|reqs[i-1:0] );
			end
		end
	endgenerate


	// select between prev-busy and prev-free cases
	assign next = ( prev ) ? next_arb : next_empty;

endmodule


// round-robin request forwarder (1 bit)
module rr_fwd(
	input  wire prev,  // who was arbitrated last time (one-hot)
	input  wire req,   // who are requesting
	output reg  next, // who will be next

	input  wire loop_in, // for internal arbitration
	output reg  loop_out //
);

	always @*
	begin
		if( prev )
		begin
			loop_out = 1'b1;
		end
		else //!prev
		begin
			loop_out = req ? 1'b0 : loop_in;
		end
	end

	always @*
	begin
		next = req ? loop_in : 1'b0;
	end

endmodule
