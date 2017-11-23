# uvm.vip
UVM.VIP allows creation of a custom VIP extending a Base VIP.

Base VIP is a fully featured vip
- integrates score boarding (scbd) and comparator when needed:
	> driver (drv) versus monitor (mon) if configured as ACTIVE (default: PASSIVE)
	> composer (cpsr) versus monitor (mon) if configured to have a composer (default: no composer)
- integrates a register model adapter (adp) if configured to have an adapter (default: no adapter)
- integrates score board filtering to filter out specific transactions (default: filter forward all transactions to score board)
- integrates coverage collection if configured to have coverage (default: UVM_NO_COVERAGE)

