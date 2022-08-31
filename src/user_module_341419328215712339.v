`default_nettype none

//  Top level io for this module should stay the same to fit into the scan_wrapper.
//  The pin connections within the user_module are up to you,
//  although (if one is present) it is recommended to place a clock on io_in[0].
//  This allows use of the internal clock divider if you wish.
module user_module_341419328215712339(
	input [7:0] io_in, 
	output [7:0] io_out
);
	wire clk = io_in[0];
	wire rst = io_in[1];
	wire [5:0]sw1 = io_in[7:2];

	//assign io_out = breg_in[15:8] ^ breg_in[7:0];
	assign io_out = mulout[7:0] ^ mulout[15:8];


	reg [16:0]breg;
	wire [15:0]x = {io_in, io_in};

	wire [7:0]mulin1 = {io_in, io_in};
	wire [7:0]mulin2 = {io_in, io_in};
	wire [15:0]mulout;
	//wire Ld = io_in[7];
	//wire Valid;
	//Booth_Multiplier_1xA #(.N(8)) mul_inst(
		//.Clk(clk),
		//.Rst(rst),
		//.Ld(Ld),
		//.Valid(Valid),
		//.M(mulin1),
		//.R(mulin2),
		//.P(mulout)
	//);
	mul #(.WIDTH(8)) mul_inst(
		//.Clk(clk),
		//.Rst(rst),
		//.Ld(Ld),
		//.Valid(Valid),
		.a(mulin1),
		.b(mulin2),
		.c(mulout)
	);

	//reg [15:0]addin1;
	//reg [15:0]addin2;
	//wire [16:0]addout;
	//add #(.WIDTH(16)) add_inst(
		//.a(addin1),
		//.b(addin2),
		//.c(addout)
	//);

	//reg [7:0]cnt = 0;
	//always @ (posedge clk) begin
		//cnt <= cnt == 10 ? 0 : cnt + 1;
		//breg <= breg_in;
	//end

	//reg [16:0]breg_in;
	//always @ (*) begin
		//mulin1 = 0;
		//mulin2 = 0;
		//addin1 = 0;
		//addin2 = 0;
		//breg_in = 0;
		//case(cnt)
			//0: begin
				//mulin1 = x[7:0];
				//mulin2 = x[7:0];
				//breg_in = {1'b0, mulout};
			//end
			//1: begin
				//mulin1 = x[15:8];
				//mulin2 = x[7:0];
				//addin1 = {8'b0, breg[15:8]};
				//addin2 = mulout;
				//breg_in = addout;
			//end
			//2: begin
				//mulin1 = x[7:0];
				//mulin2 = x[15:8];
				//addin1 = breg[15:0];
				//addin2 = mulout;
				//breg_in = addout;
			//end
			//3: begin
				//mulin1 = x[15:8];
				//mulin2 = x[15:8];
				//addin1 = {7'b0, breg[16:8]};
				//addin2 = mulout;
				//breg_in = addout;
			//end
		//endcase
	//end
endmodule

//module add
//#(
	//parameter WIDTH=16
//)
//(
	//input [WIDTH-1:0]a,
	//input [WIDTH-1:0]b,
	//output [WIDTH:0]c
//);
	//assign c = a + b;
//endmodule

/*
 *  my_multiplier - an unoptimized multiplier
 *
 *  copyright (c) 2021  hirosh dabui <hirosh@dabui.de>
 *
 *  permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  the software is provided "as is" and the author disclaims all warranties
 *  with regard to this software including all implied warranties of
 *  merchantability and fitness. in no event shall the author be liable for
 *  any special, direct, indirect, or consequential damages or any damages
 *  whatsoever resulting from loss of use, data or profits, whether in an
 *  action of contract, negligence or other tortious action, arising out of
 *  or in connection with the use or performance of this software.
 *
 */
module mul
#(
	parameter WIDTH = 16
)
(
	input      [WIDTH-1:0]      a,
	input      [WIDTH-1:0]      b,
	output reg [(WIDTH<<1)-1:0] c = 0
);

reg [(WIDTH<<1)-1:0] tmp;

reg  [(WIDTH<<1)-1:0] add_a[WIDTH-1:0];
reg  [(WIDTH<<1)-1:0] add_b[WIDTH-1:0];
wire [(WIDTH<<1)-1:0] add_y[WIDTH-1:0];

genvar k;
generate for (k = 0; k < WIDTH; k = k +1) begin
		full_addr #(WIDTH<<1) full_addr_i(add_a[k], add_b[k], add_y[k]);
	end endgenerate

integer i;
integer j;
generate always @(*) begin
		tmp = 0;
		c   = 0;

		/* generate parallel structure */
		for (j = 0; j < WIDTH; j = j + 1) begin
			for (i = 0; i < WIDTH; i = i + 1) begin
				tmp[i] = b[i] & a[j];
			end
			add_a[j] = c;
			add_b[j] = (tmp << j);
			c = add_y[j];
		end
	end endgenerate

endmodule

	// carry ripple style
	module full_addr
	#(
		parameter WIDTH = 16
	)
	(
		input      [WIDTH-1:0] a,
		input      [WIDTH-1:0] b,
		output reg [WIDTH-1:0] y = 0
	);

integer i;
reg [WIDTH-1:0] c = 1;
generate always @(*) begin
		c[0] = 0;
		y[0] = c[0] ^ (a[0] ^ b[0]);
		c[0] = a[0]&b[0] | b[0]&c[0] | a[0]&c[0];
		for (i = 1; i < WIDTH; i = i +1) begin
			y[i] = c[i -1] ^ (a[i] ^ b[i]);
			c[i] = a[i]&b[i] | b[i]&c[i -1] | a[i]&c[i -1];
		end
	end endgenerate

endmodule

/////////////////////////////////////////////////////////////////////////////////
////
////  Copyright 2010-2012 by Michael A. Morris, dba M. A. Morris & Associates
////
////  All rights reserved. The source code contained herein is publicly released
////  under the terms and conditions of the GNU Lesser Public License. No part of
////  this source code may be reproduced or transmitted in any form or by any
////  means, electronic or mechanical, including photocopying, recording, or any
////  information storage and retrieval system in violation of the license under
////  which the source code is released.
////
////  The souce code contained herein is free; it may be redistributed and/or 
////  modified in accordance with the terms of the GNU Lesser General Public
////  License as published by the Free Software Foundation; either version 2.1 of
////  the GNU Lesser General Public License, or any later version.
////
////  The souce code contained herein is freely released WITHOUT ANY WARRANTY;
////  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
////  PARTICULAR PURPOSE. (Refer to the GNU Lesser General Public License for
////  more details.)
////
////  A copy of the GNU Lesser General Public License should have been received
////  along with the source code contained herein; if not, a copy can be obtained
////  by writing to:
////
////  Free Software Foundation, Inc.
////  51 Franklin Street, Fifth Floor
////  Boston, MA  02110-1301 USA
////
////  Further, no use of this source code is permitted in any form or means
////  without inclusion of this banner prominently in any derived works. 
////
////  Michael A. Morris
////  Huntsville, AL
////
/////////////////////////////////////////////////////////////////////////////////

//`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//// Company:         M. A. Morris & Associates
//// Engineer:        Michael A. Morris
//// 
//// Create Date:     19:48:02 07/10/2010 
//// Design Name:     Booth Multiplier (1 bit at a time)
//// Module Name:     Booth_Multiplier_1xA.v
//// Project Name:    Booth_Multiplier
//// Target Devices:  Spartan-3AN
//// Tool versions:   Xilinx ISE 10.1 SP3
////
//// Description:
////
////  This module implements a parameterized multiplier which uses the Booth
////  algorithm for its implementation. The implementation is based on the 
////  algorithm described in "Computer Organization", Hamacher et al, McGraw-
////  Hill Book Company, New York, NY, 1978, ISBN: 0-07-025681-0. 
////
//// Dependencies: 
////
//// Revision: 
////
////  0.01    10G10   MAM     File Created
////
////  1.00    12I02   MAM     Changed parameterization from a power of 2 to the
////                          number of bits to match the other modules in this
////                          family of Booth multipliers. Made the structure of
////                          the module match that of the x2 and x4 modules.
////
////  1.10    12I03   MAM     Changed the implementation technique of the partial
////                          product summer to match that of the x4A module. This
////                          reduces the adder to a single adder with a preceed-
////                          ing multiplexer that generates the proper operand as
////                          0, M w/ no carry in, or ~M w/ carry input.
////          
////
//// Additional Comments: 
////
//////////////////////////////////////////////////////////////////////////////////

