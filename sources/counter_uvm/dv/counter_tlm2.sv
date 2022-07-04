
typedef enum {RESET, INC, ENABLE, CLEAR, NON_ZERO, OVERFLOW} opcode_e;

class counter_tlm extends uvm_sequence_item;

    rand opcode_e   opcode;
    rand int        data;

	function new(string name = "");
		super.new(name);
	endfunction: new

	`uvm_object_utils_begin(counter_tlm)
		`uvm_field_enum(opcode_e, opcode, UVM_ALL_ON)
        `uvm_field_int(data, UVM_ALL_ON)
	`uvm_object_utils_end


    constraint data_c {
        data >= 0;
        data < 16;
    }

    constraint opcode_c {
        opcode dist {
            INC     := 10,
            RESET   := 5,
            ENABLE  := 5,
            CLEAR   := 5
        };
    }


endclass: counter_tlm