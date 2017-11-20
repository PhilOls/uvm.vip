`ifndef base_mon__SV
`define base_mon__SV

class base_mon #(type vif_t=virtual base_if,type cfg_t=base_cfg,type txn_t=base_txn, type reg_model_t=uvm_reg_block) extends uvm_monitor;

	`uvm_component_param_utils(base_mon #(vif_t,cfg_t,txn_t, reg_model_t))

	uvm_analysis_port #(txn_t) ap;      //TLM analysis port
	uvm_analysis_port #(txn_t) ap2adp;  //TLM analysis port for adapter (burst splitted if needed)
	vif_t                      vif;
	cfg_t                      cfg;
	reg_model_t                rm;
	bit                        active = 0;
	bit                        bypass = 0;
	uvm_event                  ev_start;
	uvm_event                  ev_stop;

	bit                        clk;
	process                    p_gen_clk;

	time                       half_period = 1ms;

	extern function new(string name = "base_mon",uvm_component parent);

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void end_of_elaboration_phase(uvm_phase phase);
	extern virtual function void start_of_simulation_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual task reset_phase(uvm_phase phase);
	extern virtual task configure_phase(uvm_phase phase);
	extern virtual task gen_clk();
	extern virtual task run_phase(uvm_phase phase);
	extern virtual task start_det(uvm_phase phase);
	extern virtual task stop_det(uvm_phase phase);
	extern virtual task shutdown_phase(uvm_phase phase);

endclass: base_mon


function base_mon::new(string name = "base_mon",uvm_component parent);
	super.new(name, parent);
	if (!uvm_config_db #(cfg_t)::get(this,"", "cfg", cfg))
		`uvm_fatal(get_type_name(), "Could not get cfg from cfg db")
	ap     = new ("ap",this);
	ap2adp = new ("ap2adp",this);
endfunction: new

function void base_mon::build_phase(uvm_phase phase);
	uvm_config_db #(reg_model_t)::get(this,"", "rm", rm);
	uvm_config_db       #(vif_t)::get(this,"", "vif", vif);
	super.build_phase(phase);
endfunction: build_phase

function void base_mon::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
 endfunction: connect_phase

function void base_mon::end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase); 
endfunction: end_of_elaboration_phase


function void base_mon::start_of_simulation_phase(uvm_phase phase);
	super.start_of_simulation_phase(phase);
endfunction: start_of_simulation_phase

task base_mon::reset_phase(uvm_phase phase);
	super.reset_phase(phase);
	phase.raise_objection(this,"");
	active = 0;
	phase.drop_objection(this);
endtask: reset_phase

task base_mon::configure_phase(uvm_phase phase);
	super.configure_phase(phase);
	phase.raise_objection(this,"");
	phase.drop_objection(this);
endtask:configure_phase

task base_mon::gen_clk();
	p_gen_clk = process::self();
	fork
		forever begin
			clk = !clk;
			#half_period;
		end
	join_none
endtask : gen_clk

task base_mon::start_det(uvm_phase phase);
	if (ev_start!=null)
		forever begin
			ev_start.wait_trigger();
			if (active)
				`uvm_error(get_full_name(), "Can not start monitor which is already active. Expect a lot of further errors...")
			else
				active = 1;        
			fork
				gen_clk();
			join_none
		end
endtask

task base_mon::stop_det(uvm_phase phase);
	if (ev_stop!=null)
		forever begin
			ev_stop.wait_trigger();
			if (!active)
				`uvm_error(get_full_name(), "Can not stop monitor which is already stopped. Expect a lot of further errors...")
			else
				active = 0;
			@(negedge clk);
			p_gen_clk.kill();
		end
endtask



task base_mon::run_phase(uvm_phase phase);
	void'(uvm_config_db#(uvm_event)::get(this, "", "ev_start", ev_start));
	void'(uvm_config_db#(uvm_event)::get(this, "", "ev_stop", ev_stop));
	fork
		super.run_phase(phase);
		start_det(phase);
		stop_det(phase);
	join
endtask: run_phase

task base_mon::shutdown_phase(uvm_phase phase);
	if (active)
		`uvm_warning(get_full_name(), "Monitor is still active while shutting down.")
endtask

`endif // base_mon__SV
