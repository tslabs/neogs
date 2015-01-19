// (c) NedoPC 2013
//
// wrapper for T80.vhd
//
// fixes WR_N signal behavior, adds delays to outputs

`timescale 1ns/100ps

// as of z0840008
`define DLY_DN 34.0
`define DLY_UP 30.0

module z80
(
	input  wire rst_n,
	input  wire clk,

	input  wire int_n,
	input  wire nmi_n,
	input  wire busrq_n,
	input  wire wait_n,
	
	output wire [15:0] a,
	inout  wire [ 7:0] d,

	output wire mreq_n,
	output wire iorq_n,
	output wire rd_n,
	output reg  wr_n,

	output wire m1_n,
	output wire rfsh_n,
	output wire busak_n,
	output wire halt_n
);


	wire [15:0] #(`DLY_UP,`DLY_DN) za;
	wire [ 7:0] d_i;
	wire [ 7:0] #(`DLY_UP,`DLY_DN) d_o;

	wire #(`DLY_UP,`DLY_DN) zmreq_n;
	wire #(`DLY_UP,`DLY_DN) ziorq_n;
	wire #(`DLY_UP,`DLY_DN) zrd_n;

	wire iwr_n;
	wire im1_n;
	wire iiorq_n;
	wire ird_n;

	wire #(`DLY_UP,`DLY_DN) zm1_n;
	wire #(`DLY_UP,`DLY_DN) zrfsh_n;
	wire #(`DLY_UP,`DLY_DN) zbusak_n;
	wire #(`DLY_UP,`DLY_DN) zhalt_n;

	reg  mreq_wr_n;
	wire iorq_wr_n;
	wire full_wr_n;


/*	// attach T80 module
	T80a T80a
	(
		.RESET_n(rst_n),
		.CLK_n  (clk  ),

		.INT_n  (int_n  ),
		.NMI_n  (nmi_n  ),
		.BUSRQ_n(busrq_n),
		.WAIT_n (wait_n ),
		
		.A  (za ),
		.D_I(d_i),
		.D_O(d_o),
		
		.MREQ_n(zmreq_n),
		.IORQ_n(iiorq_n),
		.RD_n  (ird_n  ),
		.WR_n  (iwr_n  ),

		.M1_n   (im1_n   ),
		.RFSH_n (zrfsh_n ),
		.BUSAK_n(zbusak_n),
		.HALT_n (zhalt_n )
	);
*/

	// tv80 module
	tv80s tv80s
	(
		.reset_n(rst_n),
		.clk    (clk  ),
		
		.int_n  (int_n  ),
		.nmi_n  (nmi_n  ),
		.busrq_n(busrq_n),
		.wait_n (wait_n ),
		
		.A      (za ),
		.di     (d_i), 
		.dout   (d_o), 
		
		.mreq_n (zmreq_n),
		.iorq_n (iiorq_n),
		.rd_n   (ird_n  ),
		.wr_n   (iwr_n  ),
		
		.m1_n   (im1_n   ),
		.rfsh_n (zrfsh_n ),
		.busak_n(zbusak_n),
		.halt_n (zhalt_n )
	);



	assign ziorq_n = iiorq_n;
	assign zrd_n   = ird_n;
	assign zm1_n   = im1_n;


	assign a = busak_n ? za : 16'hZZZZ;

	assign mreq_n = zmreq_n;
	assign iorq_n = ziorq_n;
	assign rd_n   = zrd_n  ;

	assign m1_n    = zm1_n   ;
	assign rfsh_n  = zrfsh_n ;
	assign busak_n = zbusak_n;
	assign halt_n  = zhalt_n ;


	// fix broken wr_n of T80
	always @(negedge clk)
		mreq_wr_n <= iwr_n;
	//
	assign iorq_wr_n = iiorq_n | (~ird_n) | (~im1_n);
	assign full_wr_n = mreq_wr_n & iorq_wr_n;
	//
	always @(full_wr_n)
		if( !full_wr_n )
			#`DLY_DN wr_n <= full_wr_n;
		else
			#`DLY_UP wr_n <= full_wr_n;


	// data bus
	assign d_i =  d;
	assign d  = !wr_n ? d_o : 8'bZZZZ_ZZZZ;





endmodule

