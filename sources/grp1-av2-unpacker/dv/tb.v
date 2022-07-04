`timescale 1ns/1ps

module tb();

    localparam IN_IFC_SZ_B = 160;

    logic clk;
    logic reset_L;
    logic ready;

    logic val;
    logic sop;
    logic eop;
    logic [7:0] vbc;
    logic [IN_IFC_SZ_B*8-1:0] data;

    always #1ns clk = ~clk;


    initial begin
        clk     = '0;
        reset_L = '0;

        #3ns;
        reset_L = '1;

        insert_pkt(64);
        @(posedge ready);
        insert_pkt(160);
        @(posedge ready);
        insert_pkt(161);


        #100ns;
        $finish();
    end



    unpacker_fsm unpacker(
        .clk,
        .reset_L,
        .val,
        .sop,
        .eop,
        .vbc,
        .data,
        .ready
    );



    task automatic insert_pkt(input [7:0] size);

        real words_f = size*1.0/IN_IFC_SZ_B;
        int words = $ceil(words_f);
        int words_mod = size%IN_IFC_SZ_B;

        @(posedge clk);
        $display("[%0t] Inserting pkt size %0d, words %0d", $time, size, words);
        sop <= 1;
        val <= 1;

        if(words==1) begin
            eop <= 1;
            vbc <= size;
        end
        else begin
            eop <= 0;
            vbc <= 160;
            for(int i=1; i<words; ++i) begin
                @(posedge clk);
                sop <= '0;
                if(i==words-1) begin
                    eop <= '1;
                    vbc <= words_mod;
                end
                @(posedge ready);
            end
        end
        @(posedge clk);
        sop <= 0;
        eop <= 0;
        val <= 0;
        vbc <= 0;
        $display("[%0t] Inserting pkt size %0d done", $time, size);
    endtask


    initial begin
        $dumpfile("sim.vcd");
        $dumpvars(0,tb);
    end


endmodule
