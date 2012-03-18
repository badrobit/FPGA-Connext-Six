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
// reg = X | XXXX
//       4   3210 
reg [4:0] game_board [0:18] [0:18];

task modify_board; 
	input [0:5] x; 
	input [0:5] y; 
	input 		player; 
	
	begin
		// 0 should be the weight you figure out :) 
		reg [0:3] temp = 0; 
		temp[0][4] = player; 
		game_board[x][y] = temp; 
	end
endtask


task play_move;
	// bunch o shit
	reg [2:0] moves_left; 
	
	begin
		while( moves_left > 0 && moves_left <= 2 ) begin
		// look for WIN condition
		// look for defensive plays
		// look for offsensive moves :) 
		
		//modify_board( x, y, 1 ); 
		end
	end
endtask


always @( compute_move ) begin

	
	if( !compute_move )begin			// PLACE OPPONENT MOVE
		modify_board( x_1, y_1, 0 ); 
		modify_board( x_2, y_2, 0 ); 
	end
	else if( compute_move ) begin		// COMPUTE OUR MOVE ... PLACE OUR MOVE
		play_move(); 
	end
	else begin									// SHIT GOT WEIRD 
	end
end

endmodule