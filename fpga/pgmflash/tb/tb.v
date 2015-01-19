// (c) NedoPC 2014
//
// top-level for testing pgmflash

`timescale 1ns/1ps

`define HALF_24MHZ (20.833)
`define HALF_FPGA  (50.000)

`define HALF_ZX (71.428)


module tb;

	reg clk_24mhz;
	reg clk_fpga;
	
	reg clk_zx;





	wire clksel0;
	wire clksel1;

	reg warmres_n;


	wire [ 7:0] d;
	wire [15:0] a;

	wire iorq_n;
	wire mreq_n;
	wire rd_n;
	wire wr_n;
	wire m1_n;
	wire int_n;
	wire nmi_n;
	wire busrq_n;
	reg  busak_n;
	tri1 z80res_n;


	wire mema14;
	wire mema15;
	wire mema16;
	wire mema17;
	wire mema18;
	wire [3:0] ramcs_n;
	wire mema21;
	wire romcs_n;
	wire memoe_n;
	wire memwe_n;


	tri1 [7:0] zxid;
	reg  [7:0] zxa;
	tri0 zxa14;
	tri0 zxa15;
	reg  zxiorq_n = 1'b1;
	reg  zxmreq_n = 1'b1;
	reg  zxrd_n   = 1'b1;
	reg  zxwr_n   = 1'b1;
	wire zxcsrom_n;
	wire zxblkiorq_n;
	wire zxblkrom_n;
	wire zxgenwait_n;
	wire zxbusin;
	wire zxbusena_n;


	wire dac_bitck;
	wire dac_lrck;
	wire dac_dat;


	wire sd_clk;
	wire sd_cs;
	wire sd_do;
	tri1 sd_di;
	tri1 sd_wp;
	tri1 sd_det;


	wire ma_clk;
	wire ma_cs;
	wire ma_do;
	tri1 ma_di;

	wire mp3_xreset;
	tri1 mp3_req;
	wire mp3_clk;
	wire mp3_dat;
	wire mp3_sync;

	wire led;

	int autoinc_ena = 0;

	
	tri1 [7:0] zxd;

	wire [7:0] zxin;
	reg  [7:0] zxout;
	reg        zxena;



	// rom read & write queues
	int wr_queue [$];
	int rd_addr_queue [$];
	int rd_reta_queue [$];
	int rd_retd_queue [$];

	int very_first_read = 1;

	int rom_addr  = 0;
	int rom_phase = 0;


	// zx databus
	assign zxin = zxd;
	assign zxd  = zxena ? zxout : 8'bZZZZ_ZZZZ;


	// 74*245 emulation
	assign zxd  = (!zxbusena_n && !zxbusin) ? zxid : 8'bZZZZ_ZZZZ;
	assign zxid = (!zxbusena_n &&  zxbusin) ? zxd  : 8'bZZZZ_ZZZZ;


	// busrq/busak logic emulation
	always @(posedge clk_fpga)
	if( !z80res_n )
		busak_n <= 1'b1;
	else if( !busrq_n )
		busak_n <= 1'b0;
	else
		busak_n <= 1'b1;




	// clock gen
	initial
	begin
		clk_24mhz = 1'b1;
		forever #(`HALF_24MHZ) clk_24mhz = ~clk_24mhz;
	end
	//
	initial
	begin
		clk_fpga = 1'b1;
		forever #(`HALF_FPGA) clk_fpga = ~clk_fpga;
	end
	//
	initial
	begin
		clk_zx = 1'b1;
		forever #(`HALF_ZX) clk_zx = ~clk_zx;
	end



	initial
	begin
		warmres_n = 1'b0;
		#(1);
		repeat(2) @(posedge clk_fpga);
		warmres_n <= 1'b1;
	end



	// DUT
	top top
	(
		.clk_fpga(clk_fpga),
		.clk_24mhz(clk_24mhz),
		.clksel0(clksel0),
		.clksel1(clksel1),
		.warmres_n(warmres_n),
		.d(d),
		.a(a),
		.iorq_n(iorq_n),
		.mreq_n(mreq_n),
		.rd_n(rd_n),
		.wr_n(wr_n),
		.m1_n(m1_n),
		.int_n(int_n),
		.nmi_n(nmi_n),
		.busrq_n(busrq_n),
		.busak_n(busak_n),
		.z80res_n(z80res_n),
		.mema14(mema14),
		.mema15(mema15),
		.mema16(mema16),
		.mema17(mema17),
		.mema18(mema18),
		.ram0cs_n(ramcs_n[0]),
		.ram1cs_n(ramcs_n[1]),
		.ram2cs_n(ramcs_n[2]),
		.ram3cs_n(ramcs_n[3]),
		.mema21(mema21),
		.romcs_n(romcs_n),
		.memoe_n(memoe_n),
		.memwe_n(memwe_n),
		.zxid(zxid),
		.zxa(zxa),
		.zxa14(zxa14),
		.zxa15(zxa15),
		.zxiorq_n(zxiorq_n),
		.zxmreq_n(zxmreq_n),
		.zxrd_n(zxrd_n),
		.zxwr_n(zxwr_n),
		.zxcsrom_n(zxcsrom_n),
		.zxblkiorq_n(zxblkiorq_n),
		.zxblkrom_n(zxblkrom_n),
		.zxgenwait_n(zxgenwait_n),
		.zxbusin(zxbusin),
		.zxbusena_n(zxbusena_n),
		.dac_bitck(dac_bitck),
		.dac_lrck(dac_lrck),
		.dac_dat(dac_dat),
		.sd_clk(sd_clk),
		.sd_cs(sd_cs),
		.sd_do(sd_do),
		.sd_di(sd_di),
		.sd_wp(sd_wp),
		.sd_det(sd_det),
		.ma_clk(ma_clk),
		.ma_cs(ma_cs),
		.ma_do(ma_do),
		.ma_di(ma_di),
		.mp3_xreset(mp3_xreset),
		.mp3_req(mp3_req),
		.mp3_clk(mp3_clk),
		.mp3_dat(mp3_dat),
		.mp3_sync(mp3_sync),
		.led_diag(led)
	);




	rom_emu rom_emu
	(
		.a   ({mema18,mema17,mema16,mema15,mema14,a[13:0]}),
		.d   (d),
		.ce_n(romcs_n),
		.oe_n(memoe_n),
		.we_n(memwe_n)
	);


	initial
	begin : test_sequence

		reg [7:0] tmp;
		int i;

		wait(warmres_n==1'b1);
		repeat(10) @(negedge clk_zx);


		// start polling for init_in_progress end.
		// first we poll floating bus (==ff), then init_in_progress==1, finally it sets to 0.
		init_wait();

		// make software init
		iowr(.addr(8'h33),.data(8'h80));

		// wait for end of init_in_progress again
		init_wait();

		// play with led
		led_test();

		// "presence check" check
		presence_check();

$display("rom access!");
		// check rom access
		rom_check();



		$display("TESTS PASSED!");
		$stop;
	end








	task init_wait;

		reg [7:0] tmp;
		int i;

		for(i=0;i<100;i=i+1)
		begin
			iord(.addr(8'h33),.data(tmp));
			if( !(tmp&8'h80) ) disable init_wait;
		end

		$display("init_wait() failed: too long waiting for init_in_progress going to 0!");
		$stop;
	endtask

	
	task led_test;
		
		// assume that led_test called after reset or init, so led initial state is known to be 0.

		int i;
		int led_state;



		if( led!==1'b0 )
		begin
			$display("led is not 0 at the start of led_test!");
			$stop;
		end

		// invert led several times and check
		led_state = 0;
		for(i=0;i<20;i=i+1)
		begin
			iowr(.addr(8'h33),.data(8'h40));
			
			led_state = led_state ^ 1;

			if( led!==led_state[0] )
			begin
				$display("led is not inverted properly after write of 0x40 to 0x33 in led_test!");
				$stop;
			end
		end
	endtask


	task presence_check;

		// assume we start after init, so test reg contains zeros. so check it first.

		reg [7:0] tmp;

		int i,treg,rnd;


		iord(.addr(8'h3B),.data(tmp));

		if( tmp!==8'd0 )
		begin
			$display("test reg at first read is not zero!");
			$stop;
		end


		treg = 0;

		for(i=0;i<256;i=i+1)
		begin
			rnd = $random>>24;

			iowr(.addr(8'h3B),.data(rnd[7:0]));
			
			iord(.addr(8'h3B),.data(tmp));

			treg[8:0] = { ~rnd[7:0], treg[8] };

			if( treg[7:0]!==tmp[7:0] )
			begin
				$display("test reg at read after write is wrong!");
				$stop;
			end
		end

	endtask


	task rom_check;

		int addr = 0;
		int wrdata;
		int rddata;
		reg [7:0] tmp;
		int rnd;

		int read_nwrite;
		int addr_init_num = (-1);
		int autoinc;
		int old_autoinc = 0;
		int access_num;

		int i;


		forever
		begin
			// get some random numbers and decide what to do

			read_nwrite = $random>>31;

			if( addr_init_num<0 )
				addr_init_num = 3;
			else
				addr_init_num = $random>>30;

			autoinc = $random>>31;

			access_num = 1 + ($random>>28); // 1..16


			// start doing that
			if( autoinc!=old_autoinc )
			begin
				iowr( .addr(8'h33), .data( autoinc ? 8'h20 : 8'h00 ) );
				old_autoinc = autoinc;
			end

			for(i=0;i<addr_init_num;i=i+1)
			begin
				rnd = $random>>24;

				addr[i*8 +: 8] = rnd[7:0];
				iowr( .addr(8'hB3), .data( rnd[7:0] ) );
			end
			
			if( read_nwrite )
			begin : read
				for(i=0;i<access_num;i=i+1)
					iord( .addr(8'hBB), .data(tmp) );
			end
			else 
			begin : write
				for(i=0;i<access_num;i=i+1)
					iowr( .addr(8'hBB), .data($random>>24) );
			end
		end

	endtask









	// IO cycles emulator
	task iord;

		input  [7:0] addr;

		output [7:0] data;

		begin
			if( addr==8'hBB )
			begin
				rom_phase = 0;

				rd_addr_queue.push_back(rom_addr);
			end
			
			@(posedge clk_zx);

			zxmreq_n <= 1'b1;
			zxiorq_n <= 1'b1;
			zxrd_n   <= 1'b1;
			zxwr_n   <= 1'b1;

			zxena <= 1'b0;

			zxa <= addr;

			@(negedge clk_zx);

			zxiorq_n <= 1'b0;
			zxrd_n   <= 1'b0;

			@(negedge clk_zx);
			@(negedge clk_zx);

			data = zxin;

			zxiorq_n <= 1'b1;
			zxrd_n   <= 1'b1;

			if( addr==8'hBB )
			begin : check_read_rom
				int taddr, tdata;

				taddr = rd_reta_queue.pop_front();

				if( taddr[18:0]!==rom_addr[18:0] )
				begin
					$display("iord: rom addr error!");
					$display("iord: addr from queue: %h",taddr[18:0]);
					$display("iord: addr from bus:   %h",rom_addr[18:0]);
					$stop;
				end

				
				if( !very_first_read )
				begin
					tdata = rd_retd_queue.pop_front();

					if( tdata[7:0]!==data[7:0] )
					begin
						$display("iord: rom data error!");
						$display("iord: data from queue: %h",tdata[7:0]);
						$display("iord: data from bus:   %h",data[7:0]);
						$stop;
					end
				end
				else
				begin
					very_first_read = 0;
				end
				
				if( autoinc_ena ) rom_addr++;
			end
		end

	endtask
	//
	task iowr;

		input [7:0] addr;
		input [7:0] data;

		begin

			if( addr==8'h33 )
			begin
				autoinc_ena = data[5];
			end

			if( addr==8'hB3 )
			begin
				rom_addr[rom_phase*8 +: 8] = data[7:0];
				rom_phase = (rom_phase>=2) ? 0 : (rom_phase+1);
			end
			
			if( addr==8'hBB || (addr==8'h33 && (data & 8'h80)) )
			begin
				rom_phase = 0;
			end

			if( addr==8'hBB )
			begin
				wr_queue.push_back((rom_addr<<8)|data[7:0]);
				if( autoinc_ena ) rom_addr++;
			end


			@(posedge clk_zx);

			zxmreq_n <= 1'b1;
			zxiorq_n <= 1'b1;
			zxrd_n   <= 1'b1;
			zxwr_n   <= 1'b1;

			zxena <= 1'b1;

			zxa   <= addr;
			zxout <= data;

			@(negedge clk_zx);

			zxiorq_n <= 1'b0;
			zxwr_n   <= 1'b0;

			@(negedge clk_zx);
			@(negedge clk_zx);

			zxiorq_n <= 1'b1;
			zxwr_n   <= 1'b1;

			wait(zxwr_n==1'b1); // delta-cycle delay!!!

			zxena <= 1'b0;

		end

	endtask









endmodule






module rom_emu
(
	input  wire [18:0] a,
	inout  wire [ 7:0] d,
	input  wire        ce_n,
	input  wire        oe_n,
	input  wire        we_n
);
	wire rd_stb = ~(ce_n|oe_n);
	wire wr_stb = ~(ce_n|we_n);

	reg old_wr_stb;

	wire [7:0] dwr;
	wire [7:0] drd;

	reg [7:0]  read_data;
	reg [7:0] write_data;

	assign d = rd_stb ? drd : 8'bZZZZ_ZZZZ;

	assign dwr = d;


	
	always @(posedge rd_stb)
	if( rd_stb==1'b1 )
	begin : test_read

		int taddr;

		read_data = $random>>24;

		tb.rd_reta_queue.push_back(a[18:0]);
		tb.rd_retd_queue.push_back(read_data);

		taddr = tb.rd_addr_queue.pop_front();

		if( taddr[18:0]!==a[18:0] )
		begin
			$display("rom_emu: read address error!");
			$display("rom_emu: addr from queue: %h",taddr[18:0]);
			$display("rom_emu: addr from bus:   %h",a[18:0]);
			$stop;
		end
	end
	//
	assign drd = read_data;


	always @(wr_stb)
	if( wr_stb==1'b0 && old_wr_stb==1'b1 )
	begin : test_write

		int taddr;
		int tdata;
		int tqueue;

		tqueue = tb.wr_queue.pop_front();

		taddr = tqueue>>8;
		tdata = tqueue&255;

		if( taddr[18:0]!==a[18:0] )
		begin
			$display("rom_emu: write address error!");
			$stop;
		end

		if( tdata[7:0]!==dwr[7:0] )
		begin
			$display("rom_emu: write data error!");
			$stop;
		end

		old_wr_stb = wr_stb;
	end




endmodule

