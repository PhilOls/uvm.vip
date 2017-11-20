//
// Template for UVM-compliant sequence library
//


`ifndef base_seq_lib__SV
`define base_seq_lib__SV


typedef class base_txn;

class base_seq_lib extends uvm_sequence_library # (base_txn, base_txn);
  
  `uvm_object_utils(base_seq_lib)
  `uvm_sequence_library_utils(base_seq_lib)

  function new(string name = "simple_seq_lib");
    super.new(name);
    init_sequence_library();
  endfunction

endclass  

class base_sequence extends uvm_sequence #(base_txn, base_txn);
  rand base_txn::kinds_e   kind;

  `uvm_object_utils_begin(base_sequence)
		`uvm_field_enum(base_txn::kinds_e, kind, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "base_seq");
    super.new(name);
	`ifdef UVM_POST_VERSION_1_1
     set_automatic_phase_objection(1);
    `endif
  endfunction:new

  `ifdef UVM_VERSION_1_0
  virtual task pre_body();
    if (starting_phase != null)
      starting_phase.raise_objection(this);
  endtask:pre_body

  virtual task post_body();
    if (starting_phase != null)
      starting_phase.drop_objection(this);
  endtask:post_body
  `endif
  
  `ifdef UVM_VERSION_1_1
  virtual task pre_start();
    if((get_parent_sequence() == null) && (starting_phase != null))
      starting_phase.raise_objection(this, "Starting");
  endtask:pre_start

  virtual task post_start();
    if ((get_parent_sequence() == null) && (starting_phase != null))
      starting_phase.drop_objection(this, "Ending");
  endtask:post_start
  `endif
endclass

class write_base extends base_sequence;

  `uvm_object_utils(write_base)
  `uvm_add_to_seq_lib(write_base,base_seq_lib)

  constraint c_write {
    kind == base_txn::WRITE;
  }

  function new(string name = "write_base");
    super.new(name);
	`ifdef UVM_POST_VERSION_1_1
     set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    req = base_txn::type_id::create("req");
		`uvm_do_with(req,
			{req.kind            == local::kind;
			 req.status          == UVM_IS_OK;
			})
		get_response(rsp);
  endtask
endclass

class read_base extends base_sequence;

  `uvm_object_utils(read_base)
  `uvm_add_to_seq_lib(read_base,base_seq_lib)

  constraint c_read {
    kind == base_txn::READ;
  }

  function new(string name = "read_base");
    super.new(name);
	`ifdef UVM_POST_VERSION_1_1
     set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    req = base_txn::type_id::create("req");
		`uvm_do_with(req,
			{req.kind            == local::kind;
			 req.status          == UVM_IS_OK;
			})
		get_response(rsp);
  endtask
endclass

`endif // base_seq_lib__SV
