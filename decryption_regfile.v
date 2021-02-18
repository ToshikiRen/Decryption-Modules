`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:13:49 11/23/2020 
// Design Name: 
// Module Name:    decryption_regfile 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////


`define selectAddr 0
`define caesarAddr 'h10
`define scytaleAddr 'h12
`define zigzagAddr 'h14

`define RESET 0
`define IDLE 10
`define READ 20
`define WRITE 30

module decryption_regfile #(
			parameter addr_witdth = 8,
			parameter reg_width 	 = 16
		)(
			// Clock and reset interface
			input clk, 
			input rst_n,
			
			// Register access interface
			input[addr_witdth - 1:0] addr,
			input read,
			input write,
			input [reg_width -1 : 0] wdata,
			output reg [reg_width -1 : 0] rdata,
			output reg done,
			output reg error,
			
			// Output wires
			output reg[reg_width - 1 : 0] select,
			output reg[reg_width - 1 : 0] caesar_key,
			output reg[reg_width - 1 : 0] scytale_key,
			output reg[reg_width - 1 : 0] zigzag_key
    );
	
	
	reg[reg_width - 1 : 0] wdata_reg;
	reg[addr_witdth - 1 : 0] addr_reg;
	reg[7 : 0] state = 0, nextState = 0;

	
	always @(posedge clk) begin	
		
		state <= nextState;
		wdata_reg = wdata;
		addr_reg = addr;
		
		
		if (~rst_n) begin
				state <= `RESET;
		end
		
	end
	
	
	always @(*) begin
		
			case(state) 
				
				`RESET: begin
					
					select = 0;
					caesar_key = 0;
					scytale_key = 'hFFFF;
					zigzag_key = 'h02;
					rdata = 0;
					done = 0;
					error = 0;
					nextState = `IDLE;
				
				end
				`IDLE: begin
				
						// Resetare flag-uri eroare si done
						done = 0;
						error = 0;
						
						// Selectare stari de citire/scriere
						if(read) begin
							nextState = `READ;
						end
						if(write) begin
							nextState = `WRITE;
						end
				
				end
				`READ: begin
						
						case(addr_reg)
							
							`selectAddr:
											rdata = select;
							`caesarAddr:
											rdata = caesar_key;
							`scytaleAddr:
											rdata = scytale_key;
							`zigzagAddr:
											rdata = zigzag_key;
							// Cazul adresei invalide
							default:
									error = 1;
							 
						endcase
						
						done = 1;
						nextState = `IDLE;
					
				end			
				
				`WRITE: begin
						
						case(addr_reg)
							
							`selectAddr:
											// Copiem doar ultimii 2 biti
											select[1:0] = wdata_reg[1:0];
							`caesarAddr:
											caesar_key = wdata_reg;
							`scytaleAddr:
											scytale_key = wdata_reg;
							`zigzagAddr:
											zigzag_key = wdata_reg;
											
							// Cazul adresei invalide
							default: 
									error = 1;
						endcase
						
						done = 1;
						nextState = `IDLE;
					
				end
				

			endcase
	end
	
endmodule
