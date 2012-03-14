module GS_3032(

	config_n,	// ACEX1K config pins
	status_n,	//
	conf_done,	//
	cs,			//
	init_done,	//

	clk24in,	// 24mhz in
	clk20in,	// 20mhz in
	clkout,		// clock out
	clksel0,	// clock select 0 (1=divide by 2, 0=no divide)
	clksel1,	// clock select 1 (1=clk20in, 0=clk24in)

	a6,a7,a14,a15,	// z80 signals
	iorq_n,mreq_n,	//
	rd_n,wr_n,		//
	d7,d0,			//

	mema14,mema15,	// signals to memories
	romcs_n,ramcs0_n,
	memoe_n,memwe_n,

	coldres_n,		// cold reset input

	warmres_n,		// warm reset output

	clkin			// input of clkout signal
);

	output config_n; reg config_n;
	input status_n;
	input conf_done;
	output cs; reg cs;
	input init_done;

	input clk24in;
	input clk20in;
	output clkout; reg clkout;
	input clksel0,clksel1;

	input a6,a7,a14,a15;
	input iorq_n,mreq_n,rd_n,wr_n;
	inout d7,d0; reg d7,d0;

	output mema14,mema15; reg mema14,mema15;
	output romcs_n,ramcs0_n; reg romcs_n,ramcs0_n;
	output memoe_n,memwe_n; reg memoe_n,memwe_n;

	input coldres_n;

	input warmres_n;

	input clkin;

	reg int_mema14,int_mema15;
	reg int_romcs_n,int_ramcs0_n;
	reg int_memoe_n,int_memwe_n;
	reg int_cs;


	reg [1:0] memcfg; // memcfg[1]: 1 ram, 0 roms
	                  // memcfg[0]: 0 page0, 1 page1 -> in 8000-ffff region

	reg diver [0:10];

	reg disbl; // =1 - 3032 disabled, =0 - enabled

	reg was_cold_reset_n; // 1 - no cold reset, 0 - was cold reset


	reg [1:0] dbout;
	wire [1:0] dbin;

	assign dbin[1] = d7;
	assign dbin[0] = d0;


	wire memcfg_write;
	wire rescfg_write;

	wire coldrstf_read;
	wire fpgastat_read;


	reg [3:0] rstcount; // counter for warm reset period

	reg [2:0] disbl_sync;


	
	
	clocker myclk( .clk1(clk24in),
	               .clk2(clk20in),
	               .clksel(clksel1),
	               .divsel(clksel0),
	               .clkout(clkout) );





	always @*
	begin
		cs <= 1'b0;
		d0 <= 1'bZ;
		d7 <= 1'bZ;

		mema14 <= 1'bZ;
		mema15 <= 1'bZ;
		romcs_n <= 1'bZ;
		ramcs0_n <= 1'bZ;
		memoe_n <= 1'bZ;
		memwe_n <= 1'bZ;
	end


	always @(coldres_n, warmres_n)
	begin
		if( coldres_n==1'b0)
			config_n <= 1'b0;
		else if( warmres_n==1'b0 )
			config_n <= 1'b1;
	end



endmodule
