`ifndef base_env__SV
`define base_env__SV

class base_env #(type vif_t=virtual base_if,type cfg_t = base_cfg,type txn_t = base_txn, type reg_model_t = uvm_reg_block) extends uvm_env;

  `uvm_component_param_utils(base_env #(vif_t,cfg_t,txn_t,reg_model_t))

  vif_t                                                vif;
  cfg_t                                                cfg;
  reg_model_t                                          rm;

  base_agent        #(vif_t,cfg_t,txn_t,reg_model_t)   mst_agt;
  base_agent        #(vif_t,cfg_t,txn_t,reg_model_t)   slv_agt;

  base_scbd         #(txn_t, cfg_t)                    sb_mon2drv;
  base_scbd         #(txn_t, cfg_t)                    sb_mon2cpsr;

  base_scbd         #(txn_t, cfg_t)                    filt_sb_mon2drv;
  base_scbd         #(txn_t, cfg_t)                    filt_sb_mon2cpsr;


  base_cpsr         #(cfg_t,txn_t,reg_model_t)         cpsr;

  base_cov          #(txn_t)                           cov;
  base_mon2cov      #(txn_t)                           mon2cov;

  uvm_reg_predictor #(txn_t)                           reg_predictor;
  base_adp          #(txn_t)                           adp;

  extern function new(string name="base_env", uvm_component parent=null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern function void start_of_simulation_phase(uvm_phase phase);
  extern virtual task reset_phase(uvm_phase phase);
  extern virtual task configure_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual function void extract_phase(uvm_phase phase);
  extern virtual function void check_phase(uvm_phase phase);
  extern virtual function void report_phase(uvm_phase phase);
  extern virtual task shutdown_phase(uvm_phase phase);

endclass: base_env

function base_env::new(string name= "base_env",uvm_component parent=null);
   super.new(name,parent);
  if (!uvm_config_db #(cfg_t)::get(this,"", "cfg", cfg))
    `uvm_fatal(get_type_name(), "Could not get cfg from cfg db")
  else
    uvm_config_db #(cfg_t)::set(this,"*", "cfg", cfg);
  if (cfg.master_slave!=base_vip_pkg::NONE) begin : l_none
    if (!uvm_config_db #(vif_t)::get(this,"", "vif", vif))
      `uvm_fatal(get_type_name(), "Could not get vif from cfg db")
    else
      uvm_config_db #(vif_t)::set(this,"*", "vif", vif);
  end : l_none
endfunction:new

function void base_env::build_phase(uvm_phase phase);

  if (cfg.master_slave!=base_vip_pkg::NONE) begin
    if (!uvm_config_db #(reg_model_t)::get(this,"", "rm", rm)) begin
      if (cfg.adapter && rm==null)
        `uvm_fatal(get_full_name(), "Adapter requested but no reg-model is available")
      if (cfg.composer && rm==null)
        `uvm_fatal(get_full_name(), "Composer requested but no reg-model is available")
    end
    else
      uvm_config_db #(reg_model_t)::set(this,"*", "rm", rm);

    super.build_phase(phase);

    if (cfg.master_slave == base_vip_pkg::MASTER) begin
      mst_agt = base_agent #(vif_t,cfg_t,txn_t,reg_model_t)::type_id::create("mst_agt",this);
    end
    else begin
      slv_agt = base_agent #(vif_t,cfg_t,txn_t,reg_model_t)::type_id::create("slv_agt",this);
    end
    if (cfg.adapter) begin
      adp           =                     base_adp#(txn_t)::type_id::create("adp", this);
      reg_predictor =           uvm_reg_predictor#(txn_t)::type_id::create("reg_predictor", this);
      reg_predictor.set_report_verbosity_level_hier(UVM_LOW);
    end
    if (cfg.composer) begin
      cpsr         =   base_cpsr#(cfg_t,txn_t,reg_model_t)::type_id::create("cpsr", this);
      sb_mon2cpsr  =              base_scbd#(txn_t, cfg_t)::type_id::create("sb_mon2cpsr",this);
      sb_mon2cpsr.set_report_verbosity_level_hier(cfg.sb_verbosity_level);

      filt_sb_mon2cpsr = base_scbd#(txn_t,cfg_t)::type_id::create("filt_sb_mon2cpsr",this);
      filt_sb_mon2cpsr.set_report_verbosity_level_hier(cfg.sb_verbosity_level);

    end
    if (cfg.coverage != UVM_NO_COVERAGE) begin
      cov      =     base_cov#(txn_t)::type_id::create("cov",this);
      mon2cov  = base_mon2cov#(txn_t)::type_id::create("mon2cov", this);
      mon2cov.cov = cov;
    end

    if (cfg.active_passive == UVM_ACTIVE) begin
      sb_mon2drv = base_scbd#(txn_t, cfg_t)::type_id::create("sb_mon2drv",this);
      sb_mon2drv.set_report_verbosity_level_hier(cfg.sb_verbosity_level);

      filt_sb_mon2drv = base_scbd#(txn_t, cfg_t)::type_id::create("filt_sb_mon2drv",this);
      filt_sb_mon2drv.set_report_verbosity_level_hier(cfg.sb_verbosity_level);
    end
  end

endfunction: build_phase

function void base_env::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  if (cfg.master_slave!=base_vip_pkg::NONE) begin
    if (cfg.active_passive == UVM_ACTIVE && cfg.master_slave ==base_vip_pkg::MASTER)
    begin
      mst_agt.drv.rsp_port.connect(sb_mon2drv.expected_export);
      mst_agt.mon.ap.connect(sb_mon2drv.actual_export);
      sb_mon2drv.expected_name = "master driver";
      sb_mon2drv.actual_name = "master monitor";
      mst_agt.drv.rsp_port.connect(filt_sb_mon2drv.expected_export);
      mst_agt.mon.ap.connect(filt_sb_mon2drv.actual_export);
      filt_sb_mon2drv.expected_name = "master driver";
      filt_sb_mon2drv.actual_name = "master monitor";
    end
    if (cfg.coverage != UVM_NO_COVERAGE)
      if (cfg.master_slave ==base_vip_pkg::MASTER)
        mst_agt.mon.ap.connect(cov.cov_export);
      else
        slv_agt.mon.ap.connect(cov.cov_export);

    if (cfg.adapter) begin
      reg_predictor.adapter = adp;
      if (cfg.master_slave ==base_vip_pkg::MASTER) begin
        mst_agt.mon.ap2adp.connect(reg_predictor.bus_in);
        rm.default_map.set_sequencer(mst_agt.sqr,adp);
      end
      else begin
        slv_agt.mon.ap2adp.connect(reg_predictor.bus_in);
        rm.default_map.set_sequencer(slv_agt.sqr,adp);
      end

      reg_predictor.map = rm.default_map;
    end
    if (cfg.composer) begin
      cpsr.ap.connect(sb_mon2cpsr.expected_export);
      cpsr.ap.connect(filt_sb_mon2cpsr.expected_export);
      if (cfg.master_slave ==base_vip_pkg::MASTER) begin
        mst_agt.mon.ap.connect(sb_mon2cpsr.actual_export);
        mst_agt.mon.ap.connect(filt_sb_mon2cpsr.actual_export);
        sb_mon2cpsr.expected_name = "regmodel composer";
        sb_mon2cpsr.actual_name = "master monitor";
        filt_sb_mon2cpsr.expected_name = "regmodel composer";
        filt_sb_mon2cpsr.actual_name = "master monitor";
      end
      else begin
        slv_agt.mon.ap.connect(sb_mon2cpsr.actual_export);
        slv_agt.mon.ap.connect(filt_sb_mon2cpsr.actual_export);
        sb_mon2cpsr.expected_name = "regmodel composer";
        sb_mon2cpsr.actual_name = "slave monitor";
        filt_sb_mon2cpsr.expected_name = "regmodel composer";
        filt_sb_mon2cpsr.actual_name = "slave monitor";
      end
    end
  end
endfunction: connect_phase

function void base_env::start_of_simulation_phase(uvm_phase phase);
  super.start_of_simulation_phase(phase);
endfunction: start_of_simulation_phase


task base_env::reset_phase(uvm_phase phase);
   super.reset_phase(phase);
   phase.raise_objection(this,"");
   phase.drop_objection(this);
endtask:reset_phase

task base_env::configure_phase (uvm_phase phase);
   super.configure_phase(phase);
   phase.raise_objection(this,"");
   phase.drop_objection(this);
endtask:configure_phase

task base_env::run_phase(uvm_phase phase);
   super.run_phase(phase);
   phase.raise_objection(this,"");
   phase.drop_objection(this);
endtask:run_phase

function void base_env::extract_phase(uvm_phase phase);
   super.extract_phase(phase);
endfunction:extract_phase

function void base_env::check_phase(uvm_phase phase);
   super.check_phase(phase);
endfunction:check_phase

function void base_env::report_phase(uvm_phase phase);
   super.report_phase(phase);
endfunction:report_phase

task base_env::shutdown_phase(uvm_phase phase);
   super.shutdown_phase(phase);
endtask:shutdown_phase
`endif // base_env__SV

