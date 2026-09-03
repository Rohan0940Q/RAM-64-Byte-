`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 18:46:30
// Design Name: 
// Module Name: ram_64x8
// Project Name:  Single Port RAM [Non-blocking]
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


module ram_64x8(         // single port RAM  ( one read and write operation available)
output reg [7:0] q,
input [7:0] data, //  1 byte data
input [5:0] rd_addr, wr_addr,
input we,clk

    );
    reg [7:0] ram [63:0]; //64 byte memory
    
    always@(posedge clk)
    begin
        if(we)
            ram[wr_addr]<=data;
            q<=ram[rd_addr];  //read the old data from ram simultaneously
            
    end
endmodule
    
    
    
    

