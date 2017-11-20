//
// Template for UVM-compliant Coverage Class
//


`ifndef base_COV__SV
`define base_COV__SV

`uvm_analysis_imp_decl(_base_txn)

`define wildbin8 \
      wildcard bins b0_0 = {8'b???????0};\
      wildcard bins b1_0 = {8'b??????0?};\
      wildcard bins b2_0 = {8'b?????0??};\
      wildcard bins b3_0 = {8'b????0???};\
      wildcard bins b4_0 = {8'b???0????};\
      wildcard bins b5_0 = {8'b??0?????};\
      wildcard bins b6_0 = {8'b?0??????};\
      wildcard bins b7_0 = {8'b0???????};\
      wildcard bins b0_1 = {8'b???????1};\
      \
      wildcard bins b1_1 = {8'b??????1?};\
      wildcard bins b2_1 = {8'b?????1??};\
      wildcard bins b3_1 = {8'b????1???};\
      wildcard bins b4_1 = {8'b???1????};\
      wildcard bins b5_1 = {8'b??1?????};\
      wildcard bins b6_1 = {8'b?1??????};\
      wildcard bins b7_1 = {8'b1???????};


class base_cov #(type txn_t=base_txn) extends uvm_component;

   `uvm_component_param_utils(base_cov #(txn_t))


   event cov_event;
   txn_t tr;
   uvm_analysis_imp_base_txn #(txn_t, base_cov #(txn_t)) cov_export;


   function new(string name, uvm_component parent);
      super.new(name,parent);
      cov_export = new("Coverage Analysis",this);
   endfunction: new

   virtual function write_base_txn(txn_t tr);
      this.tr = tr;
      -> cov_event;
   endfunction: write_base_txn

endclass: base_cov

`endif // base_COV__SV

