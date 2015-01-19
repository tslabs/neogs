// Part of NeoGS project
//
// Z80 clock switch and nothing more. config_n=coldres_n.
//
// (c) 2008-2010 NedoPC

module GS_cpld(
	output wire        config_n,  // ACEX1K config pins
	input  wire        status_n,  //
	input  wire        conf_done, //
	output wire        cs,        //
	input  wire        init_done, //


	input  wire        clk24in, // 24mhz in
	input  wire        clk20in, // 20mhz in
	input  wire        clksel0, // clock select 0 (1=divide by 2, 0=no divide)
	input  wire        clksel1, // clock select 1 (1=clk20in, 0=clk24in)
	output wire        clkout,  // clock out

	input  wire        clkin, // input of clkout signal, buffered, same as for Z80


	input  wire        coldres_n, // resets
	output wire        warmres_n,


	input  wire        iorq_n, // Z80 control signals
	input  wire        mreq_n,
	input  wire        rd_n,
	input  wire        wr_n,

	inout  wire [ 7:0] d, // Z80 data bus

	input  wire        a6,  // some Z80 addresses
	input  wire        a7,
	input  wire        a10,
	input  wire        a11,
	input  wire        a12,
	input  wire        a13,
	input  wire        a14,
	input  wire        a15,


	output wire        mema14,
	output wire        mema15,
	output wire        mema19,

	inout  wire        romcs_n,
	inout  wire        memoe_n,
	inout  wire        memwe_n,

	input  wire        in_ramcs0_n,
	input  wire        in_ramcs1_n,
	input  wire        in_ramcs2_n,
	input  wire        in_ramcs3_n,

	output wire        out_ramcs0_n,
	output wire        out_ramcs1_n,


	output wire        ra6,  // some buffered memory addresses
	output wire        ra7,
	output wire        ra10,
	output wire        ra11,
	output wire        ra12,
	output wire        ra13,

	inout  wire [ 7:0] rd // memory data bus
);


	// clock selector
	clocker clk( .clk1(clk24in),
	             .clk2(clk20in),
	             .clksel(clksel1),
	             .divsel(clksel0),
	             .clkout(clkout)
	           );


	// memory control pins when running without configured FPGA
	assign mema14  = 1'bZ;
	assign mema15  = 1'bZ;
	assign mema19  = 1'bZ;

	assign romcs_n = 1'bZ;
	assign memoe_n = 1'bZ;
	assign memwe_n = 1'bZ;

	assign cs      = 1'b0;

	assign out_ramcs0_n = 1'b1;
	assign out_ramcs1_n = 1'b1;

	assign rd = 8'bZZZZ_ZZZZ;

	assign warmres_n = 1'bZ;

	assign d = 8'bZZZZ_ZZZZ;

	assign {ra6,ra7,ra10,ra11,ra12,ra13} = 6'd0;




	// reset FPGA at cold reset
	assign config_n = coldres_n;





endmodule

