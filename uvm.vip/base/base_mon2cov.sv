//
// Template for UVM-compliant Monitor to Coverage Connector Callbacks
//

`ifndef base_MON2COV
`define base_MON2COV

class base_mon2cov #(type txn_t=base_txn) extends uvm_component;

   `uvm_component_param_utils(base_mon2cov #(txn_t))

   base_cov #(txn_t) cov;
   uvm_analysis_export #(txn_t) an_exp;

   function new(string name="", uvm_component parent=null);
   	super.new(name, parent);
   endfunction: new

   virtual function void write(txn_t tr);
      cov.tr = tr;
      -> cov.cov_event;
   endfunction:write 
endclass: base_mon2cov

`endif // base_MON2COV
