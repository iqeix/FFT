`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/10/29 22:06:05
// Design Name: 
// Module Name: clk_1s
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


module clk_1s(clk,clr,clk_1s);
input   clk;//1kHz
input   clr;
output  clk_1s;

reg[11:0]   cnt='d0;
reg         clk_out='d0;
assign      clk_1s=clk_out;
//cnt signal
always @(posedge clk) begin
    if (clr=='b0||cnt=='d999) begin
        cnt<=12'b0;
    end
    else begin
        cnt<=cnt+1'b1;
    end
end
//clk
always@(posedge clk) begin
    if (cnt=='d999) begin
        clk_out<=~clk_out;
    end
    else begin
        clk_out<=clk_out;
    end
end

endmodule
