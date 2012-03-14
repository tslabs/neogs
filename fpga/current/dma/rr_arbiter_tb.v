`timescale 1ns/1ns

`define CLK_PERIOD 40

module tb;

	reg rst_n;
	reg clk;


	initial
	begin
		clk = 1'b0;

		forever
			#(`CLK_PERIOD/2) clk <= ~clk;
	end

	initial
	begin
		rst_n = 1'b0;

		repeat(3) @(posedge clk);

		rst_n <= 1'b1;
	end





	reg  [3:0] pre_reqs;
	reg  [3:0] reqs;
	reg  [3:0] prev;
	wire [3:0] next;
	reg  [3:0] ref_next;

	reg [3:0] was_prev,was_reqs,was_next;

	initial
	begin : test_rr_arbiter

		prev = 4'b0001;
		reqs = 4'b0001;

		repeat(1000000)
		begin
			@(posedge clk);
			//pre_reqs = 4'd0;
			//while( !pre_reqs )
				pre_reqs = $random>>28;

			reqs <= pre_reqs;

		end
		@(posedge clk);

		$stop ;
	end

	always @(posedge clk)
	begin
		prev <= next;
		was_prev <= prev;
		was_reqs <= reqs;
		was_next <= next;
		#1; // allow for nonblocking assignment to take place

		arbiter_predict(was_reqs,was_prev,ref_next);
		if( ref_next != was_next )
		begin
			$display("unequal! prev=%4b, reqs=%4b: reference_next=%4b, next=%4b\n",was_prev,was_reqs,ref_next,was_next);
		end
	end



	task arbiter_predict;
		input  [3:0] reqs;
		input  [3:0] prev;
		output [3:0] next;
		integer i,j,k;
		begin : disable_me
			if( !reqs )
			begin
				next = 4'd0;
			end
			else if( prev )
			begin
				i=0;
				while( !prev[i] )
					i=i+1;

				i=(i+1)&2'b11;
				while( !reqs[i] )
				begin
					i=(i+1)&2'b11;
				end

				next = 4'd1<<i;
			end
			else // !prev
			begin
				i=0;
				while( !reqs[i] )
					i=i+1;

				next = 4'd1<<i;
			end
		end
	endtask

	rr_arbiter arbiter( .reqs(reqs),
	                    .prev(prev),
	                    .next(next)
	                  );



endmodule
