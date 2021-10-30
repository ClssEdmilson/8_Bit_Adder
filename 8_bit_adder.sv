`timescale 1ns/1ps

module 8_bit_adder (
    input [7:0] a,b,
    output [8:0] y
);

assign y = a + b;

endmodule