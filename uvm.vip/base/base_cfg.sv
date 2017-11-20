
`ifndef base_CFG__SV
`define base_CFG__SV

class base_cfg extends uvm_object;

  uvm_coverage_model_e         coverage            = UVM_NO_COVERAGE;
  uvm_active_passive_enum      active_passive;

  uvm_verbosity                sb_verbosity_level  = UVM_NONE; //Set to high to display scoreboard matches

  base_vip_pkg::master_slave_e master_slave        = base_vip_pkg::SLAVE;

  bit                          monitor             = 1;
  bit                          composer            = 0;
  bit                          adapter             = 0;


  `uvm_object_utils_begin(base_cfg)
    `uvm_field_enum(uvm_coverage_model_e, coverage, UVM_ALL_ON)
    `uvm_field_enum(uvm_active_passive_enum, active_passive, UVM_ALL_ON)
    `uvm_field_enum(uvm_verbosity, sb_verbosity_level, UVM_ALL_ON)
    `uvm_field_enum(base_vip_pkg::master_slave_e, master_slave, UVM_ALL_ON)
    `uvm_field_int(monitor,UVM_ALL_ON)
    `uvm_field_int(composer,UVM_ALL_ON)
    `uvm_field_int(adapter,UVM_ALL_ON)
  `uvm_object_utils_end
   ;
   extern function new(string name = "base_cfg");
  
endclass: base_cfg

function base_cfg::new(string name);
   super.new(name);
endfunction: new


`endif // base_CFG__SV
