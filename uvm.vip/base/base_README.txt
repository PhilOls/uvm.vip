Base VIP is a fully featured vip
- integrates score boarding (scbd) and comparator when needed:
	> driver (drv) versus monitor (mon) if configured as ACTIVE (default: PASSIVE)
	> composer (cpsr) versus monitor (mon) if configured to have a composer (default: no composer)
- integrates a register model adapter (adp) if configured to have an adapter (default: no adapter)
- integrates score board filtering to filter out specific transactions (default: filter forward all transactions to score board)
- integrates coverage collection if configured to have coverage (default: UVM_NO_COVERAGE)

-----------------
Hierarchy:
	env:						vip top 
		mst_agt:				agent for master functionality
		slv_agt:				agent for slave functionality
		sb_mon2drv:			score board monitor <> driver
		sb_mon2cpsr:			score board monitor <> composer
		filt_sb_mon2drv:		filter between monitor and score board for mon <> drv
		filt_sb_mon2cpsr:	filter between monitor and score board for mon <> cpsr
		cpsr:				composer
		cov:					coverage collector
		mon2cov:				coverage connector between monitor and collector
		reg_predictor:		register model predictor (standard uvm_reg_predictor)
		adp:					register model adapter
		
	agent
		sqr:					seauencer (if configured as UVM_ACTIVE (default: passive)
		drv:					driver (if configured as UVM_ACTIVE (default: passive)
		mon:					monitor
-------------------
Generic parameters:
	vif_t:					virtual interface type (default: virtual base_if)
	cfg-t:					configuration object type (default: base_cfg)
	txn_t:					transaction type (default: base_txn)
	reg_model_t:				register model type (default: uvm_reg_block)
-------------------
Configuration parameters (defined in base_cfg):
	coverage:				coverage configuration (default: UVM_NO_COVERAGE)
	active_passive:			active/passive	(default: UVM_PASSIVE)
	sb_verbosity_level:		score board verbosity (default: UVM_NONE), set to UVM_HIGH to display transactions on scoreboard matches)
	master_slave:			master or slave (default:SLAVE)
	composer:				composer required (default: no composer)
	adapter:					adapter required (default: no adapter)		
	
	

	
