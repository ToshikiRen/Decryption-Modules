`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:53:30 11/26/2020 
// Design Name: 
// Module Name:    mux 
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

`define RESET 0
`define OUTPUT_DATA 2

module mux #(
		parameter D_WIDTH = 8
	)(
		// Clock and reset interface
		input clk,
		input rst_n,
		
		//Select interface
		input[1:0] select,
		
		// Output interface
		output reg[D_WIDTH - 1 : 0] data_o,
		output reg						 valid_o,
				
		//output interfaces
		input [D_WIDTH - 1 : 0] 	data0_i,
		input   							valid0_i,
		
		input [D_WIDTH - 1 : 0] 	data1_i,
		input   							valid1_i,
		
		input [D_WIDTH - 1 : 0] 	data2_i,
		input     						valid2_i
    );
	
		reg valid_i_sys;
		reg[7:0] state, next_state = 0;
		reg[D_WIDTH - 1 : 0] data_reg;
		
		
		always @(posedge clk) begin 
			
			// Reset + avansare tranzitie stare
			if(~rst_n)
				state <= `RESET;
			else
				state <= next_state;
			
			// Stocam in data_reg datele pe care le vrem la iesire
			data_reg <= valid0_i ? data0_i : (valid1_i ? data1_i : ( valid2_i ? data2_i : 0));
			valid_i_sys <= valid0_i | valid1_i | valid2_i;
			
		end
		
		always @(*) begin
		
			case(state)
			
				`RESET: begin
					
					data_o = 0;
					valid_o = 0;
					next_state = `OUTPUT_DATA;
					
				end
				
				`OUTPUT_DATA: begin
				
					if(valid_i_sys) begin
						data_o = data_reg;
						valid_o = valid_i_sys;
					end
					else begin
						data_o = 0;
						valid_o = 0;
					end
						
					next_state = `OUTPUT_DATA;
					
				end
			
			endcase
		
		end
		
	//TODO: Implement MUX logic here

endmodule
