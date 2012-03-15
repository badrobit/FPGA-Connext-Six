/*****************************************************************************
 *                                                                           *
 * Module:       Altera_UP_RS232_Out_Serializer                              *
 * Description:                                                              *
 *      This module writes data to the RS232 UART Port.                      *
 *                                                                           *
 *****************************************************************************/

module Altera_UP_RS232_Out_Serializer (
	// Inputs
	clk,
	reset,
	
	transmit_data,
	transmit_data_en,

	// Bidirectionals

	// Outputs
	fifo_write_space,

	serial_data_out
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

input		[DATA_WIDTH:1]	transmit_data;
input				transmit_data_en;

// Bidirectionals

// Outputs
output	reg	[7:0]	fifo_write_space;

output	reg			serial_data_out;


/*****************************************************************************
 *                 Internal wires and registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire				shift_data_reg_en;
wire				all_bits_transmitted;

wire				read_fifo_en;

wire				fifo_is_empty;
wire				fifo_is_full;
wire		[6:0]	fifo_used;

wire		[DATA_WIDTH:1]	data_from_fifo;

// Internal Registers
reg					transmitting_data;

reg			[DATA_WIDTH:0]	data_out_shift_reg;

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
		fifo_write_space <= 8'h00;
	else
		fifo_write_space <= 8'h80 - {fifo_is_full, fifo_used};
end


always @(posedge clk)
begin
	if (reset == 1'b1)
		serial_data_out <= 1'b1;
	else
		serial_data_out <= data_out_shift_reg[0];
end

always @(posedge clk)
begin
	if (reset == 1'b1)
		transmitting_data <= 1'b0;
	else if (all_bits_transmitted == 1'b1)
		transmitting_data <= 1'b0;
	else if (fifo_is_empty == 1'b0)
		transmitting_data <= 1'b1;
end

always @(posedge clk)
begin
	if (reset == 1'b1)
		data_out_shift_reg	<= {(DATA_WIDTH + 1){1'b1}};
	else if (read_fifo_en)
		data_out_shift_reg	<= {data_from_fifo, 1'b0};
	else if (shift_data_reg_en)
		data_out_shift_reg	<= 
			{1'b1, data_out_shift_reg[DATA_WIDTH:1]};
end

/*****************************************************************************
 *                            Combinational logic                            *
 *****************************************************************************/

assign read_fifo_en = 
			~transmitting_data & ~fifo_is_empty & ~all_bits_transmitted;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

Altera_UP_RS232_Counters RS232_Out_Counters (
	// Inputs
	.clk						(clk),
	.reset						(reset),
	
	.reset_counters				(~transmitting_data),

	// Bidirectionals

	// Outputs
	.baud_clock_rising_edge		(shift_data_reg_en),
	.baud_clock_falling_edge	(),
	.all_bits_transmitted		(all_bits_transmitted)
);
defparam 
	RS232_Out_Counters.BAUD_COUNTER_WIDTH	= BAUD_COUNTER_WIDTH,
	RS232_Out_Counters.BAUD_TICK_INCREMENT	= BAUD_TICK_INCREMENT,
	RS232_Out_Counters.BAUD_TICK_COUNT		= BAUD_TICK_COUNT,
	RS232_Out_Counters.HALF_BAUD_TICK_COUNT	= HALF_BAUD_TICK_COUNT,
	RS232_Out_Counters.TOTAL_DATA_WIDTH		= TOTAL_DATA_WIDTH;

Altera_UP_SYNC_FIFO RS232_Out_FIFO (
	// Inputs
	.clk			(clk),
	.reset			(reset),

	.write_en		(transmit_data_en & ~fifo_is_full),
	.write_data		(transmit_data),

	.read_en		(read_fifo_en),
	
	// Bidirectionals

	// Outputs
	.fifo_is_empty	(fifo_is_empty),
	.fifo_is_full	(fifo_is_full),
	.words_used		(fifo_used),

	.read_data		(data_from_fifo)
);
defparam 
	RS232_Out_FIFO.DATA_WIDTH	= DATA_WIDTH,
	RS232_Out_FIFO.DATA_DEPTH	= 128,
	RS232_Out_FIFO.ADDR_WIDTH	= 7;

endmodule

