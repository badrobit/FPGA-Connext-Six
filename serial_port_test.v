//`include "key_controller.v"
//`include "Altera_UP_Avalon_RS232.v"

/*
	Echo module: Example of how to use the DE2 serial port. Echos any bytes received back to the 
	sender. 
*/
module serial_port_test (
	input CLOCK_50, 
	input [3:0] KEY,
	input UART_RXD, 
	output UART_TXD	
);	
	wire [3:0] key_pressed, key_released; 
	key_controller(KEY[0], CLOCK_50, key_pressed[0], key_released[0]);
	
	wire reset; 
	assign reset = key_pressed[0];

	reg serial_reset; 
	reg serial_write, serial_read; 
	reg [31:0] serial_write_data; 
	wire [31:0] serial_read_data;
	
	// Bits 16 through 22 contain the number of bytes in the FIFO. 
	assign serial_read_available = serial_read_data[22:16] > 0; 
	
	Altera_UP_Avalon_RS232 (
		.clk(CLOCK_50),
		.reset(serial_reset),
		.address(1'b0),
		.chipselect(1'b1),
		.byteenable(3'b001),
		.read(serial_read),
		.write(serial_write),
		.writedata(serial_write_data),
		.UART_RXD(UART_RXD),
		.readdata(serial_read_data),
		.UART_TXD(UART_TXD)
	);
	
	// FSM 
	reg read_data; 
	reg write_data; 
	reg [2:0] wait_state; 
	always @ (posedge CLOCK_50)
	begin 	
		if (reset)
		begin 
			write_data <= 0; 
			read_data <= 0; 
			serial_reset <= 1; 
			wait_state <= 0; 
		end 
		else if (wait_state > 0)
		begin 
			wait_state <= wait_state - 1; 
		end 
		else 
		begin 
			serial_reset <= 0; 
			if (serial_read_available && !read_data && !write_data)
			begin 
				write_data <= 0; 
				read_data <= 1; 						
			end 
			else if (read_data)
			begin 
				write_data <= 1; 
				read_data <= 0; 
			end 
			else if (write_data)
			begin 
				write_data <= 0; 
				read_data <= 0; 
				// Wait a couple cycles before sending or receiving anything else to 
				// give the FIFO counts a chance to update. 
				wait_state <= 2; 
			end 
		end 
	end 
	
	// DATA PATH: Drives reading and writing to and from the serial port. 
	always @ (*)
	begin 
		if (read_data)
		begin 	
			serial_write_data = 32'b0; 
			serial_read  = 1; 
			serial_write = 0; 
		end
		else if (write_data)
		begin 
			// Send back the byte we received. 
			serial_write_data = {24'b0,serial_read_data[7:0]};
			serial_read  = 0; 
			serial_write = 1; 
		end 
		else 
		begin 
			serial_write_data = 32'b0; 
			serial_read  = 0; 
			serial_write = 0; 
		end 
	end 
endmodule
