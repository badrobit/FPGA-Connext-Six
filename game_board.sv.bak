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

initial begin
	integer x; 
	integer y; 
	
	for( x = 0; x < 19; x = x + 1 ) begin
		for( y = 0; y < 19; y = y + 1 ) begin
			game_board[x][y] = 6; 
		end
	end
end

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

// This is responsible for determining where we will play. 
// Default weighting of the board is 6. If it is greater
// than 9 we will play defensively. Less than 3 we play 
// offensively. starts with a win condition check. 
task play_move;
	reg [3:0] current_weight; 
	integer moves_left; 
	integer x; 
	integer y; 
	
	begin
		while( moves_left > 0 && moves_left <= 2 ) begin
			// look for WIN condition
			
			for( x = 0; x < 19; x = x + 1 ) begin
				for( y = 0; y < 19; y = y + 1 ) begin
					
				end
			end
			
			if( moves_left > 0 ) begin
				// look for defensive plays
				/*
					Need to add a control structure for restarting 
					the search in order to make sure we always get
					the proper move to play. 
				*/
				for( x = 0; x < 19; x = x + 1 ) begin
					for( y = 0; y < 19; y = y + 1 ) begin
						current_weight = game_board[x][y]; 
						if( current_weight == 11 ) begin
							modify_board( x, y, 1 ); 
							moves_left = moves_left -1; 
						end
						else if( current_weight == 10 ) begin
							modify_board( x, y, 1 ); 
							moves_left = moves_left -1; 
						end
						else begin
							// keep calm and carry on. 
						end
					end
				end
				
				if( moves_left > 0 ) begin
					// look for offsensive moves :) 
					/*
						Need to add a control structure like the one 
						talked about above.  
					*/
					for( x = 0; x < 19; x = x + 1 ) begin
						for( y = 0; y < 19; y = y + 1 ) begin
							current_weight = game_board[x][y]; 
							if( current_weight == 3 ) begin
								modify_board( x, y, 1 ); 
								moves_left = moves_left -1; 
							end
							else if( current_weight == 2 ) begin
								modify_board( x, y, 1 ); 
								moves_left = moves_left -1; 
							end
							else begin
								// keep calm and carray on.
							end
						end
					end
				end
			end
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