// clocker module for simulation

module clocker(

	input  wire clk1,
	input  wire clk2,

	input  wire clksel,
	input  wire divsel,

	output wire clkout
);

/*
как блять тут переключить клоки?
сначала clksel ресинхрим по выходному клоку, как пройдёт -
выходной клок выключили
потом по новому входному клоку уже проресинхренное прогоняем
еще раз ресинхря - и как прошло, включаем выход опять
*/
/*
* выше написана хуета!11
*/


	wire midck,ck;

	reg cksel,midsel;
	reg ckon;

	reg divby2,idiv;



	initial
	begin
		ckon = 1'b1;
		cksel = 1'b0;
		midsel = 1'b0;
	end



	assign midck = midsel ? clk2 : clk1;

	always
	begin
		@(negedge ck);

		if( cksel!=clksel )
		begin
			ckon   <= 1'b0;
			midsel <= clksel;

			repeat(2) @(negedge midck);

			ckon  <= 1'b1;
			cksel <= midsel;
		end
	end

	assign ck = ckon ? (cksel ? clk2 : clk1) : 1'b0;



	initial
	begin
		divby2 = 1'b0;
		idiv=1'b0;
	end

	always @(posedge ck)
		divby2 <= ~divby2;


	always @(posedge divby2)
		idiv <= divsel;


	assign clkout = idiv ? divby2 : ck;



endmodule