//module Booth_Multiplier_1xA #(
    //parameter N = 16            // Width = N: multiplicand & multiplier
//)(
    //input   Rst,                // Reset
    //input   Clk,                // Clock
    
    //input   Ld,                 // Load Registers and Start Multiplier
    //input   [(N - 1):0] M,      // Multiplicand
    //input   [(N - 1):0] R,      // Multiplier
    //output  reg Valid,          // Product Valid
    //output  reg [(2*N - 1):0] P // Product <= M * R
//);

/////////////////////////////////////////////////////////////////////////////////
////
////  Local Parameters
////

/////////////////////////////////////////////////////////////////////////////////
////
////  Declarations
////

//reg     [4:0] Cntr;             // Operation Counter
//reg     [1:0] Booth;            // Booth Recoding Field
//reg     Guard;                  // Shift bit for Booth Recoding
//reg     [N:0] A;                // Multiplicand w/ sign guard bit
//reg     [N:0] B;                // Input Operand to Adder w/ sign guard bit
//reg     Ci;                     // Carry input to Adder
//reg     [N:0] S;                // Adder w/ sign guard bit
//wire    [N:0] Hi;               // Upper half of Product w/ sign guard

//reg     [2*N:0] Prod;           // Double length product w/ sign guard bit

/////////////////////////////////////////////////////////////////////////////////
////
////  Implementation
////

