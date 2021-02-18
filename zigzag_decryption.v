`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:33:04 11/23/2020 
// Design Name: 
// Module Name:    zigzag_decryption 
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
`define WAIT_DATA 10
`define DECRYPT 20


module zigzag_decryption #(
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
			input[KEY_WIDTH - 1 : 0] key,
			
			// Output interface
			output reg busy,
			output reg[D_WIDTH - 1:0] data_o,
			output reg valid_o
    );

			
			reg[7 : 0] divide_at = 1;
			wire[7 : 0] no_cycle, rest_of;
			reg[MAX_NOF_CHARS * D_WIDTH - 1: 0] regData;
			reg[7 : 0]  index, i, j, indexCopy, nextIndex, nextJ, nextI;
			
			reg[7:0] R, Q, l1, l2, l3, l4;
			reg[7 : 0] state, nextState;
			// Linia din decodificarea curenta
			reg[2:0] line = 0, next_line;
			reg valid_i_reg, next_valid_o;
			reg[D_WIDTH - 1 : 0] data_i_reg;
			
			division #(8) divider(
					.N(index),
					.D(divide_at),
					.Q(no_cycle),
					.R(rest_of));
			
			always @(posedge clk) begin
				
				data_i_reg <= data_i;
				valid_i_reg <= valid_i;
				state <= nextState;
				valid_o <= next_valid_o;
				line <= next_line;
				
				i <= nextI;
				j <= nextJ;
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
						nextJ = 0;
						nextI = 0;
						nextIndex = 0;
						next_line = 0;
						
					end
					
					`WAIT_DATA: begin
						
						busy = 0;
						data_o = 0;
						// Stocare date ce vin pe intrare
						if(valid_i_reg && data_i_reg != START_DECRYPTION_TOKEN) begin
							regData[8*index +: 8] = data_i_reg;
							nextIndex = index + 1;
						end
						// Tratare sfarsit introducere date
						else if(data_i_reg == START_DECRYPTION_TOKEN && valid_i_reg) begin
							nextState = `DECRYPT;
							busy = 1;
							next_valid_o = 1;
							case(key)
							
								2: begin
									// Calcul elemente de pe prima linie 
									R = {7'b0,index[0]};
									Q = {1'b0, index[7:1]} + R;

								end
								3: begin
									
									// Calcul caractere de pe prima linie
									R = {6'b0, index[1], index[0]};
									l1 = {2'b0, index[7:2]} + (R && 1);
									
									// Calculare nr de caractere de pe ultima linie
									indexCopy = index - 2;
									R = {6'b0, indexCopy[1], indexCopy[0]};
									l3 = {2'b0, indexCopy[7:2]}  + (R && 1);

									
									// Calculare nr de caractere de pe linia 2
									l2 = index - l1 - l3;
									
								end
								4: begin
									divide_at = 6;
									l1 = no_cycle + (rest_of ? 1 : 0);
									l2 = (no_cycle << 1) + (rest_of > 1 ? 1 : 0) ;
									l3 = (no_cycle << 1) + (rest_of > 2 ? 1 : 0) + (rest_of > 4 ? 1 : 0);
								end
								
								5: begin
									divide_at = 8;
									l1 = no_cycle + (rest_of ? 1 : 0);
									l2 = (no_cycle << 1) + (rest_of > 1 ? 1 : 0);
									l3 = (no_cycle << 1) + (rest_of > 2 ? 1 : 0) + (rest_of > 6 ? 1 : 0);
									l4 = (no_cycle << 1) + (rest_of > 3 ? 1 : 0) + (rest_of > 5 ? 1 : 0);
								end
								default: begin
									R = {7'b0,index[0]};
									Q = {1'b0, index[7:1]};
								end
								
							endcase
						end	
						
					end					
				
					`DECRYPT: begin
					
					
						// Tratare cazuri in functie de cheia de decriptare
						case(key)
						
							2: begin
								
								// Selectare element de pus pe iesire
								data_o = regData[D_WIDTH * (line * Q + i) +: D_WIDTH];
								// Trecere din 1 -> 0 si din 0 -> 1 
								next_line = {2'b0, line[0] ^ 1};
							
								nextIndex = index - 1;
								// Trecere pe o noua linie
								if(next_line == 0)
									nextI = i + 1;
							end
							3: begin
								
								// Tratam fiecare linie separat
								case(line)
									
									0: begin
										data_o = regData[D_WIDTH * i +: D_WIDTH];
										next_line = 1;
									end
									
									1: begin
										
										data_o = regData[D_WIDTH * (j + l1) +: D_WIDTH];
										// Urcare/Coborare in "matrice"
										if(j[0])
										
											next_line = 0;
										else
											next_line = 2;
											
										nextJ = j + 1;
									end
									
									2: begin
										data_o = regData[D_WIDTH * (i + l1 + l2) +: D_WIDTH];
										next_line = 1;
										nextI = i + 1;
									end
								
								endcase
								
								nextIndex = index - 1;
							end
							4: begin
								
								case(line)
								
									0: begin 
										data_o = regData[D_WIDTH * i +: D_WIDTH];
										next_line = 1;
									end
									
									1: begin
										data_o = regData[D_WIDTH * (j + l1) +: D_WIDTH];
										if(j[0]) begin
											next_line = 0;
											nextJ = j + 1;
										end
										else
											next_line = 2;
										
										
									end
									
									2: begin
									
										data_o = regData[D_WIDTH * (j + l1 + l2) +: D_WIDTH];
										if(j[0])
											next_line = 1;
										else begin
											next_line = 3;
											nextJ = j + 1;
										end	
										
									end
									
									3: begin
										
										data_o = regData[D_WIDTH * (i + l1 + l2 + l3) +: D_WIDTH];
										next_line = 2;
										nextI = i + 1;
									
									end	
									
								endcase
								nextIndex = index - 1;

							end
							
							5: begin
								
								case(line)
								
									0: begin 
										data_o = regData[D_WIDTH * i +: D_WIDTH];
										next_line = 1;
									end
									
									1: begin
										data_o = regData[D_WIDTH * (j + l1) +: D_WIDTH];
										
										if(j[0]) begin
											nextJ = j + 1;
											next_line = 0;
										end
										else
											next_line = 2;
									end
									
									2: begin
										data_o = regData[D_WIDTH * (j + l1 + l2) +: D_WIDTH];
										
										if(j[0])
											next_line = 1;
										else
											next_line = 3;
									end
									
									3: begin
										
										data_o = regData[D_WIDTH * (j + l1 + l2 + l3) +: D_WIDTH];
										
										if(j[0])
											next_line = 2;
										else begin
											next_line = 4;
											nextJ = j + 1;
										end
											
									end
									
									4: begin
										data_o = regData[D_WIDTH * (i + l1 + l2 + l3 + l4) +: D_WIDTH];
										nextI = i + 1;
										next_line = 3;
									end
								endcase
								
								nextIndex = index - 1;

							end
							default:
								nextIndex = index - 1;
						endcase
							
						// Decodificare terminata, reinitializare date si revenire
						// in stare de asteptare date
						if (nextIndex == 0) begin
							nextState = `WAIT_DATA;
							nextI = 0;
							nextJ = 0;
							next_line = 0;
							next_valid_o = 0;
						end
					end
				endcase
			end
			
			

endmodule
