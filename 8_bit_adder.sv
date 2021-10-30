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

//Generator class
class generator;
    mailbox mbx;
    event done;
    transaction t;
    integer i;    

    function new(mailbox mbx);
        this.mbx = mbx;
    endfunction //new()

    task run();
        t = new();
        for ( i = 0; i < 50; i++) begin
            t.randomize();
            mbx.put(t);
            $display(" [ GEN ] - Generator send the data.");
            @(done);
        end
    endtask 
endclass //generator