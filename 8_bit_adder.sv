`timescale 1ns/1ps

//module
module adder_8Bit(
    input [7:0] a,b,
    output [8:0] y
);

assign y = a + b;

endmodule

//Test

//Transaction class
class transaction;
    randc bit [7:0] a,b;
    bit [8:0] y;
endclass //transaction

