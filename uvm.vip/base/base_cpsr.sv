//
// Template for UVM-compliant register-level to transaction-level composer
//

`ifndef base_cpsr__SV
`define base_cpsr__SV

class base_cpsr #(type cfg_t=base_cfg,type txn_t=base_txn, type reg_model_t=uvm_reg_block) extends uvm_component;

  `uvm_component_param_utils(base_cpsr #(cfg_t,txn_t, reg_model_t))

  uvm_analysis_port #(txn_t) ap;      //TLM analysis port

  cfg_t       cfg;
  reg_model_t rm;

  extern function new(string name = "base_cpsr",uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);

endclass: base_cpsr


function base_cpsr::new(string name = "base_cpsr",uvm_component parent);
   super.new(name, parent);
   ap = new("ap",this);
endfunction: new

function void base_cpsr::build_phase(uvm_phase phase);
  uvm_config_db #(reg_model_t)::get(this,"", "rm", rm);
  uvm_config_db       #(cfg_t)::get(this,"", "cfg", cfg);
  super.build_phase(phase);
endfunction: build_phase

function void base_cpsr::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
 endfunction: connect_phase

task base_cpsr::run_phase(uvm_phase phase);
    super.run_phase(phase);
endtask: run_phase


`endif // base_cpsr__SV
