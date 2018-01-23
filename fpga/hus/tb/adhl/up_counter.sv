
`timescale 1ns / 1ps		   

module up_counter
(
	output clk
);
//-------------Code Starts Here-------

reg reset;
reg enable;
reg clk = 0;
reg [7:0] out = 0;

initial
begin  
	#0 reset = 1;
	#8.5 reset = 0;
	enable = 1;
end

always
	#2 clk = ~clk;
	
always
begin
	#0.12 enable = 0;
	#3.39 enable = 1;
	#10	enable = 1;
end

always_ff @(posedge clk)
if (reset) begin
  out <= 8'b0 ;
end else if (enable) begin 
	$display(out);
  out ++;
end

endmodule 



















