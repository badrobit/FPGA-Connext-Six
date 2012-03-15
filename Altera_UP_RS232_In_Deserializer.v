/*****************************************************************************
 *                                                                           *
 * Module:       Altera_UP_RS232_In_Deserializer                             *
 * Description:                                                              *
 *      This module reads data to the RS232 UART Port.                       *
 *                                                                           *
 *****************************************************************************/

module Altera_UP_RS232_In_Deserializer (
	// Inputs
	clk,
	reset,
	
	serial_data_in,

	receive_data_en,

	// Bidirectionals

	// Outputs
	fifo_read_available,

	received_data
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/

parameter BAUD_COUNTER_WIDTH	= 9;
parameter BAUD_TICK_INCREMENT	= 9'd1;
parameter BAUD_TICK_COUNT		= 9'd433;
parameter HALF_BAUD_TICK_COUNT	= 9'd216;

parameter TOTAL_DATA_WIDTH		= 11;
parameter DATA_WIDTH			= 9;

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				clk;
input				reset;

input				serial_data_in;

input				receive_data_en;

// Bidirectionals

// Outputs
output	reg	[7:0]	fifo_read_available;

output		[(DATA_WIDTH - 1):0]	received_data;


/*****************************************************************************
 *                 Internal wires and registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire				shift_data_reg_en;
wire				all_bits_received;

wire				fifo_is_empty;
wire				fifo_is_full;
wire		[6:0]	fifo_used;

// Internal Registers
reg					receiving_data;

reg			[(TOTAL_DATA_WIDTH - 1):0]	data_in_shift_reg;

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
		fifo_read_available <= 8'h00;
	else
		fifo_read_available <= {fifo_is_full, fifo_used};
end

always @(posedge clk)
begin
	if (reset == 1'b1)
		receiving_data <= 1'b0;
	else if (all_bits_received == 1'b1)
		receiving_data <= 1'b0;
	else if (serial_data_in == 1'b0)
		receiving_data <= 1'b1;
end

always @(posedge clk)
begin
	if (reset == 1'b1)
		data_in_shift_reg	<= {TOTAL_DATA_WIDTH{1'b0}};
	else if (shift_data_reg_en)
		data_in_shift_reg	<= 
			{serial_data_in, data_in_shift_reg[(TOTAL_DATA_WIDTH - 1):1]};
end

/*****************************************************************************
 *                            Combinational logic                            *
 *****************************************************************************/


/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

Altera_UP_RS232_Counters RS232_In_Counters (
	// Inputs
	.clk						(clk),
	.reset						(reset),
	
	.reset_counters				(~receiving_data),

	// Bidirectionals

	// Outputs
	.baud_clock_rising_edge		(),
	.baud_clock_falling_edge	(shift_data_reg_en),
	.all_bits_transmitted		(all_bits_received)
);
defparam 
	RS232_In_Counters.BAUD_COUNTER_WIDTH	= BAUD_COUNTER_WIDTH,
	RS232_In_Counters.BAUD_TICK_INCREMENT	= BAUD_TICK_INCREMENT,
	RS232_In_Counters.BAUD_TICK_COUNT		= BAUD_TICK_COUNT,
	RS232_In_Counters.HALF_BAUD_TICK_COUNT	= HALF_BAUD_TICK_COUNT,
	RS232_In_Counters.TOTAL_DATA_WIDTH		= TOTAL_DATA_WIDTH;

Altera_UP_SYNC_FIFO RS232_In_FIFO (
	// Inputs
	.clk			(clk),
	.reset			(reset),

	.write_en		(all_bits_received & ~fifo_is_full),
	.write_data		(data_in_shift_reg[(DATA_WIDTH + 1):1]),

	.read_en		(receive_data_en & ~fifo_is_empty),
	
	// Bidirectionals

	// Outputs
	.fifo_is_empty	(fifo_is_empty),
	.fifo_is_full	(fifo_is_full),
	.words_used		(fifo_used),

	.read_data		(received_data)
);
defparam 
	RS232_In_FIFO.DATA_WIDTH	= DATA_WIDTH,
	RS232_In_FIFO.DATA_DEPTH	= 128,
	RS232_In_FIFO.ADDR_WIDTH	= 7;

endmodule

