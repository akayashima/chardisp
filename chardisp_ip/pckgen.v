`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/10 18:46:03
// Design Name: 
// Module Name: pckgen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pckgen(
    input SYSCLK,
    output PCK
    );
    
wire CLKFBOUT, iPCK, locked;
BUFG iBUFG(.I(iPCK), .O(PCK));

MMCME2_BASE #(
    .CLKFBOUT_MULT_F(25.0),
    .CLKIN1_PERIOD(8.0),
    .CLKOUT0_DIVIDE_F(25.0),
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT0_PHASE(0.0),
    .DIVCLK_DIVIDE(5)
)

MMCM2_BASE_inst(
    .CLKOUT0(iPCK),
    .CLKFBOUT(CLKFBOUT),
    .LOCKED(locked),
    .CLKIN1(SYSCLK),
    .CLKFBIN(CLKFBOUT)
);
endmodule
