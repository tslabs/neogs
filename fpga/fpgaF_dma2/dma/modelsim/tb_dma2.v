// modelling dma_sequencer.v together with dma_access.v

module tb_dma2;


   parameter DEVNUM = 4;


   integer i,j,k;


   tri1 iorq_n,mreq_n,rd_n,wr_n;
   reg clk,rst_n;
   wire busrq_n,busak_n;
   trireg [15:0] zaddr;
   tri  [7:0] zdata;


   wire dma_req,dma_rnw;
   wire dma_ack,dma_end;
   wire dma_busynready;

   wire [20:0] dma_addr;
   wire  [7:0] dma_wd;
   wire  [7:0] dma_rd;

   reg  [DEVNUM:1] req;
   reg  [DEVNUM:1] rnw;
   wire [DEVNUM:1] done;
   wire [DEVNUM:1] ack;

   reg [20:0] addr[1:DEVNUM];
   reg  [7:0]   wd[1:DEVNUM];
   reg  [7:0]   rd;



   wire mem_dma_bus;
   wire [15:0] mem_dma_addr;
   wire [7:0] mem_dma_wd;
   wire [7:0] mem_dma_rd;
   wire mem_dma_rnw;
   wire mem_dma_oe;
   wire mem_dma_we;



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

                        .addr(addr),
                        .wd(wd),
                        .rd(rd),
                        .req(req),
                        .rnw(rnw),
                        .ack(ack),
                        .done(done),

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



	reg start  [1:DEVNUM];
	reg rnw_in [1:DEVNUM];
	wire inprogress [1:DEVNUM];



	generate
		genvar gv;
		for(gv=1;gv<=DEVNUM;gv=gv+1)
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




	initial
	begin
		clk <= 1'b0;
            forever #40 clk <= ~clk;
	end


	initial
	begin
		rst_n <= 1'b0;

		for(i=1;i<=DEVNUM;i=i+1)
		begin
			start[i] <= 1'b0;
			rnw_in[i] <= 1'b1;
		end


		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		rst_n <= 1'b1;
		@(posedge clk);




/*		start[1] <= 1'b1;
		@(posedge ack[1]);
		start[1] <= 1'b0;

		@(negedge inprogress[1]);
*/
		repeat (5) @(posedge clk);



		rnw_in[1] = 1'b1;
		rnw_in[2] = 1'b0;
		start[1] = 1'b1;
		start[2] = 1'b1;

		fork
		begin
			@(posedge ack[1]);
			start[1] <= 1'b0;
		end
		begin
			@(posedge ack[2]);
			start[2] <= 1'b0;
		end
		join


//		$stop;



	end




endmodule




module dmaer(

	input clk,
	input rst_n,

	input start,
	input rnw_in,

	output reg inprogress,

	output reg req,
	output reg rnw,
	input      ack,
	input      done
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

		req <= 1'b0;
		rnw <= 1'b1;
		inprogress <= 1'b0;
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

