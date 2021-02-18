`timescale 1ns / 1ps



`define RESET 0
`define WAIT_DATA 10
`define DECRYPT 20


module scytale_decryption#(
			parameter D_WIDTH = 8, 
			parameter KEY_WIDTH = 8, 
			parameter MAX_NOF_CHARS = 50,
			parameter START_DECRYPTION_TOKEN = 8'hFA
		)(
			// Clock and reset interface
			input clk,
			input rst_n,
			
			// Input interface
			input[D_WIDTH - 1:0] data_i,
			input valid_i,
			
			// Decryption Key
			input[KEY_WIDTH - 1 : 0] key_N,
			input[KEY_WIDTH - 1 : 0] key_M,
			
			// Output interface
			output reg[D_WIDTH - 1:0] data_o,
			output reg valid_o,
			
			output reg busy
    );

			reg[MAX_NOF_CHARS * D_WIDTH - 1: 0] regData;
			reg[D_WIDTH - 1 : 0] data_i_reg;
			reg[7 : 0] state, nextState, index, row_select, 
					   column_select, nextRow_select, nextColumn_select, nextIndex;
			
			reg valid_i_reg, next_valid_o;

			always @(posedge clk) begin
				
				data_i_reg <= data_i;
				valid_i_reg <= valid_i;
				valid_o <= next_valid_o;
				state <= nextState;
				
				
				
				column_select<= nextColumn_select;
				row_select<= nextRow_select;
				index <= nextIndex;
				
				if(~rst_n)
					state <= `RESET;
			
			end
			
			always @(*) begin
			
				case(state) 
					
					`RESET: begin
						
						next_valid_o = 0;
						data_o = 0;
						busy = 0;
						nextState = `WAIT_DATA;
						nextColumn_select = 0;
						nextRow_select = 0;
						nextIndex = 0;
					end
				
					`WAIT_DATA: begin
						busy = 0;
						// Stocare date ce vin pe intrare
						if(valid_i_reg && data_i_reg != START_DECRYPTION_TOKEN) begin
							regData[8*index +: 8] = data_i_reg;
							nextIndex = index + 1;
						end
						// Tratare sfarsit introducere date
						else if(data_i_reg == START_DECRYPTION_TOKEN) begin
							nextState = `DECRYPT;
							busy = 1;
							next_valid_o = 1;
						end
					end					
				
					`DECRYPT: begin
					
						// Selectare element de pus pe iesire
						data_o = regData[D_WIDTH * (key_N * column_select + row_select) +: D_WIDTH];
						
						// Avans pe coloana urmatoare
						nextColumn_select = column_select+ 1;
						
						if (nextColumn_select == key_M) begin
							// Trecem pe urmatoarea "linie"
							nextColumn_select = 0;
							nextRow_select = row_select+ 1;
							
						end
						
						nextIndex = index - 1;
						// Daca am terminat, revenim in starea de asteptare a datelor
						if (nextIndex == 0) begin
							nextState = `WAIT_DATA;
							nextColumn_select = 0;
							nextRow_select = 0;
							next_valid_o = 0;
						end
					end
					
				endcase
				
			end


endmodule