//always @(posedge Clk)
//begin
    //if(Rst)
        //Cntr <= #1 0;
    //else if(Ld)
        //Cntr <= #1 N;
    //else if(|Cntr)
        //Cntr <= #1 (Cntr - 1);
//end

////  Multiplicand Register
////      includes an additional bit to guard sign bit in the event the
////      most negative value is provided as the multiplicand.

//always @(posedge Clk)
//begin
    //if(Rst)
        //A <= #1 0;
    //else if(Ld)
        //A <= #1 {M[N - 1], M};  
//end

////  Compute Upper Partial Product: (N + 1) bits in width

//always @(*) Booth <= {Prod[0], Guard};  // Booth's Multiplier Recoding field

//assign Hi = Prod[2*N:N];                // Upper Half of the Product Register

//always @(*)
//begin
    //case(Booth)
        //2'b01   : {Ci, B} <= {1'b0,  A};
        //2'b10   : {Ci, B} <= {1'b1, ~A};
        //default : {Ci, B} <= 0;
    //endcase
//end

//always @(*) S <= Hi + B + Ci;

////  Register Partial products and shift right arithmetically.
////      Product register has a sign extension guard bit.

//always @(posedge Clk)
//begin
    //if(Rst)
        //Prod <= #1 0;
    //else if(Ld)
        //Prod <= #1 R;
    //else if(|Cntr)  // Arithmetic right shift 1 bit
        //Prod <= #1 {S[N], S, Prod[(N - 1):1]};
//end

//always @(posedge Clk)
//begin
    //if(Rst)
        //Guard <= #1 0;
    //else if(Ld)
        //Guard <= #1 0;
    //else if(|Cntr)
        //Guard <= #1 Prod[0];
//end

////  Assign the product less the sign extension guard bit to the output port

//always @(posedge Clk)
//begin
    //if(Rst)
        //P <= #1 0;
    //else if(Cntr == 1)
        //P <= #1 {S, Prod[(N - 1):1]};
//end

////  Count the number of shifts
////      This implementation does not use any optimizations to perform multiple
////      bit shifts to skip over runs of 1s or 0s.

//always @(posedge Clk)
//begin
    //if(Rst)
        //Valid <= #1 0;
    //else
        //Valid <= #1 (Cntr == 1);
//end

//endmodule
