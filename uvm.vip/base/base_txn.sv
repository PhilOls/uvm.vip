//
// Template for UVM-compliant transaction descriptor


`ifndef base_TXN__SV
`define base_TXN__SV


class base_txn extends uvm_sequence_item;

  function string convert2string();
    convert2string = "";
    return convert2string;
  endfunction : convert2string

  function base_txn::new(string name = "base_txn");
    super.new(name);
  endfunction: new

endclass: base_txn

`endif // base_TXN__SV
