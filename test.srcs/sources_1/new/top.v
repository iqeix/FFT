`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/10/29 21:52:08
// Design Name: 
// Module Name: top
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


module top(clk_sys,NRESET);
input       clk_sys;
input       NRESET;
wire        nrst;
wire        wr_clk;
wire        rd_clk;
wire[7:0]   din;
wire        wr_en;
wire        rd_en;
wire        empty;
//wire        valid;
wire        wr_rst_busy;
wire        rd_rst_busy;
wire        clk_1s;
wire        clk_50;
wire        clk_100;
wire        locked;
wire[7:0]   dout;
wire        full;

assign  nrst=NRESET;
assign  wr_clk=clk_50;
assign  rd_clk=clk_100;
wire xn_r;
wire xn_i;
wire RST;
wire CLK;
wire START;
//wire OUT;
wire Xk_r;
wire Xk_i;
wire OUT;

//----------------------
reg[7:0]    data='d0;
always @(posedge clk_sys or negedge NRESET) begin
    if (NRESET) data<='d0;
    else data<=data+'d1;
end
assign din=data;
//----------------------

clk_1s ini(
    .clk(clk_sys),
    .clr(nrst),
    .clk_1s(clk_1s)
    );
FFT uut (
    .xn_r(xn_r), 
    .xn_i(xn_i),
    .RST(RST),
    .CLK(CLK),
    .START(START),
    .OUT(START),
    .Xk_r(Xk_r),
    .Xk_i(Xk_i),
    .OUT(OUT));

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
fifo_generator_0 your_instance_name (
  .rst(nrst),                  // input wire rst
  .wr_clk(wr_clk),            // input wire wr_clk
  .rd_clk(rd_clk),            // input wire rd_clk
  .din(rd_clk),               // input wire [7 : 0] din
  .wr_en(wr_en),              // input wire wr_en
  .rd_en(rd_en),              // input wire rd_en
  .dout(dout),                // output wire [7 : 0] dout
  .full(full),                // output wire full
  .empty(empty),              // output wire empty
  .wr_rst_busy(wr_rst_busy),  // output wire wr_rst_busy
  .rd_rst_busy(rd_rst_busy)  // output wire rd_rst_busy
);
// INST_TAG_END ------ End INSTANTIATION Template ---------

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG

  clk_wiz_0 instance_name
   (
    // Clock out ports
    .clk_out1(clk_50),     // output clk_out1
    .clk_out2(clk_100),     // output clk_out2
   // Clock in ports
    .clk_in1(clk_sys));      // input clk_in1
// INST_TAG_END ------ End INSTANTIATION Template ---------

endmodule
