`timescale 1ns / 1ps

// CEP: GORVE KUMAR (CS-20125), MALAIKA ALI (CS-20019), SYED MUHAMMAD (CS-20015), FARAH HUSSAIN (CS-20003)
// Create Date: 01/03/2024 03:48:26 PM
// Module Name: Display
// Project Name: CEP

module Display(
        input clk_100MHz, // Nexys A7 clock
        input [12:0] temp_data_switch,
        input [15:0] temp_data_I2C, // Temp data from i2c master
        input sensor, reset,
        output [12:0] Temp_LED,   // nexys leds = binary temp in deg C
        output Sensor_LED, Reset_LED,
        output reg [7:0] SEG_AN,
        output reg [6:0] SEG_CA,  // 7 Segments of Displays
        output reg decimal_point, // Decimal point
        output reg R, reg G, reg B
    );
    
    wire [15:0] temperature;
    // Initializing 8 regs for 8 seven segment value to be displayed.
    reg [3:0] sign_place, tens_place, ones_place, first_decimal_place, second_decimal_place, third_decimal_place, fourth_decimal_place, unit;
    reg [3:0] current_segment;
    
    // CODE TO SHOW TEMPERATURE ON SEGMENTS:
    always @(posedge clk_100MHz) begin
        case(current_segment)
            4'b0000 : SEG_CA = 7'b1000000; //0
            4'b0001 : SEG_CA = 7'b1111001; //1
            4'b0010 : SEG_CA = 7'b0100100; //2
            4'b0011 : SEG_CA = 7'b0110000; //3
            4'b0100 : SEG_CA = 7'b0011001; //4
            4'b0101 : SEG_CA = 7'b0010010; //5
            4'b0110 : SEG_CA = 7'b0000010; //6
            4'b0111 : SEG_CA = 7'b1111000; //7
            4'b1000 : SEG_CA = 7'b0000000; //8
            4'b1001 : SEG_CA = 7'b0011000; //9
            4'b1010 : SEG_CA = 7'b0111111; //-
            4'b1011 : SEG_CA = 7'b1111111; //
            4'b1100 : SEG_CA = 7'b1000110; //C
            default : SEG_CA = 7'b1111111; //
        endcase
    end
    
    always @(posedge clk_100MHz) begin
        // Decimal_Points_Display
        case (temperature[6:3])
            4'b0000: begin //0.0000
                fourth_decimal_place <= 4'b0000; third_decimal_place  <= 4'b0000;
                second_decimal_place <= 4'b0000; first_decimal_place  <= 4'b0000; end
            4'b0001: begin //0.0625
                fourth_decimal_place <= 4'b0101; third_decimal_place  <= 4'b0010;
                second_decimal_place <= 4'b0110; first_decimal_place  <= 4'b0000; end
            4'b0010: begin //0.1250
                fourth_decimal_place <= 4'b0000; third_decimal_place  <= 4'b0101;
                second_decimal_place <= 4'b0010; first_decimal_place  <= 4'b0001; end
            4'b0011: begin //0.1875
                fourth_decimal_place <= 4'b0101; third_decimal_place  <= 4'b0111;
                second_decimal_place <= 4'b1000; first_decimal_place  <= 4'b0001; end
            4'b0100: begin //0.2500
                fourth_decimal_place <= 4'b0000; third_decimal_place  <= 4'b0000;
                second_decimal_place <= 4'b0101; first_decimal_place  <= 4'b0010; end
            4'b0101: begin //0.3125
                fourth_decimal_place <= 4'b0101; third_decimal_place  <= 4'b0010;
                second_decimal_place <= 4'b0001; first_decimal_place  <= 4'b0011; end
            4'b0110: begin //0.3750
                fourth_decimal_place <= 4'b0000; third_decimal_place  <= 4'b0101;
                second_decimal_place <= 4'b0111; first_decimal_place  <= 4'b0011; end
            4'b0111: begin //0.4375
                fourth_decimal_place <= 4'b0101; third_decimal_place  <= 4'b0111;
                second_decimal_place <= 4'b0011; first_decimal_place  <= 4'b0100; end
            4'b1000: begin //0.5000
                fourth_decimal_place <= 4'b0000; third_decimal_place  <= 4'b0000;
                second_decimal_place <= 4'b0000; first_decimal_place  <= 4'b0101; end
            4'b1001: begin //0.5625
                fourth_decimal_place <= 4'b0101; third_decimal_place  <= 4'b0010;
                second_decimal_place <= 4'b0110; first_decimal_place  <= 4'b0101; end
            4'b1010: begin //0.6250
                fourth_decimal_place <= 4'b0000; third_decimal_place  <= 4'b0101;
                second_decimal_place <= 4'b0010; first_decimal_place  <= 4'b0110; end
            4'b1011: begin //0.6875
                fourth_decimal_place <= 4'b0101; third_decimal_place  <= 4'b0111;
                second_decimal_place <= 4'b1000; first_decimal_place  <= 4'b0110; end
            4'b1100: begin //0.7500
                fourth_decimal_place <= 4'b0000; third_decimal_place  <= 4'b0000;
                second_decimal_place <= 4'b0101; first_decimal_place  <= 4'b0111; end
            4'b1101: begin //0.8125
                fourth_decimal_place <= 4'b0101; third_decimal_place  <= 4'b0010;
                second_decimal_place <= 4'b0001; first_decimal_place  <= 4'b1000; end
            4'b1110: begin //0.8750
                fourth_decimal_place <= 4'b0000; third_decimal_place  <= 4'b0101;
                second_decimal_place <= 4'b0111; first_decimal_place  <= 4'b1000; end
            4'b1111: begin //0.9375
                fourth_decimal_place <= 4'b0101; third_decimal_place  <= 4'b0111;
                second_decimal_place <= 4'b0011; first_decimal_place  <= 4'b1001; end
            default: begin //0.0000
                fourth_decimal_place <= 4'b0000; third_decimal_place  <= 4'b0000;
                second_decimal_place <= 4'b0000; first_decimal_place  <= 4'b0000; end
        endcase
        
        unit <= 4'b1100;
        //Working on the sign bit and ones, tens.
        case (temperature[15])
            1'b0: begin: POSITIVE
                sign_place <= 4'b1011;
                tens_place <= temperature[14:7] / 10;
                ones_place <= temperature[14:7] % 10; end
            1'b1: begin: NEGATIVE // Perform sign extension: 1's Complement + 1.
                sign_place <= 4'b1010;
                tens_place <= ((~temperature[14:7]) + 1) / 10;
                ones_place <= ((~temperature[14:7]) + 1) % 10; end
        endcase
    end // always
    
    // Counter for time multiplexing
    reg [17:0] segment_counter = 0;
    reg invalid;
    //reg [7:0] segment_counter = 0;
    
    always @(posedge clk_100MHz or posedge reset) begin
        if (reset) segment_counter <= 0;
        else       segment_counter <= segment_counter + 1;
    end
        
    always @(posedge clk_100MHz) begin
        case ({invalid, segment_counter[17:15]})
            4'b0000: begin current_segment <= sign_place;
                SEG_AN <= 8'b01111111;
                decimal_point <= 1'b1; end
            4'b0001: begin current_segment <= tens_place;
                SEG_AN <= 8'b10111111;
                decimal_point <= 1'b1; end
            4'b0010: begin current_segment <= ones_place;
                SEG_AN <= 8'b11011111;
                decimal_point <= 1'b0; end
            4'b0011: begin current_segment <= first_decimal_place;
                SEG_AN <= 8'b11101111;
                decimal_point <= 1'b1; end
            4'b0100: begin current_segment <= second_decimal_place;
                SEG_AN <= 8'b11110111;
                decimal_point <= 1'b1; end
            4'b0101: begin current_segment <= third_decimal_place;
                SEG_AN <= 8'b11111011;
                decimal_point <= 1'b1; end
            4'b0110: begin current_segment <= fourth_decimal_place;
                SEG_AN <= 8'b11111101;
                decimal_point <= 1'b1; end
            4'b0111: begin current_segment <= unit;
                SEG_AN <= 8'b11111110;
                decimal_point <= 1'b1; end
            4'b1000: begin current_segment <= 4'b1010;
                SEG_AN <= 8'b01111111;
                decimal_point <= 1'b1; end
            4'b1001: begin current_segment <= 4'b1010;
                SEG_AN <= 8'b10111111;
                decimal_point <= 1'b1; end
            4'b1010: begin current_segment <= 4'b1010;
                SEG_AN <= 8'b11011111;
                decimal_point <= 1'b1; end
            4'b1011: begin current_segment <= 4'b1010;
                SEG_AN <= 8'b11101111;
                decimal_point <= 1'b1; end
            4'b1100: begin current_segment <= 4'b1010;
                SEG_AN <= 8'b11110111;
                decimal_point <= 1'b1; end
            4'b1101: begin current_segment <= 4'b1010;
                SEG_AN <= 8'b11111011;
                decimal_point <= 1'b1; end
            4'b1110: begin current_segment <= 4'b1010;
                SEG_AN <= 8'b11111101;
                decimal_point <= 1'b1; end
            4'b1111: begin current_segment <= 4'b1010;
                SEG_AN <= 8'b11111110;
                decimal_point <= 1'b1; end
        endcase
    end // always
    
    // CODE TO CREATE TEMPERATURE LEVELS: RGB
    // -40c to -1 Very Low Temperature : Blue Color
    // 00 to 30 Low Temperature : Cyan Color
    // 31 to 60 Medium Temperature : Green Color
    // 61 to 99 Very High Temperature : Red Color
    
    reg [7:0] pwm_counter;
    always @(posedge clk_100MHz or posedge reset) 
    begin
        if (pwm_counter == 255 | reset) 
            pwm_counter <= 0;
        else                            
            pwm_counter <= pwm_counter + 1;
    end
        
    reg [7:0] temp_value;
    reg [2:0] color_reg;
    reg [1:0] intensity_reg;
    
    always @(posedge clk_100MHz) begin    
        color_reg <= 3'b000; // Black
        temp_value <= ((tens_place * 10) + ones_place);
        if (temperature[15]) begin: Negative_Temp
            color_reg <= 3'b001; // Blue
            if (temp_value <= 14)           intensity_reg <= 2'b01;
            else if (temp_value <= 27)      intensity_reg <= 2'b10;
            else if (temp_value <= 40)      intensity_reg <= 2'b11;
            else                            intensity_reg <= 2'b00; end            
        else begin: Positive_Temp
            if (temp_value <= 30) begin
                color_reg <= 3'b011; // Cyan
                if (temp_value <= 10)       intensity_reg <= 2'b11;
                else if (temp_value <= 20)  intensity_reg <= 2'b10;
                else                        intensity_reg <= 2'b01; end
            else if (temp_value <= 60) begin
                color_reg <= 3'b010; // Green    
                if (temp_value <= 40)       intensity_reg <= 2'b01;
                else if (temp_value <= 50)  intensity_reg <= 2'b10;
                else                        intensity_reg <= 2'b11; end
            else if (temp_value < 100) begin
                color_reg <= 3'b100; // Red
                if (temp_value <= 75)       intensity_reg <= 2'b01;
                else if (temp_value <= 90)  intensity_reg <= 2'b10;
                else                        intensity_reg <= 2'b11; end
            else begin                      intensity_reg <= 2'b00; end
        end
    end // always
        
    always @(posedge clk_100MHz) begin
        invalid <= (intensity_reg==2'b00)?1:0;
        case({reset, intensity_reg})
            3'b000: {R, G, B} <= 3'b000; // 0% Intensity, When Invalid temperature is encountered.
            3'b001: {R, G, B} <= (pwm_counter < 50)? color_reg : 3'b000; // Approx 20% Intensity
            3'b010: {R, G, B} <= (pwm_counter < 150)? color_reg : 3'b000; // Approx 60% Intensity
            3'b011: {R, G, B} <= color_reg; // 100% Intensity
            default: {R, G, B} <= 3'b000;
        endcase
    end // always
    
    assign temperature = (sensor)? temp_data_I2C : {temp_data_switch, 3'b000};
    assign Temp_LED = temperature[15:3];
    assign Sensor_LED = sensor;
    assign Reset_LED = reset;

endmodule