`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:12:00 11/23/2020 
// Design Name: 
// Module Name:    demux 
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
`define RESET 100
//`define PREPARE_OUTPUT_DATA 150
`define OUTPUT_DATA 200

`define caesar 0
`define scytale 1
`define zigzag 2

module demux #(
		parameter MST_DWIDTH = 32,
		parameter SYS_DWIDTH = 8
	)(
		// Clock and reset interface
		input clk_sys,
		input clk_mst,
		input rst_n,
		
		//Select interface
		input[1:0] select,
		
		// Input interface
		input [MST_DWIDTH -1  : 0]	 data_i,
		input 						 	 valid_i,
		
		//output interfaces
		output reg [SYS_DWIDTH - 1 : 0] 	data0_o,
		output reg     						valid0_o,
		
		output reg [SYS_DWIDTH - 1 : 0] 	data1_o,
		output reg     						valid1_o,
		
		output reg [SYS_DWIDTH - 1 : 0] 	data2_o,
		output reg     						valid2_o
    );
	
	reg[MST_DWIDTH - 1 : 0] data_mst;
	reg valid_i_mst;
	reg[7 : 0] state, next_state;
	//reg[7 : 0] counter = 0;
	reg[7 : 0] i, i_next;
	
	always @(posedge clk_mst) begin
		
		// latch pe intrari
		data_mst <= data_i;
		valid_i_mst <= valid_i;
		
		state <= next_state;
		if(~rst_n) begin	
			state <= `RESET;
		end
		
		
	end
	
	// Trecere la urmatorul cuvant de 8 biti de afisat
	always @(posedge clk_sys) begin
		
		i <= i_next;
		
	end
	
	always @(*) begin
		
		// Reinitializare valori la inceput
		valid0_o = 0;
		valid1_o = 0;
		valid2_o = 0;
		data0_o = 0;
		data1_o = 0;
		data2_o = 0;
		
		case(state) 
		
			`RESET: begin
			
				i_next = 3;
				valid0_o = 0;
				valid1_o = 0;
				valid2_o = 0;
				data0_o = 0;
				data1_o = 0;
				data2_o = 0;
				next_state = `OUTPUT_DATA;
				
			end
			
			`OUTPUT_DATA: begin
				
				if(valid_i_mst) begin
					
					// Selectare output line
					case(select)
							
						`caesar: begin
						
							valid0_o = 1;
							data0_o = data_mst[SYS_DWIDTH * i +: 8];
							i_next = i - 1;
							
						end
						`scytale: begin
						
							valid1_o = 1;
							data1_o = data_mst[SYS_DWIDTH * i +: 8];
							i_next = i - 1;
							
							
						end
						`zigzag: begin
						
							valid2_o = 1;
							data2_o = data_mst[SYS_DWIDTH * i +: 8];
							i_next = i - 1;
							
							
						end

						
					endcase

					if(i == 0) begin
					
						next_state = `OUTPUT_DATA;
						// Reinitializare i_next
						i_next = 3;
					end
				end
			end

		endcase
	end

endmodule
