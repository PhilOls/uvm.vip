//
//	Fully-featured score board
//	- connects to score board filter
//	- displays statistics during report phase

`ifndef base_SCBD__SV
`define base_SCBD__SV

class base_scbd #(type txn_t=base_txn, cfg_t=base_cfg) extends uvm_scoreboard;
	cfg_t cfg;
	string actual_name   = "actual";
	string expected_name = "expected";
	
	`uvm_component_param_utils(base_scbd #(txn_t,cfg_t))
	
	uvm_analysis_export #(txn_t)           expected_export, actual_export;
	base_filter #(txn_t, cfg_t)             expected_filter, actual_filter;
	base_in_order_class_comparator #(txn_t) comparator;
	
	extern function new(string name = "base_scbd",
		uvm_component parent = null); 
	extern virtual function void build_phase (uvm_phase phase);
	extern virtual function void connect_phase (uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	extern virtual function void report_phase(uvm_phase phase);
endclass: base_scbd


function base_scbd::new(string name = "base_scbd",
                 uvm_component parent);
   super.new(name,parent);
  if (!uvm_config_db #(cfg_t)::get(this,"", "cfg", cfg))
    `uvm_fatal(get_type_name(), "Could not get cfg from cfg db")
  else
    uvm_config_db #(cfg_t)::set(this,"*", "cfg", cfg);
endfunction: new

function void base_scbd::build_phase(uvm_phase phase);
    super.build_phase(phase);
    expected_export = new("expected_export", this);
    actual_export   = new("actual_export", this);
    comparator      = base_in_order_class_comparator #(txn_t)::type_id::create("comparator", this);
    expected_filter = base_filter#(txn_t, cfg_t)::type_id::create("expected_filter", this);
    actual_filter   = base_filter#(txn_t, cfg_t)::type_id::create("actual_filter", this);
endfunction:build_phase

function void base_scbd::connect_phase(uvm_phase phase);
    expected_export.connect(expected_filter.ae_in);
    actual_export.connect(actual_filter.ae_in);
    expected_filter.ap_out.connect(comparator.expected_export);
    actual_filter.ap_out.connect(comparator.actual_export);
endfunction:connect_phase

task base_scbd::run_phase(uvm_phase phase);
  super.run_phase(phase);
  phase.raise_objection(this,"scbd..");
  phase.drop_objection(this);
endtask: run_phase

function void base_scbd::report_phase(uvm_phase phase);
	super.report_phase(phase);
	if (comparator.m_matches+comparator.m_mismatches > 0)
		`uvm_info("", $psprintf("Matches = %0d, Mismatches = %0d",
			comparator.m_matches, comparator.m_mismatches),
			UVM_NONE);
	if (expected_filter.m_filtered+actual_filter.m_filtered > 0)
		`uvm_info("", $psprintf("Filtered on %s = %0d, Filtered on %s = %0d",
			actual_name, actual_filter.m_filtered,
			expected_name, expected_filter.m_filtered),
			UVM_NONE)
	if (comparator.m_expected_fifo_used!=0 || comparator.m_actual_fifo_used != 0) begin
		if (comparator.m_expected_fifo_used!=0) begin
			txn_t t;
			`uvm_warning("", $psprintf("Items remaining in %s fifo = %0d", expected_name, comparator.m_expected_fifo_used))
			if (comparator.m_expected_fifo.try_get(t))
			t.print();
		end
		if (comparator.m_actual_fifo_used!=0) begin
			txn_t t;
			`uvm_warning("", $psprintf("Items remaining in %s fifo = %0d", actual_name, comparator.m_actual_fifo_used))
			if (comparator.m_actual_fifo.try_get(t))
				t.print();
		end
	end
endfunction:report_phase

`endif // base_SCBD__SV
