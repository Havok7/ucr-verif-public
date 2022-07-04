class counter_sequence extends uvm_sequence#(counter_tlm);

    rand int num;

    constraint num_c {
        num > 0;
        num < 30;
    }


    `uvm_object_utils_begin(counter_sequence)
       `uvm_field_int(num, UVM_ALL_ON)
    `uvm_object_utils_end


    function new(string name = "");
        super.new(name);
    endfunction: new


    task body();
        counter_tlm tlm;
        tlm = counter_tlm::type_id::create(.name("tlm"), .contxt(get_full_name()));

        repeat(num) begin
            start_item(tlm);
            assert(tlm.randomize());
            //`uvm_info("counter_seq", $sformatf("injecting %s", tlm.opcode.name), UVM_LOW);
            finish_item(tlm);
        end

    endtask: body



endclass: counter_sequence
