//
// Template for UVM-compliant transaction descriptor


`ifndef base_TXN__SV
`define base_TXN__SV


class base_txn extends uvm_sequence_item;
  typedef enum {READ, WRITE } kinds_e;
  rand kinds_e          kind;
  rand uvm_status_e     status;
  string                comp_name = "";

  `uvm_object_utils_begin(base_txn)
    `uvm_field_enum(kinds_e,kind,UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_enum(uvm_status_e,status, UVM_ALL_ON)
    `uvm_field_string(comp_name, UVM_ALL_ON | UVM_NOCOMPARE)
  `uvm_object_utils_end

  function string convert2string();
    convert2string = "";
    $swrite(convert2string, "%s\n** base transaction\n", convert2string);
    $swrite(convert2string, "%s  comp       : %s \n", convert2string, comp_name);
    $swrite(convert2string, "%s  kind       : %s \n", convert2string, kind.name);
    $swrite(convert2string, "%s  status     : %s \n", convert2string, status.name);

    return convert2string;
  endfunction : convert2string


  extern function new(string name = "Trans");
endclass: base_txn


function base_txn::new(string name = "Trans");
   super.new(name);
endfunction: new


`endif // base_TXN__SV
