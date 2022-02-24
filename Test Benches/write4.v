`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:16:25 12/21/2020
// Design Name:   PCI_Slave
// Module Name:   E:/Verlilog Projects/PCI/tee.v
// Project Name:  PCI
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: PCI_Slave
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module write4;

	//inout
	wire [31:0] AD;
	assign AD = (IRDY == 1 || cbuffer != 4'b0010 ) ? din:32'bz;


	// Inputs
	reg [3:0] CBE;
	reg FRAME;
	wire TRDY;
	reg IRDY;
	wire DEVSEL;
	reg RST;
	wire CLK;
	reg [31:0] din;	//for write in AD
	
	//SAVE THE COMMAND
	reg [3:0] cbuffer;
	always@(negedge IRDY)
		begin
			cbuffer = CBE;
		end	
		

	// Instantiate the Unit Under Test (UUT)
	PCI_Slave uut (
		.AD(AD),
		.CBE(CBE), 
		.FRAME(FRAME),
		.TRDY(TRDY), 
		.IRDY(IRDY),
		.DEVSEL(DEVSEL),
		.CLK(CLK), 
		.RST(RST)
		/*
		.test(test),
		.i(i)
		*/
	);

	initial begin
		//WRITE
		RST = 1;
		#50
		RST = 0;
		#50
		RST = 1;
		CBE = 0;
		FRAME = 1;
		IRDY = 1'b1;
		din = 51656;
		#100
		CBE = 4'b0011;
		FRAME = 0;
		IRDY = 1'b1;
		din = 51655;
		#100
		IRDY = 1'b0;
		#100
		din = 32'b10011001100110011001100110011001;
		CBE = 4'b1101;
		#500
		FRAME = 1;
		//READ
		#150
		CBE = 4'b0010;
		FRAME = 0;
		IRDY = 1'b1;
		din = 51653;
		#100
		CBE = 4'b0010;
		FRAME = 0;
		IRDY = 1'b1;
		din = 51653;
		#100
		IRDY = 1'b0;
		#600
		FRAME = 0;

	end
	
	

endmodule

