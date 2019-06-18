`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module chardisp
	(
	/*AXI4-Lite signal*/
	input CLK, RST,
	input [15:0] WRADDR,
	input [3:0] BYTEEN,
	input WREN,
	input [31:0] WRDATA,
	input [15:0] RDADDR,
	input RDEN,
	output [31:0] RDDATA,

	/*VGA out*/
	output [3:0] VGA_R,
	output [3:0] VGA_G,
	output [3:0] VGA_B,
	output VGA_HS, VGA_VS
	);

	/*VGA(640*480)parmeter RD*/
	`include "vga_param.vh"

	wire [9:0] HCNT;
	wire [9:0] VCNT;
	wire PCK;

	/*syncgen connection*/
	syncgen syncgen(
	   .CLK(CLK),
	   .RST(RST),
	   .PCK(PCK),
	   .VGA_HS(VGA_HS),
	   .VGA_VS(VGA_VS),
	   .HCNT(HCNT),
	   .VCNT(VCNT)
	);

	/*Change count value*/
	wire [9:0] iHCNT = HCNT - HFRONT - HWIDTH - HBACK + 10'd8;
	wire [9:0] iVCNT = VCNT - VFRONT - VWIDTH - VBACK - 10'd40;

	/*VRAM connection signal*/
	wire [23:0] vramout;
	wire [11:0] addra;
	wire [11:0] vramaddr;

	assign addra = (RDEN) ? RDADDR[13:2]: WRADDR[13:2];
	assign RDDATA[31:24] = 8'h00;
	wire [2:0] wea = {3{WREN}} & BYTEEN[2:0];

	/*VRAM connection*/
	VRAM VRAM(
	   .clka(CLK),
	   .wea(wea),
	   .addra(addra),
	   .dina(WRDATA[23:0]),
	   .douta(RDDATA[23:0]),
	   .clkb(PCK),
	   .web(3'b0),
	   .addrb(vramaddr),
	   .dinb(24'b0),
	   .doutb(vramout)
	 );

	 wire [2:0] vdotcnt;
	 wire [2:0] cgout;
	 
	 /*CGROM connection*/
	 CGROM CGROM(
	   .addra({vramout[6:0],vdotcnt}),
	   .douta(cgout),
	   .clka(PCK)
	 );

	 /*Divide HCN and VCNT as character and dot counters*/
	 wire [6:0] hchacnt = iHCNT[9:3];
	 wire [6:0] hdotcnt = iHCNT[2:0];
	 wire [5:0] vchacnt = iVCNT[8:3];
	 assign vdotcnt = iVCNT[2:0];

	 /*Generate VRAM address vramaddr <- vchacnt * 80 + hchacnt*/
	 assign vramaddr = (vchacnt<<6) + (vchacnt<<4) + hchacnt;

	 /*Shift register*/
	 reg [7:0] sreg;
	 wire sregld = (hdotcnt==3'h6 && iHCNT<10'd640);

	 always@(posedge PCK) begin
	   if(RST)
	       sreg <= 8'h00;
	   else if(sregld)
	       sreg <= cgout;
	   else
	       sreg <= {sreg[6:0], 1'b0};
	   end

	   /*Capture color information simultaneously with sreg LD*/
	   reg [11:0] color;

	   always@(posedge PCK) begin
	       if(RST)
	           color <= 12'h000;
	       else if(sregld)
	           color <= vramout[19:8];
	   end

	   /*Horizontal, vertical display enable signal*/
	   wire hdispen = (10'd7 <= iHCNT && iHCNT<10'd647);
	   wire vdispen = (iVCNT < 9'd400);

	   /*Generate RGB output signal*/
	   reg [11:0] vga_rgb;

	   always@(posedge PCK) begin
	       if(RST)
	           vga_rgb <= 12'h0000;
	       else
	           vga_rgb <= color & {12{hdispen & vdispen & sreg[7]}};
	   end

	   assign VGA_R = vga_rgb[11:8];
	   assign VGA_G = vga_rgb[7:4];
	   assign VGA_B = vga_rgb[3:0];

	   endmodule
