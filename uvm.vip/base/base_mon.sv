//
// Template for UVM-compliant basesical-level monitor
//

`ifndef base_mon__SV
`define base_mon__SV

class base_mon extends uvm_monitor;

   `uvm_component_utils(base_mon)

   bit                        active = 0;
   bit                        bypass = 0;
   uvm_event                  ev_start;
   uvm_event                  ev_stop;

   string                     prefix = "base";

   extern function new(string name = "base_mon",uvm_component parent);

   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void end_of_elaboration_phase(uvm_phase phase);
   extern virtual function void start_of_simulation_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);
   extern virtual task reset_phase(uvm_phase phase);
   extern virtual task configure_phase(uvm_phase phase);
   extern virtual task run_phase(uvm_phase phase);
   extern virtual task start_det(uvm_phase phase);
   extern virtual task stop_det(uvm_phase phase);
   extern virtual task shutdown_phase(uvm_phase phase);

endclass: base_mon


function base_mon::new(string name = "base_mon",uvm_component parent);
   super.new(name, parent);
endfunction: new

function void base_mon::build_phase(uvm_phase phase);
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


task base_mon::start_det(uvm_phase phase);
  if (ev_start!=null)
    fork
      forever begin
        ev_start.wait_trigger();
        if (active)
          `uvm_error(get_full_name(), "Can not start monitor which is already active. Expect a lot of further errors...")
        else
          active = 1;
      end
    join_none
endtask

task base_mon::stop_det(uvm_phase phase);
  if (ev_stop!=null)
    fork
      forever begin
        ev_stop.wait_trigger();
        if (!active)
          `uvm_error(get_full_name(), "Can not stop monitor which is already stopped. Expect a lot of further errors...")
        else
          active = 0;
      end
    join_none
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
