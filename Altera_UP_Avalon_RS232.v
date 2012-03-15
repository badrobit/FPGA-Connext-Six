/*****************************************************************************
 *                                                                           *
 * Module:       Altera_UP_Avalon_RS232                                      *
 * Description:                                                              *
 *      This module reads and writes data to the RS232 connector on Altera's *
 *   DE1 and DE2 Development and Education Boards.                           *
 *                                                                           *
 *****************************************************************************/

module Altera_UP_Avalon_RS232 (
	// Inputs
	clk,
	reset,
	
	address,
	chipselect,
	byteenable,
	read,
	write,
	writedata,

	UART_RXD,

	// Outputs
	irq,
	readdata,
	UART_TXD
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/

parameter BAUD_COUNTER_WIDTH	= 9;
parameter BAUD_TICK_INCREMENT	= 9'd1;
parameter BAUD_TICK_COUNT		= 9'd433;
parameter HALF_BAUD_TICK_COUNT	= 9'd216;

parameter TOTAL_DATA_WIDTH		= 11;
parameter DATA_WIDTH			= 8;
parameter ODD_PARITY			= 1'b1;

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				clk;
input				reset;

input				address;
input				chipselect;
input		[3:0]	byteenable;
input				read;
input				write;
input		[31:0]	writedata;

input				UART_RXD;

// Bidirectionals

// Outputs
output	reg			irq;
output	reg	[31:0]	readdata;

output				UART_TXD;

/*****************************************************************************
 *                 Internal wires and registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire				read_fifo_read_en;
wire		[7:0]	read_available;
wire		[(DATA_WIDTH - 1):0]	read_data;


wire				parity_error;

wire				write_data_parity;
wire		[7:0]	write_space;

// Internal Registers
reg					read_interrupt_en;
reg					write_interrupt_en;

reg					read_interrupt;
reg					write_interrupt;

reg					write_fifo_write_en;
reg			[(DATA_WIDTH - 1):0]	data_to_uart;

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
		irq <= 1'b0;
	else
		irq <= write_interrupt | read_interrupt;
end

always @(posedge clk)
begin
	if (reset == 1'b1)
		readdata <= 32'h00000000;
	else if (chipselect == 1'b1)
	begin
		if (address == 1'b0)
			readdata <= 
				{8'h00,
				 read_available,
				 6'h00,
				 parity_error,
				 1'b0,
				 read_data[(DATA_WIDTH - 1):0]};
		else
			readdata <= 
				{8'h00,
				 write_space,
				 6'h00,
				 write_interrupt,
				 read_interrupt,
				 6'h00,
				 write_interrupt_en,
				 read_interrupt_en};
	end
end


always @(posedge clk)
begin
	if (reset == 1'b1)
		read_interrupt_en <= 1'b0;
	else if ((chipselect == 1'b1) && (write == 1'b1) && (address == 1'b1) && (byteenable[0] == 1'b1))
		read_interrupt_en <= writedata[0];
end

always @(posedge clk)
begin
	if (reset == 1'b1)
		write_interrupt_en <= 1'b0;
	else if ((chipselect == 1'b1) && (write == 1'b1) && (address == 1'b1) && (byteenable[0] == 1'b1))
		write_interrupt_en <= writedata[1];
end

always @(posedge clk)
begin
	if (reset == 1'b1)
		read_interrupt <= 1'b0;
	else if (read_interrupt_en == 1'b0)
		read_interrupt <= 1'b0;
	else
		read_interrupt <= (&(read_available[6:5])  | read_available[7]);
end

always @(posedge clk)
begin
	if (reset == 1'b1)
		write_interrupt <= 1'b0;
	else if (write_interrupt_en == 1'b0)
		write_interrupt <= 1'b0;
	else
		write_interrupt <= (&(write_space[6:5])  | write_space[7]);
end


always @(posedge clk)
begin
	if (reset == 1'b1)
		write_fifo_write_en <= 1'b0;
	else
		write_fifo_write_en <= 
			chipselect & write & ~address & byteenable[0];
end

always @(posedge clk)
begin
	if (reset == 1'b1)
		data_to_uart <= 1'b0;
	else
		data_to_uart <= writedata[(DATA_WIDTH - 1):0];
end

/*****************************************************************************
 *                            Combinational logic                            *
 *****************************************************************************/

assign parity_error = 1'b0;
assign read_fifo_read_en = chipselect & read & ~address & byteenable[0];
assign write_data_parity = (^(data_to_uart)) ^ ODD_PARITY;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

Altera_UP_RS232_In_Deserializer RS232_In_Deserializer (
	// Inputs
	.clk						(clk),
	.reset					(reset),
	.serial_data_in		(UART_RXD),
	.receive_data_en		(read_fifo_read_en),

	// Bidirectionals

	// Outputs
	.fifo_read_available	(read_available),
	.received_data			(read_data)
);
defparam 
	RS232_In_Deserializer.BAUD_COUNTER_WIDTH	= BAUD_COUNTER_WIDTH,
	RS232_In_Deserializer.BAUD_TICK_INCREMENT	= BAUD_TICK_INCREMENT,
	RS232_In_Deserializer.BAUD_TICK_COUNT		= BAUD_TICK_COUNT,
	RS232_In_Deserializer.HALF_BAUD_TICK_COUNT	= HALF_BAUD_TICK_COUNT,
	RS232_In_Deserializer.TOTAL_DATA_WIDTH		= TOTAL_DATA_WIDTH,
	RS232_In_Deserializer.DATA_WIDTH			= DATA_WIDTH;

Altera_UP_RS232_Out_Serializer RS232_Out_Serializer (
	// Inputs
	.clk						(clk),
	.reset					(reset),
	.transmit_data			(data_to_uart),
	.transmit_data_en		(write_fifo_write_en),

	// Bidirectionals

	// Outputs
	.fifo_write_space		(write_space),
	.serial_data_out		(UART_TXD)
);
defparam 
	RS232_Out_Serializer.BAUD_COUNTER_WIDTH		= BAUD_COUNTER_WIDTH,
	RS232_Out_Serializer.BAUD_TICK_INCREMENT	= BAUD_TICK_INCREMENT,
	RS232_Out_Serializer.BAUD_TICK_COUNT		= BAUD_TICK_COUNT,
	RS232_Out_Serializer.HALF_BAUD_TICK_COUNT	= HALF_BAUD_TICK_COUNT,
	RS232_Out_Serializer.TOTAL_DATA_WIDTH		= TOTAL_DATA_WIDTH,
	RS232_Out_Serializer.DATA_WIDTH				= DATA_WIDTH;

endmodule
