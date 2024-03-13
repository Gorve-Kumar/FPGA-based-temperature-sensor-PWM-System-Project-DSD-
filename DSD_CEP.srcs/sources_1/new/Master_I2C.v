`timescale 1ns / 1ps

// CEP: GORVE KUMAR (CS-20125), MALAIKA ALI (CS-20019), SYED MUHAMMAD (CS-20015), FARAH HUSSAIN (CS-20003)
// Create Date: 01/03/2024 03:46:20 PM
// Module Name: i2c_master
// Project Name: CEP
// Description: The I2C module acts as a master controller for I2C communication, utilizing a 10 kHz clock generated from a 200 kHz input clock. It incorporates a 28-state FSM, allowing communication with slave.

module Master_I2C(
        input clk_200kHz,
        input reset,
        inout TEMP_SDA,                // i2c standard interface signal
        output TEMP_SCL,               // i2c standard interface signal - 10KHZ (SLOW CLOCK)
        output [15:0] temp_data        // 8 bits binary representation of deg C
    );
        
    wire SDA_dir; // direction of inout signal on SDA - to/from master 
    // *** GENERATE 10kHz SCL clock from 200kHz *** EVEN MORE SLOW CLOCK
    // 200 x 10^3 / 10 x 10^3 / 2 = 10
    reg [3:0] counter = 4'b0;  // count up to 9
    reg clk_reg = 1'b1; 
    
    always @(posedge clk_200kHz or posedge reset)
        if(reset) begin
            counter <= 4'b0;
            clk_reg <= 1'b0;
        end else begin 
            if(counter == 9) begin
                counter <= 4'b0;    // toggle reg
                clk_reg <= ~clk_reg; 
        end else
            counter <= counter + 1;
    end 
            
    // Set value of i2c SCL signal to the sensor - 10kHz            
    assign TEMP_SCL = clk_reg;   
    // **************************************************************************************************

    // Signal Declarations               
    parameter [7:0] sensor_address_plus_read = 8'b1001_0111;    // 0x97 (4B + Read(1)/Write(0))
    reg [7:0] temperature_MSB = 8'b0;                           // Temperature data MSB
    reg [7:0] temperature_LSB = 8'b0;                           // Temperature data LSB
    reg output_bit = 1'b1;                                      // output bit to SDA - starts HIGH
    wire input_bit;
    reg [11:0] count = 12'b0;                                   // State Machine Synchronizing Counter
    reg [15:0] temp_data_reg;		

    // State Declarations - need 28 states - (5 bits as we have 28 states)
    localparam [4:0] POWER_UP   = 5'h00, //00000
                     START      = 5'h01,
                     SEND_ADDR6 = 5'h02,
					 SEND_ADDR5 = 5'h03,
					 SEND_ADDR4 = 5'h04,
					 SEND_ADDR3 = 5'h05,
					 SEND_ADDR2 = 5'h06,
					 SEND_ADDR1 = 5'h07,
					 SEND_ADDR0 = 5'h08,
					 SEND_RW    = 5'h09,
                     REC_ACK    = 5'h0A,
                     REC_MSB7   = 5'h0B,
					 REC_MSB6	= 5'h0C,
					 REC_MSB5	= 5'h0D,
					 REC_MSB4	= 5'h0E,
					 REC_MSB3	= 5'h0F,
					 REC_MSB2	= 5'h10,
					 REC_MSB1	= 5'h11,
					 REC_MSB0	= 5'h12,
                     SEND_ACK   = 5'h13,
                     REC_LSB7   = 5'h14,
					 REC_LSB6	= 5'h15,
					 REC_LSB5	= 5'h16,
					 REC_LSB4	= 5'h17,
					 REC_LSB3	= 5'h18,
					 REC_LSB2	= 5'h19,
					 REC_LSB1	= 5'h1A,
					 REC_LSB0	= 5'h1B,
                     NACK       = 5'h1C; // 11100
      
    reg [4:0] state_reg = POWER_UP; // state register
                       
    always @(posedge clk_200kHz or posedge reset) begin
        if(reset) begin
            state_reg <= START;
			count <= 12'd2000;
        end else begin
			count <= count + 1;
            case(state_reg)
                POWER_UP   : begin
                                 if(count == 12'd1999)
                                    state_reg <= START; 
                             end
                START      : begin
                                 if(count == 12'd2004)
                                    output_bit <= 1'b0; // send START condition 1/4 clock after SCL goes high    
                                 if(count == 12'd2013)  
                                    state_reg <= SEND_ADDR6;   
                             end
                SEND_ADDR6 : begin
                                 output_bit <= sensor_address_plus_read[7];
                                 if(count == 12'd2033)  
                                    state_reg <= SEND_ADDR5; 
                             end
				SEND_ADDR5 : begin
                                 output_bit <= sensor_address_plus_read[6];
                                 if(count == 12'd2053)  
                                    state_reg <= SEND_ADDR4; 
                             end
				SEND_ADDR4 : begin
                                 output_bit <= sensor_address_plus_read[5];
                                 if(count == 12'd2073)  
                                    state_reg <= SEND_ADDR3; 
                             end
				SEND_ADDR3 : begin
                                 output_bit <= sensor_address_plus_read[4];
                                 if(count == 12'd2093)  
                                    state_reg <= SEND_ADDR2; 
                             end
				SEND_ADDR2 : begin
                                 output_bit <= sensor_address_plus_read[3];
                                 if(count == 12'd2113)  
                                    state_reg <= SEND_ADDR1; 
                             end
				SEND_ADDR1 : begin
                                 output_bit <= sensor_address_plus_read[2];
                                 if(count == 12'd2133)  
                                    state_reg <= SEND_ADDR0; 
                             end
				SEND_ADDR0 : begin
                                 output_bit <= sensor_address_plus_read[1];
                                 if(count == 12'd2153)  
                                    state_reg <= SEND_RW;  // After sending 7 bits address to slave, we want to tell that we want to read.
                             end
				SEND_RW    : begin
                                 output_bit <= sensor_address_plus_read[0];
                                 if(count == 12'd2169)  
                                    state_reg <= REC_ACK;  // Now, master is waiting to receive acknowledgement from slave. // we assume that its happening.
                             end
                REC_ACK    : begin
                                 if(count == 12'd2189)  
                                    state_reg <= REC_MSB7; 
                             end
                REC_MSB7   : begin
                                 temperature_MSB[7] <= input_bit; // master takes in from its input pin.
                                 if(count == 12'd2209)  
                                    state_reg <= REC_MSB6; 
                             end
				REC_MSB6   : begin
                                 temperature_MSB[6] <= input_bit;
                                 if(count == 12'd2229)  
                                    state_reg <= REC_MSB5; 
                             end
				REC_MSB5   : begin
                                 temperature_MSB[5] <= input_bit;
                                 if(count == 12'd2249)  
                                    state_reg <= REC_MSB4; 
                             end
				REC_MSB4   : begin
                                 temperature_MSB[4] <= input_bit;
                                 if(count == 12'd2269)  
                                    state_reg <= REC_MSB3; 
                             end
				REC_MSB3   : begin
                                 temperature_MSB[3] <= input_bit;
                                 if(count == 12'd2289)  
                                    state_reg <= REC_MSB2; 
                             end
				REC_MSB2   : begin
                                 temperature_MSB[2] <= input_bit;
                                 if(count == 12'd2309)  
                                    state_reg <= REC_MSB1; 
                             end
				REC_MSB1   : begin
                                 temperature_MSB[1] <= input_bit;
                                 if(count == 12'd2329)  
                                    state_reg <= REC_MSB0; 
                             end
				REC_MSB0   : begin
                                 output_bit <= 1'b0; // To tell slave device that we have successfully received MSB byte, so that it can start sending LSB byte.
                                 temperature_MSB[0] <= input_bit;
                                 if(count == 12'd2349)  
                                    state_reg <= SEND_ACK; // master says that I receive first byte sucessfully.
                             end
                SEND_ACK   : begin
                                 if(count == 12'd2369)  
                                    state_reg <= REC_LSB7; 
                             end
                REC_LSB7   : begin
                                 temperature_LSB[7] <= input_bit;
                                 if(count == 12'd2389)  
                                    state_reg <= REC_LSB6; 
                             end
                REC_LSB6   : begin
                                 temperature_LSB[6] <= input_bit;
                                 if(count == 12'd2409)  
                                    state_reg <= REC_LSB5; 
                             end
				REC_LSB5   : begin
                                 temperature_LSB[5] <= input_bit;
                                 if(count == 12'd2429)  
                                    state_reg <= REC_LSB4; 
                             end
				REC_LSB4   : begin
                                 temperature_LSB[4] <= input_bit;
                                 if(count == 12'd2449)  
                                    state_reg <= REC_LSB3; 
                             end
				REC_LSB3   : begin
                                 temperature_LSB[3] <= input_bit;
                                 if(count == 12'd2469)  
                                    state_reg <= REC_LSB2; 
                             end
				REC_LSB2   : begin
                                 temperature_LSB[2] <= input_bit;
                                 if(count == 12'd2489)  
                                    state_reg <= REC_LSB1; 
                             end
				REC_LSB1   : begin
                                 temperature_LSB[1] <= input_bit;
                                 if(count == 12'd2509)  
                                    state_reg <= REC_LSB0; 
                             end
				REC_LSB0   : begin
                                 output_bit <= 1'b1; 
                                 // So, that slave device can stop communication, we received both byte.
                                 temperature_LSB[0] <= input_bit;
                                 if(count == 12'd2529)  
                                    state_reg <= NACK;
                             end    
                NACK       : begin
                                 if(count == 12'd2559) begin
                                        count <= 12'd2000; // Restart
                                        state_reg <= START; 
                                     end
                             end
            endcase     
        end
    end       
    
    // Buffer for temperature data
    always @(posedge clk_200kHz) begin
        if(state_reg == NACK) // We received successfully.
            temp_data_reg <= { temperature_MSB[7:0], temperature_LSB[7:0] };
    end  
    
    // Control direction of SDA bidirectional inout signal from master to slave.
    assign SDA_dir = (state_reg == POWER_UP   || 
                      state_reg == START      || 
                      state_reg == SEND_ADDR6 || 
                      state_reg == SEND_ADDR5 ||
					  state_reg == SEND_ADDR4 || 
					  state_reg == SEND_ADDR3 || 
					  state_reg == SEND_ADDR2 || 
					  state_reg == SEND_ADDR1 ||
                      state_reg == SEND_ADDR0 || 
                      state_reg == SEND_RW    || 
                      state_reg == SEND_ACK   || 
                      state_reg == NACK)? 1 : 0;
                      
    // Set the value of SDA for output - from master to sensor
    assign TEMP_SDA = SDA_dir ? output_bit : 1'bz;
    // If slave wants to place something on SDA, then master releases SDA by placing high impedance on it, allowing slave to use it accordingly.
    // Set value of input wire when SDA is used as an input - from slave to master
    assign input_bit = TEMP_SDA;
    assign temp_data = temp_data_reg;
 
endmodule