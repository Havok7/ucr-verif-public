
// List of possible operations
typedef enum {WRITE, READ, RESET, RW_FIELD, DONE, WAIT} operation_enum;

class regs_transaction extends uvm_sequence_item;
        parameter ADDR_SIZE_P = 4;

        // Random generator for incoming data and address values
        rand int data_stream;
	rand int address;

        // Random operation generator
        rand operation_enum operation;

        // Constructor
	function new(string name = "");
		super.new(name);
	endfunction: new

         function regs_transaction clone();
                regs_transaction regs_trans;
                regs_trans = regs_transaction::type_id::create(.name(get_name()), .contxt(get_full_name()));
                return regs_trans;
        endfunction: clone

        //Define Utility Objects from previous definitions
	`uvm_object_utils_begin(regs_transaction)
		`uvm_field_int(data_stream, UVM_ALL_ON)
		`uvm_field_int(address, UVM_ALL_ON)
		`uvm_field_enum(operation_enum, operation, UVM_ALL_ON)
	`uvm_object_utils_end

        // Max and Min values for data
        // ******* PREGUNTA: Al ser 32 Bits hay alguna manera mas eficiente de hacer esto?
        //                   Si se declara data_stream como 'rand bit [31:0] data_stream' seria lo mismo y ya estaria limitado por los bits?
        constraint data_stream_c {
                data_stream >= 0;
                data_stream < 'hFFFFFFFF;
        }

        // Max and Min values for addresses
        constraint address_c {
                address >= 0;
                address < 15; 
        }

        // Create a distribuiton to control frecuency of opcodes
        constraint operation_distribution {
                operation dist {
                        READ       := 4,
                        WRITE      := 5,
                        RESET      := 2,
                        RW_FIELD   := 12      
                };
        }
endclass: regs_transaction


// class regs_transaction extends uvm_sequence_item;
//         parameter ADDR_SIZE_P = 4;

//         // Random generator for incoming data and address values
//         int data_stream = 11;
// 	int address = 1;

//         // Random operation generator
//         operation_enum operation = RW_FIELD;

//         // Constructor
// 	function new(string name = "");
// 		super.new(name);
// 	endfunction: new

//          function regs_transaction clone();
//                 regs_transaction regs_trans;
//                 regs_trans = regs_transaction::type_id::create(.name(get_name()), .contxt(get_full_name()));
//                 return regs_trans;
//         endfunction: clone

//         //Define Utility Objects from previous definitions
// 	`uvm_object_utils_begin(regs_transaction)
// 		`uvm_field_int(data_stream, UVM_ALL_ON)
// 		`uvm_field_int(address, UVM_ALL_ON)
// 		`uvm_field_enum(operation_enum, operation, UVM_ALL_ON)
// 	`uvm_object_utils_end
// endclass: regs_transaction


class regs_sequence extends uvm_sequence#(regs_transaction);
        rand int num;

    constraint num_c {
        num > 0;
        num < 100;
    }


    `uvm_object_utils_begin(regs_sequence)
       `uvm_field_int(num, UVM_ALL_ON)
    `uvm_object_utils_end

        // Constructor
	function new(string name = "");
		super.new(name);
	endfunction: new

	task body();
                // Create transaction object
		// regs_transaction_random sa_tx;
                // sa_tx = regs_transaction_random::type_id::create(.name("sa_tx"), .contxt(get_full_name()));

                // regs_transaction_read sa_tx_r;
                // sa_tx_r = regs_transaction_read::type_id::create(.name("sa_tx_r"), .contxt(get_full_name()));

                regs_transaction sa_tx;
                sa_tx = regs_transaction::type_id::create(.name("sa_tx_w"), .contxt(get_full_name()));

		repeat(num) begin
                        start_item(sa_tx);
		        assert(sa_tx.randomize());
		        // assert(sa_tx);
		        `uvm_info("sa_sequence", sa_tx.sprint(), UVM_LOW);
		        finish_item(sa_tx);
		end

	endtask: body

endclass: regs_sequence

typedef uvm_sequencer#(regs_transaction) regs_sequencer;
