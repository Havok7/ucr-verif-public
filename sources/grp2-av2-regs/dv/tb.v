//////////////////////////////////////////////////////////////////////////////////
//
// melvin.alvarado
// may 2021
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module tb();


    reg clk;
    reg reset_L;

    reg [31:0] write_val, read_val;
    reg [3:0]  addr;
    reg req, rd_wr, ack;

    reg [1:0] cfg_ctrl_err;
    reg [1:0] cfg_ctrl_idle;



    initial begin
        $display("Starting simulation");
        #5ns;
        clk <= 0;

        addr <= '0;
        req <= '0;
        rd_wr <= '0;
        write_val <= 0;
        cfg_ctrl_err <= '0;
        cfg_ctrl_idle <= '0;

        // reset
        reset_L <= 0;
        #20ns;
        reset_L <= 1;

        repeat (10) @(posedge clk);

        // read
        @(posedge clk);
        req <= 1'b1;
        rd_wr <= 1'b1;
        @(posedge clk);
        req <= 1'b0;

        // write
        @(posedge clk);
        req <= 1'b1;
        write_val <= '1;
        rd_wr <= 1'b0;
        @(posedge clk);
        req <= 1'b0;
        write_val <= '0;

        @(posedge clk);
        $display("[%0t] Status change", $time);
        cfg_ctrl_err <= '1;

        // read
        @(posedge clk);
        req <= 1'b1;
        rd_wr <= 1'b1;
        @(posedge clk);
        req <= 1'b0;

        // write
        repeat (10) @(posedge clk);
        req <= 1'b1;
        rd_wr <= '0;
        write_val <= '0;
        @(posedge clk);
        req <= 1'b0;


        // read
        @(posedge clk);
        req <= 1'b1;
        rd_wr <= 1'b1;
        @(posedge clk);
        req <= 1'b0;


        #1000ns;
        $finish();
    end


    // monitor
    always @(posedge clk) begin
        if(req)
            if(rd_wr) begin // READ
                @(posedge ack)
                $display("[%0t] READ 0x%x",$time,read_val);
            end
            else begin // WRITE
                $display("[%0t] WRITE 0x%x",$time,write_val);
            end
    end


    // clk gen
    always @(*) begin
        #5ns;
        clk <= ~clk;
    end

    regs REG(
        .clk(clk),
        .reset_L(reset_L),

        .addr(addr),
        .rd_wr(rd_wr),
        .req(req),
        .write_val(write_val),

        .cfg_ctrl_err(cfg_ctrl_err),
        .cfg_ctrl_idle(cfg_ctrl_idle),
        .cfg_port_enable(),
        .cfg_port_id(),

        .ack(ack),
        .read_val(read_val)

    );

    initial begin
        $dumpfile("sim.vcd");
        $dumpvars(0,tb);
    end


endmodule
