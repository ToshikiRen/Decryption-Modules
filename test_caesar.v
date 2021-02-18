`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:15:45 11/30/2020
// Design Name:   ceasar_decryption
// Module Name:   G:/334AB/Semestrul I/AC/Tema2/decryption_skel/test_caesar.v
// Project Name:  decryption_skel
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ceasar_decryption
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_caesar;

	// Inputs
	reg clk;
	reg rst_n;
	reg [7:0] data_i;
	reg valid_i;
	reg [15:0] key;

	// Outputs
	wire [7:0] data_o;
	wire valid_o;
	wire busy;

	// Instantiate the Unit Under Test (UUT)
	ceasar_decryption uut (
		.clk(clk), 
		.rst_n(rst_n), 
		.data_i(data_i), 
		.valid_i(valid_i), 
		.key(key), 
		.busy(busy),
		.data_o(data_o), 
		.valid_o(valid_o)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst_n = 0;
		data_i = 0;
		valid_i = 0;
		key = 0;
		repeat(5)
			@(posedge clk);
      rst_n = 1;
		// Wait 100 ns for global reset to finish
		repeat(5)
			@(posedge clk);
      
		
		@(posedge clk);
			data_i = 1;
			valid_i = 1;
		
		@(posedge clk);
			data_i = 2;
			valid_i = 1;
			
		@(posedge clk);
			valid_i = 0;
			data_i = 2;
			
		@(posedge clk);
			valid_i = 1;
			data_i = 20;
			
		// Add stimulus here


	end
      always #10 clk = ~clk;
endmodule

