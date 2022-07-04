
typedef enum {PKT_OK, PKT_ERR_SOP, PKT_ERR_EOP, PKT_ERR_EN, PKT_RESET} pkt_type_e;

typedef enum {RESET, CFG, VAL} opcode_e;

class control_tlm extends uvm_sequence_item;

	rand pkt_type_e		pkt_type;
	rand opcode_e		opcode[$];
	rand integer		w_size;
	
	function new(string name = "");
		super.new(name);
	endfunction: new

	
	`uvm_object_utils_begin(control_tlm)
		`uvm_field_enum(pkt_type_e, pkt_type, UVM_ALL_ON)
		`uvm_field_queue_enum(opcode_e, opcode, UVM_ALL_ON)
		`uvm_field_int(w_size, UVM_ALL_ON)
	`uvm_object_utils_end

    
	constraint w_size_c {
        w_size >=	1;
        w_size < 	5;
    }

	constraint pkt_type_c {
        pkt_type dist {
            PKT_OK		    := 10,
            PKT_ERR_SOP     := 5,
            PKT_ERR_EOP	    := 5
        };
    }
    
	constraint opcode_c {
        opcode.size() > 0;
        opcode.size() < 4;

        foreach (opcode[i]) {
            opcode[i] dist {
                CFG     := 10,
                VAL     := 10,
                RESET   := 5
            };
        }
    }
	
endclass: control_tlm
