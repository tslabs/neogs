// modelling dma_sequencer.v together with dma_access.v

`define CLK_PERIOD 40

//`define NO_CPU

module tb;


   parameter DEVNUM = 4;


   integer i,j,k;


	reg clk,rst_n;

	reg can_go;

   tri1 iorq_n,mreq_n,rd_n,wr_n;
   tri0 busrq_n,busak_n;
   trireg [15:0] zaddr;
   tri  [7:0] zdata;


   wire dma_req,dma_rnw;
   wire dma_ack,dma_end;
   wire dma_busynready;

   wire [20:0] dma_addr;
   wire  [7:0] dma_wd;
   wire  [7:0] dma_rd;

   tri0 [DEVNUM-1:0] req;
   tri1 [DEVNUM-1:0] rnw;
   wire [DEVNUM-1:0] done;
   wire [DEVNUM-1:0] ack;

   tri0[20:0] addr[0:DEVNUM-1];
   tri0 [7:0]   wd[0:DEVNUM-1];
   wire [7:0]   rd;



   wire mem_dma_bus;
   wire [15:0] mem_dma_addr;
   wire [7:0] mem_dma_wd;
   wire [7:0] mem_dma_rd;
   wire mem_dma_rnw;
   wire mem_dma_oe;
   wire mem_dma_we;



	initial
	begin
		clk = 1'b0;
		forever #(`CLK_PERIOD/2) clk = ~clk;
	end




