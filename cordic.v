module cordic(
    input clk,
    input signed [15:0]xin,
    input signed [15:0]yin,
    input signed [31:0]angle,
    output signed [15:0] xout,
    output signed [15:0] yout);

reg znext;
wire signed [31:0] atan[0:15];

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
	2'b00,2'b11: // no change in case of 1st and 4th quadrant
		begin	
		x[0] <= x_start;
		y[0] <= y_start;
		z[0] <= angle;
		end
	2'b01: //2nd quadrant --> subtract 90			
		begin
		x[0] <= -y_start;
		y[0] <= x_start;
		z[0] <= {2'b00,angle[29:0]};
		end
	2'b10: //3rd quadrant --> add 90
		begin
		x[0] <= y_start;			
		y[0] <= -x_start;
		z[0] <= {2'b11,angle[29:0]};
		end
    endcase
end

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

endmodule
