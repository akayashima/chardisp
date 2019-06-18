module syncgen(
    input CLK,
    input RST,
    output PCK,
    output reg VGA_HS,
    output reg VGA_VS,
    output reg [9:0] HCNT,
    output reg [9:0] VCNT
);

/*VGA(640*480) parameter*/
`include "vga_param.vh"

/*connect MMCM to genetrate PCK*/
pckgen pckgen( .SYSCLK(CLK), .PCK(PCK));

/*Horizontal counter*/
wire hcntend = (HCNT==HPERIOD-10'h001);

always@ (posedge PCK) begin
    if(RST)
        HCNT <= 10'h000;
    else if(hcntend)
        HCNT <= 10'h000;
    else
        HCNT <= HCNT + 10'h001;
end

/*Vertical counter*/
always@(posedge PCK) begin
    if(RST)
        VCNT <= 10'h000;
    else if(hcntend) begin
        if(VCNT == VPERIOD - 10'h001)
            VCNT <= 10'h000;
        else
            VCNT <= VCNT + 10'h001;
    end
end

/*sync singnal*/
wire [9:0] hsstart = HFRONT - 10'h001;
wire [9:0] hsend = HFRONT + HWIDTH - 10'h001;
wire [9:0] vsstart = VFRONT;
wire [9:0] vsend = VFRONT + VWIDTH;

always@(posedge PCK) begin
    if(RST)
        VGA_HS <= 1'b1;
    else if(HCNT==hsstart)
        VGA_HS <= 1'b0;
    else if(HCNT==hsend)
        VGA_HS <= 1'b1;
end

always@(posedge PCK) begin
    if(RST)
        VGA_VS <= 1'b1;
    else if(HCNT==hsstart) begin
        if(VCNT==vsstart)
            VGA_VS <= 1'b0;
        else if(VCNT==vsend)
            VGA_VS <= 1'b1;
    end
end

endmodule