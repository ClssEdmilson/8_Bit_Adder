`timescale 1ns/1ps

//module
module adder(
    input [7:0] a,b,
    output [8:0] y
);

assign y = a + b;

endmodule

//Test

//Transaction class
class transaction;
    randc bit [7:0] a;
    randc bit [7:0] b;
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
        for ( i = 0; i < 25; i++) begin
            t.randomize();
            mbx.put(t);
            $display(" [ GEN ] - Generator send the data.");
            @(done);
            #10;
        end
    endtask 
endclass //generator

//Interface
interface adder_intf();
    logic [7:0] a,b;
    logic [8:0] y;   
endinterface //adder_intf

//Driver class
class driver;
    transaction t;
    mailbox mbx;
    event done;
    virtual adder_intf vif;

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
    virtual adder_intf vif;

    function new(mailbox mbx);
        this.mbx = mbx;
    endfunction //new()

    task run();
        t = new();
        forever begin
            t.a = vif.a;
            t.b = vif.b;
            t.y = vif.y;
            mbx.put(t);
            $display(" [ MON ] - Monitor OK.");
            #10;
        end
    endtask 
endclass //monitor

//class scoreboard
class scoreboard;
    transaction t;
    mailbox mbx;
    bit [8:0] temp;

    function new(mailbox mbx);
        this.mbx = mbx;
    endfunction //new()

    task run();
        t = new();
        forever begin
            mbx.get(t);
            temp = t.a + t.b;

            if(t.y == temp) begin
                $display("[SCO] - Test Passed!");
            end
            else begin
                $display("[SCO] - Test Fail!");
            end
            #10;
        end
    endtask 
endclass //scoreboard

//Environment class
class environment;
    generator gen;
    driver drv;
    monitor mon;
    scoreboard sco;
    mailbox gdmbx, msmbx;
    event gddone;

    virtual adder_intf vif;

    function new(mailbox gdmbx, mailbox msmbx);
        this.gdmbx = gdmbx;
        this.msmbx = msmbx;

        gen = new(gdmbx);
        drv = new(gdmbx);

        mon = new(msmbx);
        sco = new(msmbx);
    endfunction //new()

    task run();

        drv.vif = vif;
        mon.vif = vif;

        gen.done = gddone;
        drv.done = gddone;
        
        fork
            gen.run();
            drv.run();
            mon.run();
            sco.run();
        join_any 
    endtask 
endclass //Environment

//Module tb
module tb();
    environment env;
    mailbox gdmbx, msmbx;
    adder_intf vif();

    adder dut (vif.a, vif.b, vif.y);

    initial begin
        gdmbx = new();
        msmbx = new();
        env = new(gdmbx,msmbx);
        env.vif = vif;
        env.run();
        #500;
        $finish;
    end
endmodule