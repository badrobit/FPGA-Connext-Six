module game_board
(
	input [0:5] x_1,
	input [0:5] y_1, 
	input [0:5] x_2,
	input [0:5] y_2,
	input 		compute_move,
	
	output [0:5]	x_out,
	output [0:5] 	y_out 
);

// 19x19 array of 4 bit registers. 
// reg = X | XXX
//       3   210 
reg [3:0] game_board [0:18] [0:18];

reg [0:2] moves_left; 

task place_move; 
	input [0:5] x; 
	input [0:5] y; 
	input [0:4] board_value;
	input 		player; 
	
	begin
		reg [0:3] temp = board_value; 
		temp[0][3] = player; 
		game_board[x][y] = temp; 
	end
endtask


task defensive_move; 
	begin
		//while( playing ) begin 
		
		// break condition ... don't need to defend ... 
		
		//end 

	end
endtask 


task offensive_move;
	input [3:0]	moves_left; 

	reg [0:5] x_move; 
	reg [0:5] y_move; 
		
	begin
		
		while( moves_left > 0 ) begin
		
			place_move( x_move, y_move, 0, 1 ); 
		end
	end
endtask


always @( compute_move ) begin

	
	if( !compute_move )begin			// PLACE OPPONENT MOVE
		place_move( x_1, y_1, 0, 0 ); 
		place_move( x_2, y_2, 0, 0 ); 
	end
	else if( compute_move ) begin		// COMPUTE OUR MOVE ... PLACE OUR MOVE
		defensive_move(); 
	end
	else begin									// SHIT GOT WEIRD 
	end
end

endmodule