module cordic(
input clk,
input signed [15:0]x_in,y_in,
input signed [31:0]angle,
output signed [15:0]x_out, y_out);

wire [1:0]quad;
assign quad = angle[31:30];

//arctan LUT:
wire signed [31:0]atan[15:0];
//scale = (angle/360)*(2^32)
assign atan[00] = 32'b00100000000000000000000000000000; //2^0
assign atan[01] = 32'b00010010111001000000010100011101; //2^-1
assign atan[02] = 32'b00001001111110110011100001011011;
assign atan[03] = 32'b00000101000100010001000111010100;
assign atan[04] = 32'b00000010100010110000110101000011;
assign atan[05] = 32'b00000001010001011101011111100001;
assign atan[06] = 32'b00000000101000101111011000011110;
assign atan[07] = 32'b00000000010100010111110001010101;
assign atan[08] = 32'b00000000001010001011111001010011;
assign atan[09] = 32'b00000000000101000101111100101110;
assign atan[10] = 32'b00000000000010100010111110011000;
assign atan[11] = 32'b00000000000001010001011111001100;
assign atan[12] = 32'b00000000000000101000101111100110;
assign atan[13] = 32'b00000000000000010100010111110011;
assign atan[14] = 32'b00000000000000001010001011111001;
assign atan[15] = 32'b00000000000000000101000101111101;
assign atan[16] = 32'b00000000000000000010100010111110;

reg [16:0] x[15:0];
reg [16:0] y[15:0];
reg [31:0] z[15:0];

always@(posedge clk)
begin
    case(quad)
        2'b00, 2'b11:
            begin
            x[0] <= x_in;
            y[0] <= y_in;
            z[0] <= angle;
            end
        2'b01:
            begin
            x[0] <= -y_in;
            y[0] <= x_in;
            z[0] <= {2'b00, angle[29:0]}; //subtracting pi/2
            end
        2'b10:
            begin
            x[0] <= y_in;
            y[0] <= -x_in;
            z[0] <= {2'b11,angle[29:0]}; //adding pi/2
            end
    endcase
end

//iterating from 0 to 15 stages:
genvar i; 
generate 
for (i=0;i<=15;i=i+1)
    begin
        wire signed [15:0]x_shift, y_shift;
        wire z_sign;
        assign z_sign = z[i][31];
        assign x_shift = x[i]>>>i;
        assign y_shift = y[i]>>>i;
        always@(posedge clk)
            begin
            	    x[i+1] <= z_sign ? x[i] + y_shift : x[i] - y_shift;
		    y[i+1] <= z_sign ? y[i] - x_shift : y[i] + x_shift;
		    z[i+1] <= z_sign ? z[i] + atan[i] : z[i] - atan[i];
            end  
    end
endgenerate

//outputs:
assign x_out = x[15];
assign y_out = y[15];

endmodule
