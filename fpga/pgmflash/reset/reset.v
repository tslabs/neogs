// part of NeoGS flash programmer project (c) 2014 lvd^NedoPC
//
// reset controller

module reset
(
	input  wire clk_fpga,
	input  wire clk_24mhz,

	input  wire init,
	output reg  init_in_progress,

	output wire zxbus_rst_n,
	output reg    rom_rst_n,
	output reg    z80_rst_n,

	output reg  z80_busrq_n,
	input  wire z80_busak_n
);

parameter RST_CNT_SIZE = 8;

	reg [RST_CNT_SIZE:0] poweron_rst_cnt;
	reg [RST_CNT_SIZE:0] rz_rst_cnt;

	wire poweron_rst_n = poweron_rst_cnt[RST_CNT_SIZE];

	wire rz_rst_n = rz_rst_cnt[RST_CNT_SIZE];

	reg z80_rst2;

	reg [1:0] z80_halted;


	// make overall reset from poweron
	//
	initial
		poweron_rst_cnt <= 'd0;
	//
	always @(posedge clk_24mhz)
	if( !poweron_rst_n )
		poweron_rst_cnt <= poweron_rst_cnt + 'd1;


	// make zxbus reset
	assign zxbus_rst_n = poweron_rst_n;


	// make rom/z80 reset
	//
	always @(posedge clk_24mhz, negedge poweron_rst_n)
	if( !poweron_rst_n )
		rz_rst_cnt <= 'd0;
	else if( init )
		rz_rst_cnt <= 'd0;
	else if( !rz_rst_n )
		rz_rst_cnt <= rz_rst_cnt + 'd1;

	// z80 reset
	always @(posedge clk_fpga, negedge rz_rst_n)
	if( !rz_rst_n )
	begin
		z80_rst_n <= 1'b0;
		z80_rst2  <= 1'b0;
	end
	else
	begin
		z80_rst_n <= z80_rst2;
		z80_rst2  <= 1'b1;
	end

	// z80 busrq/busak
	always @(posedge clk_fpga, negedge z80_rst_n)
	if( !z80_rst_n )
		z80_busrq_n <= 1'b1;
	else
		z80_busrq_n <= 1'b0;
	//
	always @(posedge clk_24mhz, negedge rz_rst_n)
	if( !rz_rst_n )
		z80_halted <= 2'b00;
	else
		z80_halted[1:0] <= {z80_halted[0], ~z80_busak_n};


	// rom reset, init_in_progress
	always @(posedge clk_24mhz, negedge rz_rst_n)
	if( !rz_rst_n )
	begin
		rom_rst_n        <= 1'b0;
		init_in_progress <= 1'b1;
	end
	else if( z80_halted[1] )
	begin
		rom_rst_n        <= 1'b1;
		init_in_progress <= 1'b0;
	end


endmodule

