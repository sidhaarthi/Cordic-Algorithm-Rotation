module cordic_tb;
reg clk;
reg [15:0]xin, yin;
reg [31:0]angle;
wire [15:0] xout, yout;

cordic uut (clk, xin, yin, angle, xout, yout);

initial begin
		clk = 0;
		xin = 0;
		yin = 0;
		angle = 0;
		#100;
		
		xin = 32000;
		yin = 32000;
		angle = 'b00100000000000000000000000000000;
   // check for other angles
   // angle = 'b00000000001010001011111001010011;
   // angle = 'b00110010100010110000110101000011;
		 
		 clk = 'b0;
		 forever
		 begin
			#5 clk = !clk;
		 end
	end
endmodule
