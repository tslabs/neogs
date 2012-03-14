// Part of NewGS project
//
// FPGA early and on-the-fly configuration, Z80 clock switch
//
// (c) 2008 NedoPC

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

	output warmres_n; reg warmres_n;

	input clkin;

	reg int_mema14,int_mema15;
	reg int_romcs_n,int_ramcs0_n;
	reg int_memoe_n,int_memwe_n;
	reg int_cs;


	reg [1:0] memcfg; // memcfg[1]: 1 ram, 0 roms
	                  // memcfg[0]: 0 page0, 1 page1 -> in 8000-ffff region

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

	// PORTS:
	// {a7,a6}
	// 00 - fpga ports
	// 01,WR - write memcfg: d7=RAM(1)/ROM(0), d0=32k page(0/1)
	// 01,RD - read cold_reset_n flag: d7=(0:was cold reset,1:no cold reset)
	// 10,WR - set cold_reset_n flag & write FPGA nCONFIG: d7=1: set cold_reset_n flag, d0: nCONFIG
	// 10,RD - read FPGA status: d7=nSTATUS, d0=CONF_DONE
	// 11,WR - write to FPGA
	// 11,RD - read from FPGA

	
	// clock selector	
	clocker clk( .clk1(clk24in),
	             .clk2(clk20in),
	             .clksel(clksel1),
	             .divsel(clksel0),
	             .clkout(clkout) );


	// disable control

	always @(negedge config_n,posedge init_done)
	begin
		if( config_n==0 ) // asynchronous reset
			disbl <= 0;
		else // posedge of init_done, synchronous set
			disbl <= 1;
	end




	// enabling memory control pins on request
	always @*
	begin
		if( disbl==0 )
		begin
			mema14   <= int_mema14;
			mema15   <= int_mema15;
			romcs_n  <= int_romcs_n;
			ramcs0_n <= int_ramcs0_n;
			memoe_n  <= int_memoe_n;
			memwe_n  <= int_memwe_n;
			cs       <= int_cs;
		end
		else // disbl==1
		begin
			mema14   <= 1'bZ;
			mema15   <= 1'bZ;
			romcs_n  <= 1'bZ;
			ramcs0_n <= 1'bZ;
			memoe_n  <= 1'bZ;
			memwe_n  <= 1'bZ;
			cs       <= 1'bZ;
		end
	end


	// controlling memory paging
	always @*
	begin
		casex( {a15,a14,memcfg[1]} )
		3'b00x:
			{int_mema15,int_mema14,int_romcs_n,int_ramcs0_n} <= 4'b0001;
		3'b01x:
			{int_mema15,int_mema14,int_romcs_n,int_ramcs0_n} <= 4'b0010;
		3'b1x0:
			{int_mema15,int_mema14,int_romcs_n,int_ramcs0_n} <= {memcfg[0],a14,2'b01};
		3'b1x1:
			{int_mema15,int_mema14,int_romcs_n,int_ramcs0_n} <= {memcfg[0],a14,2'b10};
		endcase
	end

	// controlling memory /OE, /WE
	always @*
	begin
		int_memoe_n <= mreq_n | rd_n;
		int_memwe_n <= mreq_n | wr_n;
	end


	// writing paging register [1:0] memcfg
	assign memcfg_write = iorq_n | wr_n | a7 | ~a6; // {a7,a6}==01

	always @(negedge coldres_n, posedge memcfg_write)
	begin
		if( coldres_n==0 ) // reset on coldres_n
			memcfg <= 2'b00;
		else // write on memcfg_write
			memcfg <= dbin;
	end


	// writing nCONFIG and cold reset "register"
	assign rescfg_write = iorq_n | wr_n | ~a7 | a6; // {a7,a6}==10

	always @(negedge coldres_n, posedge rescfg_write)
	begin
		if( coldres_n==0 ) // async reset
		begin
			was_cold_reset_n <= 0; // there was!
			config_n <= 0; // start FPGA config
		end
		else // sync set/load
		begin
			config_n <= dbin[0];
			was_cold_reset_n <= dbin[1] | was_cold_reset_n;
		end
	end


	// controlling positive CS pin to FPGA
	always @*
	begin
		int_cs <= a7 & a6; // {a7,a6}==11
	end



	// reading control
	assign coldrstf_read = iorq_n | rd_n | a7 | ~a6; // {a7,a6}=01
	assign fpgastat_read = iorq_n | rd_n | ~a7 | a6; // {a7,a6}=10

	always @*
	begin
		if( (coldrstf_read & fpgastat_read)==0 )
		begin
			d7 <= dbout[1];
			d0 <= dbout[0];
		end
		else
		begin
			d7 <= 1'bZ;
			d0 <= 1'bZ;
		end
	end

	always @*
	begin
		casex( {coldrstf_read,fpgastat_read} )
			2'b01:
				dbout <= { was_cold_reset_n, 1'bX };
			2'b10:
				dbout <= { status_n, conf_done };
			default:
				dbout <= 2'bXX;
		endcase
	end



	// warm resetter control

	always @(posedge clkin)
	begin
		disbl_sync[2:0]={disbl_sync[1:0],disbl};
	end

	always @(negedge coldres_n,posedge clkin)
	begin
		if( coldres_n==0 ) // async reset
		begin
			rstcount <= (-1);
			warmres_n <= 0;
		end
		else // posedge clkin
		begin
			if( disbl_sync[2]==0 && disbl_sync[1]==1 ) // positive pulse
			begin
				warmres_n <= 0;
				rstcount <= (-1);
			end
			else // no disbl_sync positive pulse
			begin
                rstcount <= rstcount - 1;
                if( |rstcount == 0 )
                	warmres_n <= 1'bZ;
			end
		end

	end



endmodule
