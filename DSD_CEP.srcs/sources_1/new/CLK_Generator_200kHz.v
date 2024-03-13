`timescale 1ns / 1ps

// Create Date: 01/03/2024 03:44:49 PM
// Module Name: clkgen_200kHz
// Project Name: CEP
// Description: This Verilog module, clkgen_200kHz, acts as a clock divider, transforming a 100 MHz input clock 100MHz into a 200 kHz output clock.

module CLK_Generator_200kHz(
        input reset,
        input clk_100MHz,
        output clk_200kHz
    );
    
    // 100 x 10^6 / 200 x 10^3 / 2 = 250 <-- 8 bit counter    
    reg [7:0] counter = 8'h00;
    reg clk_reg = 1'b1;
        
    always @(posedge clk_100MHz or posedge reset) 
    begin
        if(counter == 249 | reset) begin
            counter <= 8'h00;
            clk_reg <= ~clk_reg;
        end else
            counter <= counter + 1;
    end // always
       
    assign clk_200kHz = clk_reg;
    
endmodule


