/*

reset...init...save.start_write.stop_write.restore.start_read(compare).stop_read.loop

error...



*/
module mem_tester(

	clk,

	rst_n,


	led, // LED flashing or not


// SRAM signals
	SRAM_DQ,   // sram inout databus

	SRAM_ADDR, // sram address bus

	SRAM_UB_N,
	SRAM_LB_N,
	SRAM_WE_N, //
	SRAM_CE_N, //
	SRAM_OE_N  //
);

parameter SRAM_DATA_SIZE = 8;
parameter SRAM_ADDR_SIZE = 19;

	inout [SRAM_DATA_SIZE-1:0] SRAM_DQ;
	wire  [SRAM_DATA_SIZE-1:0] SRAM_DQ;
	output [SRAM_ADDR_SIZE-1:0] SRAM_ADDR;
	wire   [SRAM_ADDR_SIZE-1:0] SRAM_ADDR;
	output SRAM_UB_N,SRAM_LB_N,SRAM_WE_N,SRAM_CE_N,SRAM_OE_N;
	wire   SRAM_UB_N,SRAM_LB_N,SRAM_WE_N,SRAM_CE_N,SRAM_OE_N;




	input clk;

	input rst_n;

	output led; reg led;


	reg inc_pass_ctr; // increment passes counter (0000-9999 BCD)
	reg inc_err_ctr;  // increment errors counter (10 red binary LEDs)


	reg check_in_progress; // when 1 - enables errors checking


	reg [19:0] ledflash;

	reg was_error;



	initial ledflash='d0;

	always @(posedge clk)
	begin
		if( inc_pass_ctr )
			ledflash <= 20'd0;
		else if( !ledflash[19] )
			ledflash <= ledflash + 20'd1;
	end

	always @(posedge clk)
	begin
		led <= ledflash[19] ^ was_error;
	end



	always @(posedge clk, negedge rst_n)
	begin
		if( !rst_n )
			was_error <= 1'b0;
		else if( inc_err_ctr )
			was_error <= 1'b1;
	end



	reg rnd_init,rnd_save,rnd_restore; // rnd_vec_gen control
	wire [SRAM_DATA_SIZE-1:0] rnd_out; // rnd_vec_gen output

	reg sram_start,sram_rnw;
	wire sram_stop,sram_ready;

	rnd_vec_gen my_rnd( .clk(clk), .init(rnd_init), .next(sram_ready), .save(rnd_save), .restore(rnd_restore), .out(rnd_out) );
	defparam my_rnd.OUT_SIZE = SRAM_DATA_SIZE;
	defparam my_rnd.LFSR_LENGTH = 41;
	defparam my_rnd.LFSR_FEEDBACK = 3;




	wire [SRAM_DATA_SIZE-1:0] sram_rdat;

	sram_control my_sram( .clk(clk), .clk2(clk), .start(sram_start), .rnw(sram_rnw), .stop(sram_stop), .ready(sram_ready),
	                      .rdat(sram_rdat), .wdat(rnd_out),
	                      .SRAM_DQ(SRAM_DQ), .SRAM_ADDR(SRAM_ADDR),
	                      .SRAM_CE_N(SRAM_CE_N), .SRAM_OE_N(SRAM_OE_N), .SRAM_WE_N(SRAM_WE_N) );
	defparam my_sram.SRAM_DATA_SIZE = SRAM_DATA_SIZE;
	defparam my_sram.SRAM_ADDR_SIZE = SRAM_ADDR_SIZE;







// FSM states and registers
	reg [3:0] curr_state,next_state;

parameter RESET        = 4'h0;

parameter INIT1        = 4'h1;
parameter INIT2        = 4'h2;

parameter BEGIN_WRITE1 = 4'h3;
parameter BEGIN_WRITE2 = 4'h4;
parameter BEGIN_WRITE3 = 4'h5;
parameter BEGIN_WRITE4 = 4'h6;

parameter WRITE        = 4'h7;

parameter BEGIN_READ1  = 4'h8;
parameter BEGIN_READ2  = 4'h9;
parameter BEGIN_READ3  = 4'hA;
parameter BEGIN_READ4  = 4'hB;

