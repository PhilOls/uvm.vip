`ifndef base_DRV__SV
`define base_DRV__SV

class base_drv#(type vif_t=virtual base_if,type cfg_t=base_cfg,type txn_t=base_txn, type reg_model_t=uvm_reg_block) extends uvm_driver#(txn_t,txn_t);

   `uvm_component_param_utils(base_drv #(vif_t,cfg_t,txn_t,reg_model_t))

   vif_t           vif;
   cfg_t           cfg;
   reg_model_t     rm;
   
	function new(string name = "base_drv",
										 uvm_component parent = null);
		 super.new(name, parent);
  if (!uvm_config_db #(cfg_t)::get(this,"", "cfg", cfg))
    `uvm_fatal(get_type_name(), "Could not get cfg from cfg db")
  if (!uvm_config_db #(vif_t)::get(this,"", "vif", vif))
    `uvm_fatal(get_type_name(), "Could not get vif from cfg db")

	endfunction


  virtual function void build_phase(uvm_phase phase);
    uvm_config_db #(reg_model_t)::get(this,"", "rm", rm);
    super.build_phase(phase);
  endfunction: build_phase

	virtual function void connect_phase(uvm_phase phase);
		 super.connect_phase(phase);
	endfunction: connect_phase

	virtual function void end_of_elaboration_phase(uvm_phase phase);
		 super.end_of_elaboration_phase(phase);
	endfunction: end_of_elaboration_phase

	virtual function void start_of_simulation_phase(uvm_phase phase);
		 super.start_of_simulation_phase(phase);
	endfunction: start_of_simulation_phase


	virtual task reset_phase(uvm_phase phase);
		 super.reset_phase(phase);
		 phase.raise_objection(this,"");
		 phase.drop_objection(this);
	endtask: reset_phase

	virtual task configure_phase(uvm_phase phase);
		 super.configure_phase(phase);
		 phase.raise_objection(this,"");
		 phase.drop_objection(this);
	endtask:configure_phase


	virtual task run_phase(uvm_phase phase);
		 super.run_phase(phase);
//		 `uvm_fatal(get_full_name(), "This driver is void. Starting a sequence on its agent will stall")
	endtask: run_phase

	`endif // base_DRV__SV

endclass: base_drv