`ifndef NO_CPU
   T80a z80( .RESET_n(rst_n),
             .CLK_n(clk),
             .WAIT_n(1'b1),
             .INT_n(1'b1),
             .NMI_n(1'b1),
             .MREQ_n(mreq_n),
             .IORQ_n(iorq_n),
             .RD_n(rd_n),
             .WR_n(wr_n),
             .BUSRQ_n(busrq_n),
             .BUSAK_n(busak_n),
             .A(zaddr),
             .D(zdata) );
`endif



   rom myrom( .addr(zaddr),
              .data(zdata),
              .ce_n( (zaddr<16'h8000)?(mreq_n|rd_n):1'b1 ) );


   assign zaddr = mem_dma_bus ? mem_dma_addr[15:0] : 16'hZZZZ;

   assign zdata = (mem_dma_bus&(!mem_dma_rnw)) ? mem_dma_wd : 8'hZZ;
   assign mem_dma_rd = zdata;

   ram myram( .addr(zaddr),
              .data(zdata),
              .ce_n( (zaddr>=16'h8000)?1'b0:1'b1 ),
              .oe_n( mem_dma_bus ? mem_dma_oe : (mreq_n|rd_n) ),
              .we_n( mem_dma_bus ? mem_dma_we : (mreq_n|wr_n) ) );


   dma_sequencer myseq( .clk(clk),
                        .rst_n(rst_n),

                        .rd   (rd),

                        .addr0(addr[0]),
                        .wd0  (wd[0]),
                        .req0 (req[0]),
                        .rnw0 (rnw[0]),
                        .ack0 (ack[0]),
                        .end0 (done[0]),

                        .addr1(addr[1]),
                        .wd1  (wd[1]),
                        .req1 (req[1]),
                        .rnw1 (rnw[1]),
                        .ack1 (ack[1]),
                        .end1 (done[1]),

                        .addr2(addr[2]),
                        .wd2  (wd[2]),
                        .req2 (req[2]),
                        .rnw2 (rnw[2]),
                        .ack2 (ack[2]),
                        .end2 (done[2]),

                        .addr3(addr[3]),
                        .wd3  (wd[3]),
                        .req3 (req[3]),
                        .rnw3 (rnw[3]),
                        .ack3 (ack[3]),
                        .end3 (done[3]),




                        .dma_req(dma_req),
                        .dma_rnw(dma_rnw),
                        .dma_ack(dma_ack),
                        .dma_end(dma_end),
                        .dma_addr(dma_addr),
                        .dma_wd(dma_wd),
                        .dma_rd(dma_rd) );


	dma_access mydma( .dma_req(dma_req),
	                  .dma_rnw(dma_rnw),
	                  .dma_ack(dma_ack),
	                  .dma_end(dma_end),
	                  .dma_addr(dma_addr),
	                  .dma_wd(dma_wd),
	                  .dma_rd(dma_rd),

	                  .dma_busynready(dma_busynready),

	                  .mem_dma_rd(zdata),
	                  .mem_dma_wd(mem_dma_wd),
	                  .mem_dma_bus(mem_dma_bus),
	                  .mem_dma_addr(mem_dma_addr),
	                  .mem_dma_rnw(mem_dma_rnw),
	                  .mem_dma_oe(mem_dma_oe),
	                  .mem_dma_we(mem_dma_we),

	                  .clk(clk),
	                  .rst_n(rst_n),
	                  .busrq_n(busrq_n),
	                  .busak_n(busak_n) );



	generate
		genvar gv;
		for(gv=0;gv<DEVNUM;gv=gv+1)
		begin : instantiate_testers

			dma_tester #( .BEG_ADDR(21'h0A000+21'd4096*gv) ) mytest (
			              .clk(clk),
			              .can_go(can_go),

			              .req(req[gv]),
			              .rnw(rnw[gv]),
			              .wd(wd[gv]),
			              .addr(addr[gv]),
			              .ack(ack[gv]),
			              .done(done[gv]),
			              .rd(rd)
			);
		end
	endgenerate




/*
	reg start  [0:DEVNUM-1];
	reg rnw_in [0:DEVNUM-1];
	wire inprogress [0:DEVNUM-1];

	generate
		genvar gv;
		for(gv=0;gv<DEVNUM;gv=gv+1)
		begin : dmaers
			dmaer g( .clk(clk), .rst_n(rst_n),
			         .start(start[gv]),
			         .rnw_in(rnw_in[gv]),
			         .inprogress(inprogress[gv]),
			         .req(req[gv]),
			         .rnw(rnw[gv]),
			         .ack(ack[gv]),
			         .done(done[gv]) );
		end
	endgenerate
*/





	initial
	begin
		rst_n  = 1'b0;
		can_go = 1'b0;

		for(i=0;i<DEVNUM;i=i+1)
		begin
			//start[i]  = 1'b0;
			//rnw_in[i] = 1'b1;
			//addr[i]   = 21'h8001;
			//wd[i] = 1+i+(i<<2)+(i<<6);
		end


		repeat(4) @(posedge clk);

		rst_n <= 1'b1;

		repeat(10) @(posedge clk);

		can_go <= 1'b1;




/*		start[1] <= 1'b1;
		@(posedge ack[1]);
		start[1] <= 1'b0;

		@(negedge inprogress[1]);

		repeat (5) @(posedge clk);



		rnw_in[1] = 1'b0;
		rnw_in[1] = 1'b1;
		rnw_in[1] = 1'b1;
		rnw_in[1] = 1'b1;
		start[0] = 1'b1;
		start[1] = 1'b1;
		start[2] = 1'b1;
		start[3] = 1'b1;

		fork
		begin
			repeat (3) @(posedge ack[0]);
			start[0] <= 1'b0;
		end
		begin
			repeat (3) @(posedge ack[1]);
			start[1] <= 1'b0;
			repeat(9) @(posedge clk);
			start[1] <= 1'b1;
			repeat(2) @(posedge ack[1]);
			start[1] <= 1'b0;
		end
		begin
			repeat(13) @(posedge ack[2]);
			start[2] <= 1'b0;
		end
		begin
			repeat(17) @(posedge ack[3]);
			start[3] <= 1'b0;
		end
		join
*/

//		$stop;



	end




endmodule




module dmaer(

	input  wire clk,
	input  wire rst_n,

	input  wire start,
	input  wire rnw_in,

	output reg  inprogress,

	output reg  req,
	output reg  rnw,
	input  wire ack,
	input  wire done
);


	initial
	begin
		inprogress = 1'b0;
		req        = 1'b0;
		rnw        = 1'b1;
	end


	always @(negedge rst_n)
	begin
		disable main_loop;

		req = 1'b0;
		rnw = 1'b1;
		inprogress = 1'b0;
	end


	always
	begin : main_loop

		wait(rst_n);

		wait(start);

	      begin : dma_loop
			forever
			begin
				inprogress <= 1'b1;
				rnw <= rnw_in;
				req <= 1'b1;

				@(negedge ack);
				if( !start ) disable dma_loop;
			end
		end

		req <= 1'b0;
		wait(done);/*@(posedge done);*/
		inprogress <= 1'b0;
	end



endmodule

