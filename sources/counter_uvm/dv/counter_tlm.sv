
typedef enum {RESET, INC, ENABLE, CLEAR} opcode_e;

class counter_tlm extends uvm_sequence_item;


    rand opcode_e   opcode;
    rand int        data;
    rand int        hold;

	function new(string name = "");
		super.new(name);
	endfunction: new

	`uvm_object_utils_begin(counter_tlm)
		`uvm_field_enum(opcode_e, opcode, UVM_ALL_ON)
		`uvm_field_int(hold, UVM_ALL_ON)
        `uvm_field_int(data, UVM_ALL_ON)
	`uvm_object_utils_end


    constraint hold_c {
        hold > 0;
        hold < 10;
    }

    constraint data_c {
        data >= 0;
        data < 16;
    }

    constraint opcode_c {
        opcode dist {
            INC     := 20,
            RESET   := 3,
            ENABLE  := 5,
            CLEAR   := 5
        };
    }


endclass: counter_tlm