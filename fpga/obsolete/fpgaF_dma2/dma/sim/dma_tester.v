// dma_data_consumer
// dma_data_supplier
// dma_access_controller
//
// задача. читать и писать разные области памяти, одновременно в 4 потока
// и сравнивать прочитанное с записанным. Читать бурстами 1-N1 байт с паузой 0-N2 тактов между каждыми
//
//



module dma_tester(

	input  wire        clk,

	input  wire        can_go,


	output reg         req,
	output reg         rnw,
	output reg   [7:0] wd,
	output reg  [20:0] addr,

	input  wire        ack,
	input  wire        done,
	input  wire  [7:0] rd
);
	parameter BEG_ADDR = 21'h00C000;
	parameter BLK_SIZE = 21'd004096;



	reg         first; // 1 when first cycle in sequence of either reads or writes


	reg rnw_done;   // to store rnw until reader gets it at done signal
	reg first_done; //



	// address/dir generation
	//
	always @(posedge clk, negedge can_go)
	begin
		if( !can_go )
		begin
			addr  = BEG_ADDR;
			rnw   = 1'b1;     // start with reading
			first = 1'b0;
		end
		else // posedge clk
		begin
			if( ack )
			begin
				if( addr >= (BEG_ADDR+BLK_SIZE-1) )
				begin
					addr  <= BEG_ADDR;
					rnw   <= ~rnw;
					first <= 1'b1;
				end
				else
				begin
					addr  <= addr + 21'd1;
					first <= 1'b0;
				end
			end
		end
	end





`define RND_PAUSE (8'd20 + ( 8'd63 & ($random>>20)))
`define RND_BURST (8'd1 + ( 8'd15 & ($random>>20)))
	// burst generator
	//
	reg [7:0] bcnt;
	//
	always @(posedge clk, negedge can_go)
	begin
		if( !can_go )
		begin
			bcnt = `RND_PAUSE;
			req  = 1'b0;
		end
		else // posedge clk
		begin

			if( !req ) // waiting
			begin
				if( bcnt!=0 )
				begin
					bcnt <= bcnt - 8'd1;
				end
				else // bcnt==0
				begin
					req  <= 1'b1;
					bcnt <= `RND_BURST;
				end
			end
			else // req - bursting
			begin
				if( ack )
				begin
					if( bcnt!=0 )
					begin
						bcnt <= bcnt - 8'd1;
					end
					else // bcnt==0
					begin
						req  <= 1'b0;
						bcnt <= `RND_PAUSE;
					end
				end
			end
		end
	end



	// rnd data supplying/checking
	//
	reg [7:0] chkmem [0:BLK_SIZE-1];
	integer wr_ptr,rd_ptr;
	integer rnd;
	reg idle;
	//
	initial
	begin
		idle=1'b1;
		wr_ptr = 0;
		rd_ptr = 0;
	end
	//
	always @(posedge clk, negedge can_go)
	begin
		if( !can_go )
		begin
			rnw_done   = 1'b1;
			first_done = 1'b0;
		end
		else // posedge clk
		begin
			if( ack )
			begin
				rnw_done   <= rnw;
				first_done <= first;
			end
		end
	end
	//
	// idle control
	always @(posedge first)
	begin
		if( idle )
		begin
			idle <= 1'b0;
		end
	end
	// reading
	always @(posedge clk)
	begin
		if( !idle )
		begin
			if( rnw_done ) // read
			begin
				if( done )
				begin
					if( first_done ) 
					begin
						rd_ptr = 0;
						//$display("reader done!\n");
					end

					if( chkmem[rd_ptr]!=rd )
					begin
						$display("readback error: at address %x must be %x, was %x\n",rd_ptr,chkmem[rd_ptr],rd);
						$stop;
					end

					rd_ptr=rd_ptr+1;
				end
			end
		end
	end
	//
	// writing
	always @(posedge clk)
	begin
		if( idle )
			wd <= $random>>24;
		else // !idle
			if( !rnw && ack )
				wd <= $random>>24;
	end
	//	
	always @(posedge clk)
	begin
		if( !idle )
		begin
			if( !rnw ) // write
			begin
				if( ack )
				begin
					chkmem[wr_ptr] <= wd;
					
					if( first )
						wr_ptr <= 1;
					else if( wr_ptr<(BLK_SIZE-1) )
						wr_ptr <= wr_ptr+1;
					else
						wr_ptr <= 0;
				end
			end
		end
	end



endmodule








