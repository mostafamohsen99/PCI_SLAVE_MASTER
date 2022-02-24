`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:40:11 12/21/2020 
// Design Name: 
// Module Name:    PCI-Slave 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module PCI_Slave(
//Address & data
inout [31:00] AD,
input [3:0]CBE,
//Interface Control
input FRAME,
output reg TRDY,
input IRDY,
output reg DEVSEL,
//System
input CLK,
input RST
					);

//Clock Generator
clockGen c1(CLK);

//Commands Parameters 
parameter [3:0] READ_CMD = 4'b0010;
parameter [3:0] WRITE_CMD = 4'b0011;

//Memory
reg [31:0] mem [51653:51656];
reg [31:0] stack [0:100];
initial $readmemb("ex.mem", mem);

//States Parameters
reg [2:0] state;

parameter [2:0] IDLE = 3'b000;
parameter [2:0] READY = 3'b111;
parameter [2:0] READ= 3'b001;
parameter [2:0] PREWRITE= 3'b101;
parameter [2:0] WRITE= 3'b010;
parameter [2:0] STACK=3'b011;
parameter [2:0] END= 3'b100;

//Variables
reg [2:0] i = 0;
reg [2:0] j = 0;
reg [2:0] k = 0;
reg [2:0] b = 0;

//Buffers
reg [31:0] address;
reg [3:0]  command;


														//RESET\\
always @(negedge CLK or posedge RST)
begin
	if(!RST || FRAME)
	begin 
		state = IDLE;
	end
end
														//STATES\\
always @(negedge CLK)
begin
case(state)
	IDLE:
										//WAIT FOR FRAME SIGNAL\\
			begin
			i = 0;
			j = 0;
				if (!FRAME)
					begin
					address <= AD;
					command <= CBE;
	
					state = READY;
				end
				DEVSEL = 1;
				TRDY = 1;
			end
	READY: 					   	//CHECK THE ADDRESS AND GET THE COMMAND\\
			begin
			if(address >= 51653 && address <= 51656)

			begin
			if(command == READ_CMD && IRDY == 0 )
				begin
					state = READ;
				end
			if(command == WRITE_CMD && IRDY == 0 )
				begin
					state = PREWRITE;
				end
			end
		end
	READ:								//READ THE DATA FROM TARGET MEMORY\\
			begin
				DEVSEL = 0;
				TRDY = 0;
				i = i + 1;
				if ( address + i  ==  51656 + 2) 
				begin
				i = 0 ;
				state = END;
				end
			end
	PREWRITE:				//BEFORE WRITE ON MEM TRANSFER THE EXISTED DATA\\
				begin
				DEVSEL = 0;
				TRDY = 0;
				
				if ( j == 0 )
				begin
				state = STACK;
				end
				else
				begin
				state = WRITE;
				end
			end
	STACK:						//TRANSFERING THE EXISTED DATA\\
			begin
				TRDY = 1;
				stack[b+j] = mem[address+j];
				j = j + 1;
				b = b + 1;
				if ( j == 3 )
				begin
				j = 0;
				state = WRITE;
				end
			end
			
	WRITE:						//WRITING ON DEVICE MEMORY\\
			begin		
				DEVSEL = 0;
				TRDY = 0;
				
				if(CBE[0]==1'b1)
				begin
				mem[address+k][7:0] = AD[7:0];
				end
				
				if(CBE[1]==1'b1)
				begin
				mem[address+k][15:8] = AD[15:8];
				end
				
				if(CBE[2]==1'b1)
				begin
				mem[address+k][23:16] = AD[23:16];
				end
				
				if(CBE[3]==1'b1)
				begin
				mem[address+k][31:24] = AD[31:24];
				end
	
				k = k + 1;
				if ( address + k  ==  51656 + 1) 
				begin
				k = 0 ;
				state = END;
				end
			end
	END:							//END THE OPERATION\\
			begin
				j = 0;
				DEVSEL = 1;
				TRDY = 1;
				state = IDLE;
			end
	endcase
end
				assign AD = (state == READ && !TRDY) ? mem[address-1+i] : 32'bZ;
				
endmodule
