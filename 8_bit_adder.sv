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

//Interface
interface adder_8Bit_intf();
    logic [7:0] a,b;
    logic [8:0] y;   
endinterface //adder_8Bit_intf

//Driver class
class driver;
    transaction t;
    mailbox mbx;
    virtual adder_8Bit_intf vif;

    function new(mailbox mbx);
        this.mbx = mbx;
    endfunction //new()

    task run();
        t = new();
        forever begin
            mbx.get(t);
            vif.a = t.a;
            vif.b = t.b;
            $display(" [ DRV ] - Interface is OK.");
            ->done;
            #10;
        end
    endtask 
endclass //driver

//monitor class
class monitor;
    transaction t;
    mailbox mbx;
    virtual adder_8Bit_intf vif;

    function new(mailbox mbx);
        this.mbx = mbx;
    endfunction //new()

    task run();
        t = new();
        forever begin
            t.a = vif.a;
            t.b = vif.b;
            mbx.put(t);
            $display(" [ MON ] - Monitor OK.");
            #10;
        end
    endtask 
endclass //monitor


