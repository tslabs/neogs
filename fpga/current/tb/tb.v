// (c) NedoPC 2013
//
// top-level for testing NGS

`timescale 1ns/100ps

`define HALF_24MHZ (20.8)
`define HALF_FPGA  (20.8)


module tb;

	reg clk_24mhz;
	reg clk_fpga;






	wire clksel0;
	wire clksel1;

	reg warmres_n;


	wire [ 7:0] d;
	wire [15:0] a;

	wire iorq_n;
	wire mreq_n;
	wire rd_n;
	wire wr_n;
	wire m1_n;
	wire int_n;
	wire nmi_n;
	wire busrq_n;
	wire busak_n;
	tri1 z80res_n;


	wire mema14;
	wire mema15;
	wire mema16;
	wire mema17;
	wire mema18;
	wire [3:0] ramcs_n;
	wire mema21;
	wire romcs_n;
	wire memoe_n;
	wire memwe_n;


	tri0 [7:0] zxid;
	tri0 [7:0] zxa;
	tri0 zxa14;
	tri0 zxa15;
	tri1 zxiorq_n;
	tri1 zxmreq_n;
	tri1 zxrd_n;
	tri1 zxwr_n;
	wire zxcsrom_n;
	wire zxblkiorq_n;
	wire zxblkrom_n;
	wire zxgenwait_n;
	wire zxbusin;
	wire zxbusena_n;


	wire dac_bitck;
	wire dac_lrck;
	wire dac_dat;


	wire sd_clk;
	wire sd_cs;
	wire sd_do;
	tri1 sd_di;
	tri1 sd_wp;
	tri1 sd_det;


	wire ma_clk;
	wire ma_cs;
	wire ma_do;
	tri1 ma_di;

	wire mp3_xreset;
	tri1 mp3_req;
	wire mp3_clk;
	wire mp3_dat;
	wire mp3_sync;

	wire led_diag;



	reg [7:0] sdmp3_chk [$]; // fifo for checking data from SD to MP3



	// clock gen
	initial
	begin
		clk_24mhz = 1'b1;
		forever #(`HALF_24MHZ) clk_24mhz = ~clk_24mhz;
	end
	//
	initial
	begin
		clk_fpga = 1'b1;
		forever #(`HALF_FPGA) clk_fpga = ~clk_fpga;
	end

	// reset gen
	initial
	begin
		warmres_n = 1'b0;

		#(1);
		repeat(2) @(posedge clk_fpga);

		warmres_n <= 1'b1;
	end


	// DUT
	top top
	(
		.clk_fpga(clk_fpga),
		.clk_24mhz(clk_24mhz),
		.clksel0(clksel0),
		.clksel1(clksel1),
		.warmres_n(warmres_n),
		.d(d),
		.a(a),
		.iorq_n(iorq_n),
		.mreq_n(mreq_n),
		.rd_n(rd_n),
		.wr_n(wr_n),
		.m1_n(m1_n),
		.int_n(int_n),
		.nmi_n(nmi_n),
		.busrq_n(busrq_n),
		.busak_n(busak_n),
		.z80res_n(z80res_n),
		.mema14(mema14),
		.mema15(mema15),
		.mema16(mema16),
		.mema17(mema17),
		.mema18(mema18),
		.ram0cs_n(ramcs_n[0]),
		.ram1cs_n(ramcs_n[1]),
		.ram2cs_n(ramcs_n[2]),
		.ram3cs_n(ramcs_n[3]),
		.mema21(mema21),
		.romcs_n(romcs_n),
		.memoe_n(memoe_n),
		.memwe_n(memwe_n),
		.zxid(zxid),
		.zxa(zxa),
		.zxa14(zxa14),
		.zxa15(zxa15),
		.zxiorq_n(zxiorq_n),
		.zxmreq_n(zxmreq_n),
		.zxrd_n(zxrd_n),
		.zxwr_n(zxwr_n),
		.zxcsrom_n(zxcsrom_n),
		.zxblkiorq_n(zxblkiorq_n),
		.zxblkrom_n(zxblkrom_n),
		.zxgenwait_n(zxgenwait_n),
		.zxbusin(zxbusin),
		.zxbusena_n(zxbusena_n),
		.dac_bitck(dac_bitck),
		.dac_lrck(dac_lrck),
		.dac_dat(dac_dat),
		.sd_clk(sd_clk),
		.sd_cs(sd_cs),
		.sd_do(sd_do),
		.sd_di(sd_di),
		.sd_wp(sd_wp),
		.sd_det(sd_det),
		.ma_clk(ma_clk),
		.ma_cs(ma_cs),
		.ma_do(ma_do),
		.ma_di(ma_di),
		.mp3_xreset(mp3_xreset),
		.mp3_req(mp3_req),
		.mp3_clk(mp3_clk),
		.mp3_dat(mp3_dat),
		.mp3_sync(mp3_sync),
		.led_diag(led_diag)
	);



	// SD and MP3 test modules
	mp3 mp3
	(
		.clk (mp3_clk ),
		.sync(mp3_sync),
		.data(mp3_dat ),
		.req (mp3_req )
	);
	//
	sd sd
	(
		.clk(sd_clk),
		.sdi(sd_do ),
		.sdo(sd_di )
	);


	// Z80
	z80 z80
	(
		.rst_n(z80res_n),
		.clk  (clk_fpga),

		.int_n  (int_n  ),
		.nmi_n  (nmi_n  ),
		.busrq_n(busrq_n),
		.wait_n (1'b1   ),
		
		.a(a),
		.d(d),

		.mreq_n(mreq_n),
		.iorq_n(iorq_n),
		.rd_n  (rd_n  ),
		.wr_n  (wr_n  ),

		.m1_n   (m1_n   ),
		.rfsh_n (       ),
		.busak_n(busak_n),
		.halt_n (       )
	);




	// RAM blocks
	wire [19:0] ram_a;
	genvar ram_i;
	//
	assign ram_a = { mema21, mema18, mema17, mema16, mema15, mema14, a[13:0] }; // 4mb
	//assign ram_a = { 1'b0, mema18, mema17, mema16, mema15, mema14, a[13:0] }; // 2mb
	//
	generate
	for(ram_i=0;ram_i<4;ram_i=ram_i+1)
	begin : ram_block
		ram ram
		(
			.a(ram_a),
			.d(d    ),

			.ce_n(ramcs_n[ram_i]),
			.oe_n(memoe_n       ),
			.we_n(memwe_n       )
		);
	end
	endgenerate

	
	// ROM block
	wire [18:0] rom_a;
	assign rom_a = { mema18, mema17, mema16, mema15, mema14, a[13:0] };
	rom
	#(
`ifdef TIMER_TEST
		.FILENAME("timer_test.bin")
`elsif PAGE_TEST
		.FILENAME("page_test.bin")
`elsif SDMP3_TEST
		.FILENAME("sdmp3_test.bin")
`endif
	)
	rom
	(
		.a(rom_a),
		.d(d    ),

		.ce_n(romcs_n),
		.oe_n(memoe_n)
	);




endmodule

