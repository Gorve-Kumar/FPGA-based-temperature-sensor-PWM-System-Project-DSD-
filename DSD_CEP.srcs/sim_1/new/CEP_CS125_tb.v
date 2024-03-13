`timescale 1ns / 1ps

module test1;  
  // Inputs
  reg CLK100MHZ;
  reg [12:0] temp_data_switch;
  reg reset; reg sensor;
  wire TEMP_SDA, TEMP_SCL;

  // Outputs
  wire [6:0] SEG_CA;
  wire [7:0] SEG_AN;
  wire decimal_point;
  wire [12:0] Temp_LED;
  wire Reset_LED, Sensor_LED;
  wire R, G, B;

  // Instantiate the design under test (DUT)
  CEP_CS125 uut (
        .CLK100MHZ(CLK100MHZ),
        .temp_data_switch(temp_data_switch),
        .reset(reset), .sensor(sensor),
        .TEMP_SDA(TEMP_SDA), .TEMP_SCL(TEMP_SCL),
        .SEG_CA(SEG_CA), .SEG_AN(SEG_AN), .decimal_point(decimal_point),
        .Temp_LED(Temp_LED), .Reset_LED(Reset_LED), .Sensor_LED(Sensor_LED),
        .R(R), .G(G), .B(B));

  // Clock generation
  always #0.1 CLK100MHZ = !CLK100MHZ;
//  always #10 CLK100MHZ = !CLK100MHZ;

  initial begin
        // Initialize inputs
        CLK100MHZ = 0;
        reset = 1;
        #100; reset = 0; sensor = 0;
              temp_data_switch = 13'b0_0000_0000_0000; // (Decimal: 0)
        #100; temp_data_switch = 13'b1_1101_0100_1001; // (Decimal: -44)
        #100; temp_data_switch = 13'b1_1101_1000_0000; // (Decimal: -40)
        #100; temp_data_switch = 13'b1_1110_0000_1110; // (Decimal: -32)
        #100; temp_data_switch = 13'b1_1111_0000_1101; // (Decimal: -16)
        #100; temp_data_switch = 13'b1_1111_1111_0110; // (Decimal: -1)
        #100; temp_data_switch = 13'b0_0000_0000_0000; // (Decimal: 0)
        #100; temp_data_switch = 13'b0_0000_1000_1001; // (Decimal: 8)
        #100; temp_data_switch = 13'b0_0001_0000_1110; // (Decimal: 16)  
        #100; temp_data_switch = 13'b0_0001_1000_1010; // (Decimal: 24)
        #100; temp_data_switch = 13'b0_0010_1000_0110; // (Decimal: 40)
        #100; temp_data_switch = 13'b0_0011_0000_1011; // (Decimal: 48)
        #100; temp_data_switch = 13'b0_0011_1000_0001; // (Decimal: 56)
        #100; temp_data_switch = 13'b0_0100_0000_1001; // (Decimal: 64)
        #100; temp_data_switch = 13'b0_0101_0000_0010; // (Decimal: 80)
        #100; temp_data_switch = 13'b0_0110_0000_1011; // (Decimal: 96)        
        #100; temp_data_switch = 13'b0_0110_1000_1001; // (Decimal: 104)
        #100; temp_data_switch = 13'b0_0000_0000_0000;
        #100; reset = 1;
  end
endmodule