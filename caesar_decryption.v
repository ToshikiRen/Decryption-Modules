`timescale 1ns / 1ps


`define RESET 0
`define LISTENING 10
module caesar_decryption#(
				parameter D_WIDTH = 8,
				parameter KEY_WIDTH = 16
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

			
			always @(posedge clk) begin
				
				// Busy este mereu pe 0 in cazul acesta
				busy <= 0;
				
				// Tratare reset
				if(~rst_n) begin
					valid_o <= 0;
					data_o <= 0;
				end
				// Punem datele decodificate pe iesire la urmatorul
				// ciclu de ceas
				if(valid_i) begin
					data_o <= data_i - key;
					valid_o <= valid_i;
				end
				// Daca nu avem date pe intrare punem 0 pe iesire
				// si valid la clk urmator de ceas
				else begin
					valid_o <= 0;
					data_o <= 0;
				end
			end
			

			
endmodule
