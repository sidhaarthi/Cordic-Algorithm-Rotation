`timescale 1ns/1ps

module cordic_lcd(
    input wire clk,
    output signed [15:0] xout,
    output signed [15:0] yout,
	 output reg [6:0]hex0,hex1,hex2,hex3,hex4,hex5);
	 
reg[15:0]xin;
reg[15:0]yin;
reg[31:0]angle;

always@*
begin
xin = 200;
yin = 200;
angle = 'b00100000000000000000000000000000;
end
	 

reg znext;
wire signed [31:0] atan[0:15];

//// arctan lookup table ////

assign atan[00] = 'b00100000000000000000000000000000; // 1/2^0 or 45 degrees
assign atan[01] = 'b00010010111001000000010100011101; // 1/(2^-1) or 26.25 degrees
assign atan[02] = 'b00001001111110110011100001011011; // 1/(2^-2) or 14.03 degrees
assign atan[03] = 'b00000101000100010001000111010100;
assign atan[04] = 'b00000010100010110000110101000011;
assign atan[05] = 'b00000001010001011101011111100001;
assign atan[06] = 'b00000000101000101111011000011110;
assign atan[07] = 'b00000000010100010111110001010101;
assign atan[08] = 'b00000000001010001011111001010011;
assign atan[09] = 'b00000000000101000101111100101110;
assign atan[10] = 'b00000000000010100010111110011000;
assign atan[11] = 'b00000000000001010001011111001100;
assign atan[12] = 'b00000000000000101000101111100110;
assign atan[13] = 'b00000000000000010100010111110011;
assign atan[14] = 'b00000000000000001010001011111001;
assign atan[15] = 'b00000000000000000101000101111100;

parameter width = 16;
reg signed [15:0] x_start,y_start;
reg [3:0] out = 4'b0000;


wire [1:0] quad;
assign quad = angle[31:30];

reg signed [width:0] x [0:width-1]; //17 bit wide
reg signed [width:0] y [0:width-1]; //17 bit wide
reg signed [31:0] z [0:width-1];


always @(posedge clk)
begin

x_start = (xin>>>1)+(xin>>>4)+(xin>>>5);
y_start = (yin>>>1)+(yin>>>4)+(yin>>>5);

case(quad)
	2'b00,2'b11:
		begin		// -90 to 90
		x[0] <= x_start;
		y[0] <= y_start;
		z[0] <= angle;
		end
	2'b01:				//subtract 90	(second quadrant)
		begin
		x[0] <= -y_start;
		y[0] <= x_start;
		z[0] <= {2'b00,angle[29:0]};
		end
	2'b10:				// add 90 (third quadrant)
		begin
		x[0] <= y_start;			
		y[0] <= -x_start;
		z[0] <= {2'b11,angle[29:0]};
		end
		  
    endcase
end


/////////////////////////////////////////////////////////////////////////////////////


genvar i;
generate
for (i=0;i<15;i=i+1)
begin: iterations

	wire signed [width:0] x_shift, y_shift;
	wire signed z_sign;
	assign z_sign = z[i][31];

	assign x_shift = x[i] >>> i;
	assign y_shift = y[i] >>> i;

	always @(posedge clk)
		begin
		x[i+1] <= z_sign ? x[i] + y_shift : x[i] - y_shift;
		y[i+1] <= z_sign ? y[i] - x_shift : y[i] + x_shift;
		z[i+1] <= z_sign ? z[i] + atan[i] : z[i] - atan[i];
		end
end
endgenerate

assign xout = x[width-1];
assign yout = y[width-1];

///////////////////////////////////////////////////////////////////////////////////////

//// 7 segment display of output in hexadecimal ////
reg [3:0]yout0,yout1,yout2,yout3;
reg [3:0]xout0,xout1,xout2,xout3;


always@(yout)
begin
yout0 = yout[3:0];
yout1 = yout[7:4];
yout2 = yout[11:8];
yout3 = yout[15:12];

xout0 = xout[3:0];
xout1 = xout[7:4];
xout2 = xout[11:8];
xout3 = xout[15:12];

case(xout0)
4'b0000: hex0 = 7'b1000000;
4'b0001: hex0 = 7'b1111001;
4'b0010: hex0 = 7'b0100100;
4'b0011: hex0 = 7'b0110000;
4'b0100: hex0 = 7'b0011001;
4'b0101: hex0 = 7'b0010010;
4'b0110: hex0 = 7'b0000010;
4'b0111: hex0 = 7'b1111000;
4'b1000: hex0 = 7'b0000000;
4'b1001: hex0 = 7'b0010000;
default: hex0 = 7'b1111111;
endcase

case(xout1)
4'b0000: hex1 = 7'b1000000;
4'b0001: hex1 = 7'b1111001;
4'b0010: hex1 = 7'b0100100;
4'b0011: hex1 = 7'b0110000;
4'b0100: hex1 = 7'b0011001;
4'b0101: hex1 = 7'b0010010;
4'b0110: hex1 = 7'b0000010;
4'b0111: hex1 = 7'b1111000;
4'b1000: hex1 = 7'b0000000;
4'b1001: hex1 = 7'b0010000;
default: hex1 = 7'b1111111;
endcase

case(xout2)
4'b0000: hex2 = 7'b1000000;
4'b0001: hex2 = 7'b1111001;
4'b0010: hex2 = 7'b0100100;
4'b0011: hex2 = 7'b0110000;
4'b0100: hex2 = 7'b0011001;
4'b0101: hex2 = 7'b0010010;
4'b0110: hex2 = 7'b0000010;
4'b0111: hex2 = 7'b1111000;
4'b1000: hex2 = 7'b0000000;
4'b1001: hex2 = 7'b0010000;
default: hex2 = 7'b1111111;
endcase

 case(yout0)
4'b0000: hex3 = 7'b1000000;
4'b0001: hex3 = 7'b1111001;
4'b0010: hex3 = 7'b0100100;
4'b0011: hex3 = 7'b0110000;
4'b0100: hex3 = 7'b0011001;
4'b0101: hex3 = 7'b0010010;
4'b0110: hex3 = 7'b0000010;
4'b0111: hex3 = 7'b1111000;
4'b1000: hex3 = 7'b0000000;
4'b1001: hex3 = 7'b0010000;
default: hex3 = 7'b1111111;
endcase

case(yout1)
4'b0000: hex4 = 7'b1000000;
4'b0001: hex4 = 7'b1111001;
4'b0010: hex4 = 7'b0100100;
4'b0011: hex4 = 7'b0110000;
4'b0100: hex4 = 7'b0011001;
4'b0101: hex4 = 7'b0010010;
4'b0110: hex4 = 7'b0000010;
4'b0111: hex4 = 7'b1111000;
4'b1000: hex4 = 7'b0000000;
4'b1001: hex4 = 7'b0010000;
default: hex4 = 7'b1111111;
endcase

case(yout2)
4'b0000: hex5 = 7'b1000000;
4'b0001: hex5 = 7'b1111001;
4'b0010: hex5 = 7'b0100100;
4'b0011: hex5 = 7'b0110000;
4'b0100: hex5 = 7'b0011001;
4'b0101: hex5 = 7'b0010010;
4'b0110: hex5 = 7'b0000010;
4'b0111: hex5 = 7'b1111000;
4'b1000: hex5 = 7'b0000000;
4'b1001: hex5 = 7'b0010000;
default: hex5 = 7'b1111111;
endcase

end

endmodule
