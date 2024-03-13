`timescale 1ns / 1ps

// CEP: GORVE KUMAR (CS-20125), MALAIKA ALI (CS-20019), SYED MUHAMMAD (CS-20015), FARAH HUSSAIN (CS-20003)
// Create Date: 12/29/2023 08:25:59 PM
// Module Name: CEP_CS125
// Target Devices: XLINIX NEXYS A7 FPGA

module CEP_CS125(
        input CLK100MHZ,        // nexys clk signal
        input [12:0] temp_data_switch,
        input sensor, reset,
        inout TEMP_SDA,         // i2c sda on temp sensor - bidirectional
        output TEMP_SCL,        // i2c scl on temp sensor
        output [6:0] SEG_CA,    // 7 segments of each display
        output [7:0] SEG_AN,
        output decimal_point,
        output Reset_LED, Sensor_LED,
        output [12:0] Temp_LED, // nexys leds = binary temp in deg C
        output R, G, B
    );
    wire clock_200kHz;  // 200kHz SCL
    wire [15:0] temp_data_I2C;
    
    // Instantiate 200kHz clock generator
    CLK_Generator_200kHz CLK_Generator_200kHz(.reset(reset), .clk_100MHz(CLK100MHZ), .clk_200kHz(clock_200kHz));
    
    // Instantiate i2c master
    Master_I2C Master_I2C(.clk_200kHz(clock_200kHz), .reset(reset), .temp_data(temp_data_I2C), .TEMP_SDA(TEMP_SDA), .TEMP_SCL(TEMP_SCL));
    
    // Instantiate Display
    Display Display(.clk_100MHz(CLK100MHZ), .temp_data_switch(temp_data_switch), .temp_data_I2C(temp_data_I2C), 
        .sensor(sensor), .reset(reset),
        .Temp_LED(Temp_LED), .Sensor_LED(Sensor_LED), .Reset_LED(Reset_LED),
        .SEG_AN(SEG_AN), .SEG_CA(SEG_CA), .decimal_point(decimal_point),
        .R(R), .G(G), .B(B));

endmodule