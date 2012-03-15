/*****************************************************************************
 *                                                                           *
 * Module:       Altera_UP_RS232_Counters                                    *
 * Description:                                                              *
 *      This module reads and writes data to the RS232 connectpr on Altera's *
 *   DE1 and DE2 Development and Education Boards.                           *
 *                                                                           *
 *****************************************************************************/

module Altera_UP_RS232_Counters (
	// Inputs
	clk,
	reset,
	
	reset_counters,

	// Bidirectionals

	// Outputs
	baud_clock_rising_edge,
	baud_clock_falling_edge,
	all_bits_transmitted
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/

parameter BAUD_COUNTER_WIDTH	= 9;
parameter BAUD_TICK_INCREMENT	= 9'd1;
parameter BAUD_TICK_COUNT		= 9'd433;
parameter HALF_BAUD_TICK_COUNT	= 9'd216;

parameter TOTAL_DATA_WIDTH		= 11;

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				clk;
input				reset;

input				reset_counters;

// Bidirectionals

// Outputs
output	reg			baud_clock_rising_edge;
output	reg			baud_clock_falling_edge;
output	reg			all_bits_transmitted;

/*****************************************************************************
 *                 Internal wires and registers Declarations                 *
 *****************************************************************************/

// Internal Wires

// Internal Registers
reg			[(BAUD_COUNTER_WIDTH - 1):0]	baud_counter;
reg			[3:0]	bit_counter;

// State Machine Registers


/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential logic                              *
 *****************************************************************************/

always @(posedge clk)
begin
	if (reset == 1'b1)
		baud_counter <= {BAUD_COUNTER_WIDTH{1'b0}};
	else if (reset_counters)
		baud_counter <= {BAUD_COUNTER_WIDTH{1'b0}};
	else if (baud_counter == BAUD_TICK_COUNT)
		baud_counter <= {BAUD_COUNTER_WIDTH{1'b0}};
	else
		baud_counter <= baud_counter + BAUD_TICK_INCREMENT;
end

always @(posedge clk)
begin
	if (reset == 1'b1)
		baud_clock_rising_edge <= 1'b0;
	else if (baud_counter == BAUD_TICK_COUNT)
		baud_clock_rising_edge <= 1'b1;
	else
		baud_clock_rising_edge <= 1'b0;
end

always @(posedge clk)
begin
	if (reset == 1'b1)
		baud_clock_falling_edge <= 1'b0;
	else if (baud_counter == HALF_BAUD_TICK_COUNT)
		baud_clock_falling_edge <= 1'b1;
	else
		baud_clock_falling_edge <= 1'b0;
end

always @(posedge clk)
begin
	if (reset == 1'b1)
		bit_counter <= 4'h0;
	else if (reset_counters)
		bit_counter <= 4'h0;
	else if (bit_counter == TOTAL_DATA_WIDTH)
		bit_counter <= 4'h0;
	else if (baud_counter == BAUD_TICK_COUNT)
		bit_counter <= bit_counter + 4'h1;
end

always @(posedge clk)
begin
	if (reset == 1'b1)
		all_bits_transmitted <= 1'b0;
	else if (bit_counter == TOTAL_DATA_WIDTH)
		all_bits_transmitted <= 1'b1;
	else
		all_bits_transmitted <= 1'b0;
end

/*****************************************************************************
 *                            Combinational logic                            *
 *****************************************************************************/


/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/


endmodule

