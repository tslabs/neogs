// (c) NedoPC 2013
//
// ROM for NGS testbench

module rom
#(
	FILENAME = "no_such_file.rom"
)
(
	input  wire [18:0] a,
	output wire [ 7:0] d,

	input  wire ce_n,
	input  wire oe_n
);

	integer fd,i,len,tmp;


	reg [7:0] mem [0:524287];


	initial
	begin
		for(i=0;i<524288;i=i+1)
			mem[i] = 8'hFF;

		fd = $fopen(FILENAME,"rb");
		if( !fd )
		begin
			$display("rom: can't open file %s!",FILENAME);
			$stop;
		end

		tmp = $fseek(fd,0,2);
		len = $ftell(fd);
		tmp = $rewind(fd);

		if( len != $fread(mem,fd) )
		begin
			$display("rom: can't load file %s!",FILENAME);
			$stop;
		end

		$fclose(fd);
	end


	assign d = ( !ce_n && !oe_n ) ? mem[a] : 8'bZZZZ_ZZZZ;

endmodule

