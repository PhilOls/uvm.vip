
class base_filter #(type txn_t=base_txn, cfg_t=base_cfg) extends uvm_component;

   `uvm_component_param_utils(base_filter #(txn_t, cfg_t))

  cfg_t                        cfg;

  uvm_analysis_export #(txn_t) ae_in;
  uvm_analysis_port   #(txn_t) ap_out;

  uvm_tlm_analysis_fifo #(txn_t) filter_fifo;

  int m_filtered;
  
  function new(string name, uvm_component parent);

    super.new(name, parent);
    if (!uvm_config_db #(cfg_t)::get(this,"", "cfg", cfg))
      `uvm_fatal(get_type_name(), "Could not get cfg from cfg db")

    ae_in = new("ae_in", this);
    ap_out = new("ap_out", this);
    filter_fifo = new("filter_fifo", this);
    m_filtered = 0;

  endfunction
  

  virtual function void connect_phase(uvm_phase phase);
    ae_in.connect(filter_fifo.analysis_export);
  endfunction



  virtual task run_phase(uvm_phase phase);
    txn_t txn;
    super.run_phase(phase); 

    forever begin
      filter_fifo.get(txn);
      ap_out.write(txn);
    end
  endtask
  
endclass