parameter READ         = 4'hC;

parameter END_READ     = 4'hD;

parameter INC_PASSES1  = 4'hE;
parameter INC_PASSES2  = 4'hF;


// FSM dispatcher

	always @*
	begin
		case( curr_state )

		RESET:
			next_state <= INIT1;

		INIT1:
			if( sram_stop )
				next_state <= INIT2;
			else
				next_state <= INIT1;

		INIT2:
			next_state <= BEGIN_WRITE1;

		BEGIN_WRITE1:
			next_state <= BEGIN_WRITE2;

		BEGIN_WRITE2:
			next_state <= BEGIN_WRITE3;

		BEGIN_WRITE3:
			next_state <= BEGIN_WRITE4;

		BEGIN_WRITE4:
			next_state <= WRITE;

		WRITE:
			if( sram_stop )
				next_state <= BEGIN_READ1;
			else
				next_state <= WRITE;

		BEGIN_READ1:
			next_state <= BEGIN_READ2;

		BEGIN_READ2:
			next_state <= BEGIN_READ3;

		BEGIN_READ3:
			next_state <= BEGIN_READ4;

		BEGIN_READ4:
			next_state <= READ;

		READ:
			if( sram_stop )
				next_state <= END_READ;
			else
				next_state <= READ;

		END_READ:
			next_state <= INC_PASSES1;

		INC_PASSES1:
			next_state <= INC_PASSES2;

		INC_PASSES2:
			next_state <= BEGIN_WRITE1;




		default:
			next_state <= RESET;


		endcase
	end


// FSM sequencer

	always @(posedge clk,negedge rst_n)
	begin
		if( !rst_n )
			curr_state <= RESET;
		else
			curr_state <= next_state;
	end


// FSM controller

	always @(posedge clk)
	begin
		case( curr_state )

//////////////////////////////////////////////////
		RESET:
		begin
			// various initializings begin

			inc_pass_ctr <= 1'b0;

			check_in_progress <= 1'b0;

			rnd_init <= 1'b1; //begin RND init

			rnd_save <= 1'b0;
			rnd_restore <= 1'b0;

			sram_start <= 1'b1;
			sram_rnw   <= 1'b1; // start condition for sram controller, in read mode
		end

		INIT1:
		begin
                  sram_start <= 1'b0; // end sram start
		end

		INIT2:
		begin
			rnd_init <= 1'b0; // end rnd init
		end



//////////////////////////////////////////////////
		BEGIN_WRITE1:
		begin
			rnd_save <= 1'b1;
			sram_rnw <= 1'b0;
		end

		BEGIN_WRITE2:
		begin
			rnd_save   <= 1'b0;
			sram_start <= 1'b1;
		end

		BEGIN_WRITE3:
		begin
			sram_start <= 1'b0;
		end

/*		BEGIN_WRITE4:
		begin
			rnd_save   <= 1'b0;
			sram_start <= 1'b1;
		end

		WRITE:
		begin
			sram_start <= 1'b0;
		end
*/



//////////////////////////////////////////////////
		BEGIN_READ1:
		begin
			rnd_restore <= 1'b1;
			sram_rnw <= 1'b1;
		end

		BEGIN_READ2:
		begin
                  rnd_restore <= 1'b0;
                  sram_start <= 1'b1;
		end

		BEGIN_READ3:
		begin
        		sram_start <= 1'b0;
				check_in_progress <= 1'b1;
		end

/*		BEGIN_READ4:
		begin
                  rnd_restore <= 1'b0;
                  sram_start <= 1'b1;
		end

		READ:
		begin
			sram_start <= 1'b0;
			check_in_progress <= 1'b1;
		end
*/
		END_READ:
		begin
			check_in_progress <= 1'b0;
		end

		INC_PASSES1:
		begin
			inc_pass_ctr <= 1'b1;
		end

		INC_PASSES2:
		begin
			inc_pass_ctr <= 1'b0;
		end




		endcase
	end



// errors counter

	always @(posedge clk)
		inc_err_ctr <= check_in_progress & sram_ready & ((sram_rdat==rnd_out)?0:1);



endmodule


