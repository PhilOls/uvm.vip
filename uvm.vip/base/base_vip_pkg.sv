`include "uvm_macros.svh"

`include "base/base_if.sv"

package base_vip_pkg;

  typedef enum {MASTER, SLAVE, NONE} master_slave_e;

  import uvm_pkg::*;

  `include "base_txn.sv"
  `include "base_cfg.sv"
  `include "base_mon.sv"
  `include "base_cov.sv"
  `include "base_mon2cov.sv"
  `include "base_drv.sv"
  `include "base_cpsr.sv"
  `include "base_seq_lib.sv"
  `include "base_agent.sv"
  `include "base_adp.sv"
  `include "base_filter.sv"
  `include "basde_in_order_comparator.sv"
  `include "base_scbd.sv"
  `include "base_env.sv"

endpackage
