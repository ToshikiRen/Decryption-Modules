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

module decryption_top#(
			parameter addr_witdth = 8,
			parameter reg_width 	 = 16,
			parameter MST_DWIDTH = 32,
			parameter SYS_DWIDTH = 8
		)(
		// Clock and reset interface
		input clk_sys,
		input clk_mst,
		input rst_n,
		
		// Input interface
		input [MST_DWIDTH -1 : 0] data_i,
		input 						  valid_i,
		output busy,
		
		//output interface
		output [SYS_DWIDTH - 1 : 0] data_o,
		output      					 valid_o,
		
		// Register access interface
		input[addr_witdth - 1:0] addr,
		input read,
		input write,
		input [reg_width - 1 : 0] wdata,
		output[reg_width - 1 : 0] rdata,
		output done,
		output error
		
    );
	
	
	// TODO: Add and connect all Decryption blocks
	wire [reg_width - 1 : 0] select, caesar_key, scytale_key, zigzag_key;
	wire [SYS_DWIDTH - 1 : 0] dmux_caesar_data, dmux_scytale_data, dmux_zigzag_data;
	wire [SYS_DWIDTH - 1 : 0] caesar_data, scytale_data, zigzag_data;
	wire caesar_valid, scytale_valid, zigzag_valid;
	wire dmux_caesar_valid, dmux_scytale_valid, dmux_zigzag_valid;
	wire caesar_busy, scytale_busy, zigzag_busy;


	demux #(MST_DWIDTH, SYS_DWIDTH) dmux(
		.clk_mst(clk_mst),
		.clk_sys(clk_sys),
		.rst_n(rst_n),
		.data_i(data_i),
		.valid_i(valid_i),
		.select(select[1:0]),
		.data0_o(dmux_caesar_data),
		.valid0_o(dmux_caesar_valid),
		.data1_o(dmux_scytale_data),
		.valid1_o(dmux_scytale_valid),
		.data2_o(dmux_zigzag_data),
		.valid2_o(dmux_zigzag_valid));

	caesar_decryption #(SYS_DWIDTH) caesar(
		.clk(clk_sys),
		.rst_n(rst_n),
		.data_i(dmux_caesar_data),
		.valid_i(dmux_caesar_valid),
		.key(caesar_key),
		.busy(caesar_busy),
		.valid_o(caesar_valid),
		.data_o(caesar_data));
	
	scytale_decryption #(SYS_DWIDTH) scytale(
		.clk(clk_sys),
		.rst_n(rst_n),
		.data_i(dmux_scytale_data),
		.valid_i(dmux_scytale_valid),
		.key_M(scytale_key[7:0]),
		.key_N(scytale_key[15:8]),
		.busy(scytale_busy),
		.valid_o(scytale_valid),
		.data_o(scytale_data));
	
	zigzag_decryption #(SYS_DWIDTH) zigzag(
		.clk(clk_sys),
		.rst_n(rst_n),
		.data_i(dmux_zigzag_data),
		.valid_i(dmux_zigzag_valid),
		.key(zigzag_key[7:0]),
		.busy(zigzag_busy),
		.valid_o(zigzag_valid),
		.data_o(zigzag_data));

	mux #(SYS_DWIDTH) mux_uut(
		.clk(clk_sys),
		.rst_n(rst_n),
		.select(select[1:0]),
		.data0_i(caesar_data),
		.valid0_i(caesar_valid),
		.data1_i(scytale_data),
		.valid1_i(scytale_valid),
		.data2_i(zigzag_data),
		.valid2_i(zigzag_valid),
		.data_o(data_o),
		.valid_o(valid_o));

	// Instantiate the Unit Under Test (UUT)
	decryption_regfile #(addr_witdth, reg_width) uut (
		.clk(clk_sys), 
		.rst_n(rst_n), 
		.addr(addr), 
		.read(read), 
		.write(write), 
		.wdata(wdata), 
		.rdata(rdata), 
		.done(done), 
		.error(error), 
		.select(select), 
		.caesar_key(caesar_key), 
		.scytale_key(scytale_key), 
		.zigzag_key(zigzag_key)
	);


assign busy =  caesar_busy | scytale_busy | zigzag_busy;

endmodule
