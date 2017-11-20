//
// Base agent
//

`ifndef base_agent__SV
`define base_agent__SV


class base_agent #(type vif_t=virtual base_if,type cfg_t=base_cfg,type txn_t=base_txn, type reg_model_t=uvm_reg_block) extends uvm_agent;

  `uvm_component_param_utils_begin(base_agent #(vif_t,cfg_t,txn_t,reg_model_t))
  `uvm_component_utils_end

   uvm_sequencer #(txn_t,txn_t)       sqr;
   base_drv      #(vif_t,cfg_t,txn_t, reg_model_t)  drv;
   base_mon      #(vif_t,cfg_t,txn_t, reg_model_t)  mon;
   cfg_t                              cfg;

   function new(string name = "base_agent", uvm_component parent = null);
      super.new(name, parent);
      if (!uvm_config_db #(cfg_t)::get(this,"", "cfg", cfg))
        `uvm_fatal(get_type_name(), "Could not get cfg from cfg db")
      uvm_config_db #(cfg_t)::set(this,"drv", "cfg", cfg);
      uvm_config_db #(cfg_t)::set(this,"mon", "cfg", cfg);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      mon = base_mon#(vif_t,cfg_t,txn_t, reg_model_t)::type_id::create("mon", this);
      if (cfg.active_passive == UVM_ACTIVE) begin
        sqr = uvm_sequencer#(txn_t, txn_t)::type_id::create("sqr", this);
        drv = base_drv#(vif_t,cfg_t,txn_t, reg_model_t)::type_id::create("drv", this);
      end
   endfunction: build_phase

   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if (cfg.active_passive == UVM_ACTIVE)
        drv.seq_item_port.connect(sqr.seq_item_export);
   endfunction

   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
   endtask

   virtual function void report_phase(uvm_phase phase);
      super.report_phase(phase);
   endfunction

endclass: base_agent
 
`endif // base_agent__SV

