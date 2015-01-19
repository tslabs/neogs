// part of NeoGS flash programmer project (c) 2014 lvd^NedoPC
//
// top-level module

module top(

	input  wire clk_fpga,  // clocks
	input  wire clk_24mhz, //

	output wire clksel0, // clock selection
	output wire clksel1, //

	input  wire warmres_n, // warm reset


	inout  wire [ 7:0] d, // Z80 data bus
	output wire [15:0] a, // Z80 address bus

	input  wire iorq_n,   // Z80 control signals
	input  wire mreq_n,   //
	input  wire rd_n,     //
	input  wire wr_n,     //
	input  wire m1_n,     //
	output wire int_n,    //
	output wire nmi_n,    //
	output wire busrq_n,  //
	input  wire busak_n,  //
	output wire z80res_n, //


	output wire mema14,   // memory control
	output wire mema15,   //
	output wire mema16,   //
	output wire mema17,   //
	output wire mema18,   //
	output wire ram0cs_n, //
	output wire ram1cs_n, //
	output wire ram2cs_n, //
	output wire ram3cs_n, //
	output wire mema21,   //
	output wire romcs_n,  //
	output wire memoe_n,  //
	output wire memwe_n,  //


	inout  wire [7:0] zxid,        // zxbus signals
	input  wire [7:0] zxa,         //
	input  wire       zxa14,       //
	input  wire       zxa15,       //
	input  wire       zxiorq_n,    //
	input  wire       zxmreq_n,    //
	input  wire       zxrd_n,      //
	input  wire       zxwr_n,      //
	input  wire       zxcsrom_n,   //
	output wire       zxblkiorq_n, //
	output wire       zxblkrom_n,  //
	output wire       zxgenwait_n, //
	output wire       zxbusin,     //
	output wire       zxbusena_n,  //


	output wire dac_bitck, // audio-DAC signals
	output wire dac_lrck,  //
	output wire dac_dat,  //


	output wire sd_clk, // SD card interface
	output wire sd_cs,  //
	output wire sd_do,  //
	input  wire sd_di,  //
	input  wire sd_wp,  //
	input  wire sd_det, //


	output wire ma_clk, // control interface of MP3 chip
	output wire ma_cs,
	output wire ma_do,
	input  wire ma_di,

	output wire mp3_xreset, // data interface of MP3 chip
	input  wire mp3_req,    //
	output wire mp3_clk,    //
	output wire mp3_dat,    //
	output wire mp3_sync,   //

	output wire led_diag // LED driver
);





	wire init, init_in_progress;
	
	wire zxbus_rst_n;
	wire rom_rst_n;

	wire       wr_addr;
	wire       wr_data;
	wire       rd_data;
	wire [7:0] wr_buffer;
	wire [7:0] rd_buffer;

	wire autoinc_ena;




	// assign unused pins to safe values
	assign clksel0 = 1'b1;
	assign clksel1 = 1'b1;

	assign int_n = 1'b1;
	assign nmi_n = 1'b1;

	assign ram0cs_n = 1'b1;
	assign ram1cs_n = 1'b1;
	assign ram2cs_n = 1'b1;
	assign ram3cs_n = 1'b1;
	
	assign mema21 = 1'b0;

	assign zxblkrom_n  = 1'b1;
	assign zxgenwait_n = 1'b1;

	assign dac_bitck = 1'b0;
	assign dac_lrck  = 1'b0;
	assign dac_dat   = 1'b0;

	assign sd_clk = 1'b0;
	assign sd_cs  = 1'b1;
	assign sd_do  = 1'b0;

	assign ma_clk = 1'b0;
	assign ma_cs  = 1'b1;
	assign ma_do  = 1'b0;

	assign mp3_xreset = 1'b0;
	assign mp3_clk    = 1'b0;
	assign mp3_sync   = 1'b0;


















	// reset controller
	reset reset
	(
		.clk_fpga (clk_fpga ),
		.clk_24mhz(clk_24mhz),

		.init            (init            ),
		.init_in_progress(init_in_progress),

		.zxbus_rst_n(zxbus_rst_n),
		.rom_rst_n  (rom_rst_n  ),
		.z80_rst_n  (z80res_n   ),

		.z80_busrq_n(busrq_n),
		.z80_busak_n(busak_n)
	);






	// zxbus controller
	zxbus zxbus
	(
		.clk  (clk_24mhz  ),
		.rst_n(zxbus_rst_n),

		.zxid       (zxid       ),
		.zxa        (zxa        ),
		.zxiorq_n   (zxiorq_n   ),
		.zxmreq_n   (zxmreq_n   ),
		.zxrd_n     (zxrd_n     ),
		.zxwr_n     (zxwr_n     ),
		.zxblkiorq_n(zxblkiorq_n),
		.zxbusin    (zxbusin    ),
		.zxbusena_n (zxbusena_n ),

		.init            (init            ),
		.init_in_progress(init_in_progress),

		.led(led_diag),

		.autoinc_ena(autoinc_ena),

		.wr_addr  (wr_addr  ),
		.wr_data  (wr_data  ),
		.rd_data  (rd_data  ),
		.wr_buffer(wr_buffer),
		.rd_buffer(rd_buffer)
	);




	// rom controller
	rom rom
	(
		.clk  (clk_24mhz),
		.rst_n(rom_rst_n),

		.wr_addr  (wr_addr  ),
		.wr_data  (wr_data  ),
		.rd_data  (rd_data  ),
		.wr_buffer(wr_buffer),
		.rd_buffer(rd_buffer),

		.autoinc_ena(autoinc_ena),

		.rom_a   ({mema18,mema17,mema16,mema15,mema14,a[13:0]}),
		.rom_d   (d),
		.rom_cs_n(romcs_n),
		.rom_oe_n(memoe_n),
		.rom_we_n(memwe_n)
	);

	assign a[15:14] = 2'bZZ;




endmodule

