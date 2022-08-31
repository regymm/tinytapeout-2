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

	assign io_out = breg_in[15:8] ^ breg_in[7:0];


	reg [16:0]breg;
	wire [15:0]x = {io_in, io_in};

	reg [3:0]mulin1;
	reg [3:0]mulin2;
	wire [15:0]mulout;
	Booth_Main #(.n(8)) mul_inst(
		.a(mulin1),
		.b(mulin2),
		.out(mulout)
	);

	reg [7:0]addin1;
	reg [7:0]addin2;
	wire [8:0]addout;
	add #(.WIDTH(8)) add_inst(
		.a(addin1),
		.b(addin2),
		.c(addout)
	);

	reg [7:0]cnt = 0;
	always @ (posedge clk) begin
		cnt <= cnt == 10 ? 0 : cnt + 1;
		breg <= breg_in;
	end

	reg [16:0]breg_in;
	always @ (*) begin
		mulin1 = 0;
		mulin2 = 0;
		addin1 = 0;
		addin2 = 0;
		breg_in = 0;
		case(cnt)
			0: begin
				mulin1 = x[7:0];
				mulin2 = x[7:0];
				breg_in = {1'b0, mulout};
			end
			1: begin
				mulin1 = x[15:8];
				mulin2 = x[7:0];
				addin1 = {8'b0, breg[15:8]};
				addin2 = mulout;
				breg_in = addout;
			end
			2: begin
				mulin1 = x[7:0];
				mulin2 = x[15:8];
				addin1 = breg[15:0];
				addin2 = mulout;
				breg_in = addout;
			end
			3: begin
				mulin1 = x[15:8];
				mulin2 = x[15:8];
				addin1 = {7'b0, breg[16:8]};
				addin2 = mulout;
				breg_in = addout;
			end
		endcase
	end
endmodule

module add
#(
	parameter WIDTH=16
)
(
	input [WIDTH-1:0]a,
	input [WIDTH-1:0]b,
	output [WIDTH:0]c
);
	assign c = a + b;
endmodule

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
//module mul
//#(
	//parameter WIDTH = 16
//)
//(
	//input      [WIDTH-1:0]      a,
	//input      [WIDTH-1:0]      b,
	//output reg [(WIDTH<<1)-1:0] c = 0
//);

//reg [(WIDTH<<1)-1:0] tmp;

//reg  [(WIDTH<<1)-1:0] add_a[WIDTH-1:0];
//reg  [(WIDTH<<1)-1:0] add_b[WIDTH-1:0];
//wire [(WIDTH<<1)-1:0] add_y[WIDTH-1:0];

//genvar k;
//generate for (k = 0; k < WIDTH; k = k +1) begin
        //full_addr #(WIDTH<<1) full_addr_i(add_a[k], add_b[k], add_y[k]);
    //end endgenerate

//integer i;
//integer j;
//generate always @(*) begin
        //tmp = 0;
        //c   = 0;

        //[> generate parallel structure <]
        //for (j = 0; j < WIDTH; j = j + 1) begin
            //for (i = 0; i < WIDTH; i = i + 1) begin
                //tmp[i] = b[i] & a[j];
            //end
            //add_a[j] = c;
            //add_b[j] = (tmp << j);
            //c = add_y[j];
        //end
    //end endgenerate

//endmodule

    //// carry ripple style
    //module full_addr
    //#(
        //parameter WIDTH = 16
    //)
    //(
        //input      [WIDTH-1:0] a,
        //input      [WIDTH-1:0] b,
        //output reg [WIDTH-1:0] y = 0
    //);

//integer i;
//reg [WIDTH-1:0] c = 1;
//generate always @(*) begin
        //c[0] = 0;
        //y[0] = c[0] ^ (a[0] ^ b[0]);
        //c[0] = a[0]&b[0] | b[0]&c[0] | a[0]&c[0];
        //for (i = 1; i < WIDTH; i = i +1) begin
            //y[i] = c[i -1] ^ (a[i] ^ b[i]);
            //c[i] = a[i]&b[i] | b[i]&c[i -1] | a[i]&c[i -1];
        //end
    //end endgenerate

//endmodule
module Booth_Main #(parameter n=8)(out,a,b);

output [(2*n):0]out;
input [n:0]a,b;

wire [(2*n):0]w[n:0];
wire [n+1:0]q;
assign q = {b,1'b0};
assign out=w[0]+(w[1]<<1)+(w[2]<<2)+(w[3]<<3)+(w[4]<<4)+(w[5]<<5)+(w[6]<<6)+(w[7]<<7);
genvar i;
generate
for(i=0;i<=8;i=i+1)
begin
MUX #(.n(8))m1(w[i],a,q[i+1:i]);
end
endgenerate
endmodule

module MUX #(parameter n=8) (out,a,s);
output reg [(2*n):0]out;
input [n:0]a;
input [1:0]s;

always @ (a,s)
begin
case(s)
2'b00: out<=0;
2'b01: out<= a;
2'b10: out<= ~a+1;
2'b11: out<=0;
endcase
end
endmodule
