//
// Base RAL adapter

`ifndef base_adp__SV
`define base_adp__SV

class base_adp #(type txn_t=base_txn) extends uvm_reg_adapter;

  `uvm_object_param_utils(base_adp #(txn_t))

  function new (string name="base_adp", uvm_component parent = null);
    super.new(name);
    supports_byte_enable = 1;
    provides_responses = 1;
  endfunction
 
   
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
  endfunction

  virtual function void bus2reg (uvm_sequence_item bus_item,
                                  ref uvm_reg_bus_op rw);
  endfunction

endclass: base_adp
`endif // base_adp__SV

