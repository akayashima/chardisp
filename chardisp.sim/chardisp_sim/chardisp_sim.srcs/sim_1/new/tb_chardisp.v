`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/16 16:14:30
// Design Name: 
// Module Name: tb_chardisp
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
module tb_chardisp;

/*Define clock period and Sim clock number*/
localparam STEP = 10;
localparam CLKNUM = (800*525+12000)*5;

/*Declaration of connection signal*/
reg CLK,RST;
reg [15:0] RDADDR;
reg [15:0] WRADDR;
reg [3:0] BYTEEN;
reg WREN, RDEN;
reg [31:0] WRDATA;
wire [31:0] RDDATA;
wire [3:0] VGA_R;
wire [3:0] VGA_G;
wire [3:0] VGA_B;
wire VGA_HS, VGA_VS;

/*Connection of character display circuit body*/
chardisp chardisp(
    .CLK(CLK),
    .RST(RST),
    .WRADDR(WRADDDR),
    .BYTEEN(BYTEEN),
    .WREN(WREN),
    .RDADDR(RDADDR),
    .RDEN(RDEN),
    .RDDATA(RDDATA),
    .VGA_R(VGA_R),
    .VGA_G(VGA_G),
    .VGA_B(VGA_B),
    .VGA_HS(VGA_HS),
    .VGA_VS(VGA_VS)
);

/*Cloc generate*/
always begin
    CLK = 0; #(STEP/2);
    CLK = 1; #(STEP/2);
end
    
/*Task to write to VRAM*/
task write_vram;
    input [15:0] wraddr;
    input [3:0] byteen;
    input [23:0] wrdata;
begin
    WRADDR = wraddr;
    BYTEEN = byteen;
    WRDATA = wrdata;
    WREN = 1;
    #STEP;
    WREN = 0;
    #STEP;
end
endtask

/*Various variables*/
integer fd,i;

/*Create input to validate*/
initial begin
    RST = 0; WRADDR = 0; BYTEEN = 0; WRDATA = 0; WREN = 0;
    RDADDR = 0; RDEN = 0;
    fd = $fopen("imagedata.raw","wb");
    #(STEP*500) RST = 1;
    #(STEP*10) RST = 0;
    /*Write each character in each color in VRAM*/
    for(i=0; i<4000; i=i+1)
        write_vram(i<<2, 4'hf, (i<<8) | (8'hff & i));
    #(STEP*CLKNUM);
    $fclose(fd);
    $stop;
end

/*Parameter reading for VGA(640*480)*/
`include "vga_param.vh"

/*Video output expiration data*/
wire fileouten = (HFRONT + HWIDTH + HBACK <= chardisp.syncgen.HCNT) && (VFRONT + VWIDTH + VBACK <= chardisp.syncgen.VCNT);

/*File output*/
always @(posedge chardisp.PCK) begin
    if(fileouten) begin
        $fwrite(fd,"%c",{VGA_R,4'h0});
        $fwrite(fd,"%c",{VGA_G,4'h0});
        $fwrite(fd,"%c",{VGA_B,4'h0});
    end
end

endmodule