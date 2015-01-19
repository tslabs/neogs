`timescale 1ns/100ps



module tb;



	reg clk;
	reg rst_n;



	wire [19:0] sram_addr;
	wire [ 7:0] sram_data;
	wire [ 3:0] sram_cs_n;
	wire sram_oe_n;
	wire sram_we_n;

	wire [15:0] shit;


	wire led;


	initial
	begin
		clk = 1'b1;

		forever #20.8 clk = ~clk;
	end


	initial
	begin
		rst_n = 1'b0;

		repeat(10) @(posedge clk) rst_n <= 1'b1;
	end







	main main(

		.clk_fpga(clk),
		.clk_24mhz(clk),

		.warmres_n(rst_n),

		.led_diag(led),

		.d(sram_data),
		.a( shit ),
		.mema14(sram_addr[14]),
		.mema15(sram_addr[15]),
		.mema16(sram_addr[16]),
		.mema17(sram_addr[17]),
		.mema18(sram_addr[18]),
		.mema21(sram_addr[19]),

		.memwe_n(sram_we_n),
		.memoe_n(sram_oe_n),

		.ram0cs_n(sram_cs_n[0]),
		.ram1cs_n(sram_cs_n[1]),
		.ram2cs_n(sram_cs_n[2]),
		.ram3cs_n(sram_cs_n[3]),


		.zxa('d0),
		.zxiorq_n(1'b1),
		.zxwr_n(1'b1)
	);

	assign sram_addr[13:0] = shit[13:0];




endmodule

