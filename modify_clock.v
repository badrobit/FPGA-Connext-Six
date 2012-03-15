module modify_clock
(
	input 		original_clock,
	output reg	clock_1hz
);

reg [25:0] R; 

always @( posedge original_clock ) begin
	if( R < 2500000 ) begin
		R <= R + 1; 
	end
	else begin
		clock_1hz <= ~clock_1hz; 
		R <= 0; 
	end
end
endmodule 