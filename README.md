# Cordic - Rotation Mode
The cordic program is written in Verilog. The main objective of this project is to map the verilog program for the algorithm onto an FPGA using basic pins such as LEDs, switched and/or push buttons.
## cordic.v:
Verilog code for the fundamental CORDIC algorithm architecture
## cordic_lcd.v:
Verilog code to display the output co-ordinates onto the 7 segment display of an FPGA(as part of our project). You can modify this code to interface with any other peripheral as desired.
## cordic_tb.v:
Verilog testbench which works for both of the above mentioned designs.
## ASIC vs FPGA comparison:
The power, timing and area of Cordic algorithm is computed and compared in case of ASIC and FPGA separately for both pipelined and non-pipelined architectures
(To be updated)
