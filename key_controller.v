/*
 * Processes the key into pressed and released events. When the key 
 * is pressed, a key_pressed event is issued. When the key is 
 * released, a key_released event is issued. When 
 * the key has been held for HOLD_INTERVAL clock cycles a 
 * pressed event is issued after every REPEAT_INTERVAL clock cycles. 
 * 
 * The relevant output is held high for one cycle after an event. 
 * 
 * Author: Andrew Somerville
 */
module key_controller(KEY, clock, key_pressed, key_released);
	parameter HOLD_INTERVAL   = 50000000;
	parameter REPEAT_INTERVAL =  1000000;

	input KEY, clock; 
	output key_pressed, key_released;

	// Always holds the previous value of the key. 
	reg key_prev;	
	// Clock ticks since the key was depressed. Limited to HOLD_INTERVAL. 
	reg[31:0] hold_timer; 
	// Clock ticks since the key was either depressed or last repeated. Limited to REPEAT_INTERVAL. 
	reg[31:0] repeat_timer;
	
	// The key has either just been pressed, or is being triggered to repeat. 
	assign key_pressed  = ((KEY ^ key_prev) & ~KEY) | key_repeat;
	// The key has just been released. 
	assign key_released = (KEY ^ key_prev) &  KEY; 
	// The key is currently being held down. 
	assign key_held   = hold_timer == HOLD_INTERVAL;
	// When the repeat timer hits the repeat interval, trigger a repeat. 
	assign key_repeat = repeat_timer == REPEAT_INTERVAL; 

	always @ (posedge clock)
	begin 		
		key_prev <= KEY; 
		
		if (KEY) 
			hold_timer <= 0; 
		else if (~KEY && hold_timer < HOLD_INTERVAL)
			hold_timer <= hold_timer + 1; 
		else 
			hold_timer <= hold_timer; 
		
		repeat_timer <= (key_held &&  repeat_timer < REPEAT_INTERVAL) ? repeat_timer + 1 : 0; 				
	end 
endmodule
