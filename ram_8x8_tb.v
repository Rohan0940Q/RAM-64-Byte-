`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 19:10:29
// Design Name: 
// Module Name: ram_8x8_tb
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


module ram_64x8_tb(
    

    );
     reg [7:0] data;
     reg [5:0] rd_addr;
     reg [5:0] wr_addr;
     reg we,clk;
     
     wire [7:0] q;
     
     ram_64x8 ram1(q,data,rd_addr,wr_addr,we,clk);
     
     initial begin
        $monitor("Time=%0t clk=%b we=%b wr_addr=%d rd_addr=%d data=%b q=%b",
                $time, clk, we, wr_addr, rd_addr, data, q);
     end
     
     always
        #5 clk=~clk;              // the time period of clock is set 10ns
        
        initial begin

        clk = 0;                 // Initialize inputs
        we = 0;
        data = 8'b00000000;
        rd_addr = 0;
        wr_addr = 0;

        
        #10;                      // data AA is written in RAM
                         
        we = 1;
        wr_addr = 6'd5;
        data = 8'b10101010;

        #10;                    // considering only read operation after 10ns
 
        we = 0;
        rd_addr = 6'd5;

        #10                     //data F0 is written in memory
                          
        we = 1;
        wr_addr = 6'd10;
        data = 8'b11110000;

        #10;                    //only the read operation on the previous address

        we = 0;
        rd_addr = 6'd10;

        #10;

        $finish;

    end
     
     
endmodule
