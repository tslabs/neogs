// part of NeoGS flash programmer project (c) 2014 lvd^NedoPC
//
// rom controller
//
// !!!!!!!!!!!enables addr bus as soon as reset is removed!!!!!!!

module rom
(
	input  wire clk,
	input  wire rst_n,
	
	input  wire        wr_addr,
	input  wire        wr_data,
	input  wire        rd_data,
	input  wire [ 7:0] wr_buffer,
	output reg  [ 7:0] rd_buffer,

	input  wire        autoinc_ena,

	output wire [18:0] rom_a,
	inout  wire [ 7:0] rom_d,
	output reg         rom_cs_n,
	output reg         rom_oe_n,
	output reg         rom_we_n
);

	reg  [7:0] wrdata;
	wire [7:0] rddata;
	reg        enadata;

	reg [18:0] addr;
	reg [18:0] next_addr;
	reg        enaaddr;

	reg [2:0] addr_phase;

	reg       rnw;
	reg [6:0] rw_phase;


	// dbus control
	assign rom_d  = enadata ? wrdata : 8'bZZZZ_ZZZZ;
	assign rddata = rom_d;

	// abus control
	assign rom_a = enaaddr ? addr : {19{1'bZ}};



	// enaaddr control
	always @(posedge clk, negedge rst_n)
	if( !rst_n )
		enaaddr <= 1'b0;
	else
		enaaddr <= 1'b1;

	// address phase (points which one of 3byte address to write into)
	always @(posedge clk, negedge rst_n)
	if( !rst_n )
	begin
		addr_phase <= 3'b001;
	end
	else
	case( {wr_addr, wr_data, rd_data} )
		3'b100:        addr_phase <= {addr_phase[1:0], addr_phase[2] };
		3'b010,3'b001: addr_phase <= 3'b001;
		default:       addr_phase <= addr_phase;
	endcase

	// address control
	always @(posedge clk, negedge rst_n)
	if( !rst_n )
	begin
		next_addr <= 19'd0;
	end
	else
	case( {wr_addr, wr_data, rd_data} )
		3'b100: begin
			next_addr[ 7:0 ] <= addr_phase[0] ? wr_buffer[7:0] : next_addr[ 7:0 ];
			next_addr[15:8 ] <= addr_phase[1] ? wr_buffer[7:0] : next_addr[15:8 ];
			next_addr[18:16] <= addr_phase[2] ? wr_buffer[2:0] : next_addr[18:16];
		end
		3'b010, 3'b001: if( autoinc_ena ) next_addr <= next_addr + 19'd1;
		default:        next_addr <= next_addr;
	endcase

	// address output register
	always @(posedge clk)
	if( wr_data || rd_data )
		addr <= next_addr;


	// read/write sequence
	always @(posedge clk, negedge rst_n)
	if( !rst_n )
	begin
		rw_phase <= 'd0;
		rnw      <= 1'b1;
	end
	else if( rd_data || wr_data )
	begin
		rw_phase <= 'd1;
		rnw      <= rd_data;
	end
	else
	begin
		rw_phase <= rw_phase<<1;
	end

	// output control
	always @(posedge clk, negedge rst_n)
	if( !rst_n )
	begin
		enadata <= 1'b0;
	end
	else if( rw_phase[0] )
	begin
		enadata <= !rnw;
	end
	else if( rw_phase[6] )
	begin
		enadata <= 1'b0;
	end
	//
	always @(posedge clk, negedge rst_n)
	if( !rst_n )
	begin
		rom_cs_n <= 1'b1;
		rom_oe_n <= 1'b1;
		rom_we_n <= 1'b1;
	end
	else if( rw_phase[1] )
	begin
		rom_cs_n <= 1'b0;
		rom_oe_n <= !rnw;
		rom_we_n <=  rnw;
	end
	else if( rw_phase[6] )
	begin
		rom_cs_n <= 1'b1;
		rom_oe_n <= 1'b1;
		rom_we_n <= 1'b1;
	end
	//
	always @(posedge clk)
	if( wr_data )
		wrdata <= wr_buffer;



	// input control
	always @(posedge clk)
	if( rw_phase[6] && rnw )
		rd_buffer <= rddata;



endmodule


