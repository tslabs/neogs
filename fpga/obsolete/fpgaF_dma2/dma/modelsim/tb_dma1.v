// modelling dma_access.v in both burst and one-shot modes

module tb_dma1;

   integer i,j,k;


   tri1 iorq_n,mreq_n,rd_n,wr_n;
   reg clk,rst_n;
   wire busrq_n,busak_n;
   trireg [15:0] zaddr;
   tri  [7:0] zdata;


   reg dma_req, dma_rnw;
   wire dma_busynready;
   wire mem_dma_bus;
   wire [15:0] mem_dma_addr;
   wire [7:0] mem_dma_wd;
   wire [7:0] mem_dma_rd;
   wire mem_dma_rnw;
   wire mem_dma_oe;
   wire mem_dma_we;

   reg [7:0] wridat;


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


   dma_access mydma( .dma_req(dma_req),
                     .dma_rnw(dma_rnw),
                     .dma_addr(21'h08001),
                     .dma_wd(wridat),
                     .mem_dma_rd(zdata),
                     .mem_dma_wd(mem_dma_wd),
                     .dma_busynready(dma_busynready),
                     .mem_dma_bus(mem_dma_bus),
                     .mem_dma_addr(mem_dma_addr),
                     .mem_dma_rnw(mem_dma_rnw),
                     .mem_dma_oe(mem_dma_oe),
                     .mem_dma_we(mem_dma_we),
                     .clk(clk),
                     .rst_n(rst_n),
                     .busrq_n(busrq_n),
                     .busak_n(busak_n) );




	initial
	begin
      wridat <= 8'hA5;
		clk = 1'b0;
            forever #40 clk = ~clk;
	end

	initial
	begin
		rst_n <= 1'b0;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		rst_n <= 1'b1;
	end


	initial
	begin
		dma_req <= 1'b0;
		dma_rnw <= 1'b1;

		@(posedge rst_n);


		forever
		begin
			for(i=1;i<5;i=i+1) // one-shot dma requests
			begin
				@(posedge clk);
				@(posedge clk);
				@(posedge clk);
				@(posedge clk);
				@(posedge clk);
				@(posedge clk);
				@(posedge clk);
				dma_req <= 1'b1;
				@(posedge dma_busynready);
				@(posedge clk);
				dma_req <= 1'b0;
				dma_rnw <= ~dma_rnw;
				@(negedge dma_busynready);
            wridat <= wridat + 8'h01;
			end



			@(posedge clk);
			dma_req <= 1'b1;
			for(i=1;i<10;i=i+1) // burst dma requests
			begin
				@(negedge dma_busynready);
            wridat <= wridat + 8'h01;
				dma_rnw <= ~dma_rnw;
			end

			dma_req <= 1'b0;
		end
	end




endmodule
