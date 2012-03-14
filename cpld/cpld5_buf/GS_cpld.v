// Part of NeoGS project
//
// FPGA early and on-the-fly configuration, Z80 clock switch,
// 3.3v RAM buffer
//
// (c) 2008-2010 NedoPC

module GS_cpld(
	output reg         config_n,  // ACEX1K config pins
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
	output reg         warmres_n,


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




	reg int_mema14,int_mema15;
	reg int_romcs_n,int_ramcs_n;
	wire int_memoe_n,int_memwe_n;
	wire int_cs;

	wire ext_romcs_n,
	     ext_memoe_n,
	     ext_memwe_n;


	reg [1:0] memcfg; // memcfg[1]: 1 ram, 0 roms
	                  // memcfg[0]: 0 page0, 1 page1 -> in 8000-ffff region

	reg disbl; // =1 - cpld disabled, =0 - enabled

	reg was_cold_reset_n; // 1 - no cold reset, 0 - was cold reset


	reg  [1:0] dbout;
	wire [1:0] dbin;

	wire memcfg_write_n;
	wire rescfg_write_n;

	wire coldrstf_read_n;
	wire fpgastat_read_n;




	assign dbin[1] = d[7];
	assign dbin[0] = d[0];



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
	             .clkout(clkout)
	           );


	// disable control

	always @(negedge config_n,posedge init_done)
	begin
		if( !config_n ) // asynchronous reset
			disbl <= 0;
		else // posedge of init_done, synchronous set
			disbl <= 1;
	end



	// memory control pins when running without configured FPGA
	assign mema14  = disbl ? 1'bZ : int_mema14;
	assign mema15  = disbl ? 1'bZ : int_mema15;
	assign romcs_n = disbl ? 1'bZ : int_romcs_n;
	assign memoe_n = disbl ? 1'bZ : int_memoe_n;
	assign memwe_n = disbl ? 1'bZ : int_memwe_n;
	assign cs      = disbl ? 1'bZ : int_cs;

	assign ext_romcs_n = romcs_n;
	assign ext_memoe_n = memoe_n;
	assign ext_memwe_n = memwe_n;


	// controlling memory paging
	always @*
	begin
		casex( {a15,a14,memcfg[1]} )
		3'b00x:
			{int_mema15,int_mema14,int_romcs_n,int_ramcs_n} <= 4'b0001;
		3'b01x:
			{int_mema15,int_mema14,int_romcs_n,int_ramcs_n} <= 4'b0010;
		3'b1x0:
			{int_mema15,int_mema14,int_romcs_n,int_ramcs_n} <= {memcfg[0],a14,2'b01};
		3'b1x1:
			{int_mema15,int_mema14,int_romcs_n,int_ramcs_n} <= {memcfg[0],a14,2'b10};
		endcase
	end

	// controlling memory /OE, /WE
	assign int_memoe_n = mreq_n | rd_n;
	assign int_memwe_n = mreq_n | wr_n;


	// writing paging register [1:0] memcfg
	assign memcfg_write_n = iorq_n | wr_n | a7 | ~a6; // {a7,a6}==01

	always @(negedge coldres_n, posedge memcfg_write_n)
	begin
		if( !coldres_n ) // reset on coldres_n
			memcfg <= 2'b00;
		else // write on memcfg_write_n
			memcfg <= dbin;
	end


	// writing nCONFIG and cold reset "register"
	assign rescfg_write_n = iorq_n | wr_n | ~a7 | a6; // {a7,a6}==10

	always @(posedge rescfg_write_n, negedge coldres_n)
	begin
		if( !coldres_n ) // async reset
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
	assign int_cs = a7 & a6; // {a7,a6}==11



	// reading control
	assign coldrstf_read_n = iorq_n | rd_n | a7 | ~a6; // {a7,a6}=01
	assign fpgastat_read_n = iorq_n | rd_n | ~a7 | a6; // {a7,a6}=10



	always @*
	begin
		case( {coldrstf_read_n,fpgastat_read_n} )
			2'b01:
				dbout = { was_cold_reset_n, 1'bX };
			2'b10:
				dbout = { status_n, conf_done };
			default:
				dbout = 2'bXX;
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



	// Z80 data bus control

	assign d = ( (!coldrstf_read_n)||(!fpgastat_read_n) )   ?
	           { dbout[1], 6'bXXXXXX, dbout[0] }            :
	           ( (ext_romcs_n&&(!ext_memoe_n)) ? rd : 8'bZZZZZZZZ ) ;

	// memory data bus control

	assign rd = (ext_romcs_n&&(!ext_memwe_n)) ? d : 8'bZZZZZZZZ;

	// memory addresses buffering

	assign ra6  = a6;
	assign ra7  = a7;
	assign ra10 = a10;
	assign ra11 = a11;
	assign ra12 = a12;
	assign ra13 = a13;


	// memory CS'ing

	assign out_ramcs0_n = disbl ? ( in_ramcs0_n & in_ramcs1_n ) : int_ramcs_n;
	assign out_ramcs1_n = disbl ? ( in_ramcs2_n & in_ramcs3_n ) : 1'b1;

	assign mema19 = disbl ? ( in_ramcs0_n & in_ramcs2_n ) : 1'b0;



endmodule

