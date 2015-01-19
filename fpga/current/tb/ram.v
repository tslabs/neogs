// (c) NedoPC 2013
// SRAM model for ngs testbench

module ram
(
	input  wire [19:0] a,
	inout  wire [ 7:0] d,

	input  wire ce_n,
	input  wire oe_n,
	input  wire we_n
);

	reg [7:0] mem [0:1048575];


	initial
	begin : init_mem

		integer i;

		for(i=0;i<1048576;i=i+1)
			mem[i] = 8'd0;
	end


	// output data to bus
	assign d = (!ce_n && !oe_n && we_n) ? mem[a] : 8'bZZZZ_ZZZZ;

	// input data from bus
	always @*
	if( !ce_n && !we_n )
		mem[a] <= d;



endmodule

