# uvm.vip

UVM.VIP allows creation of a custom VIP extending a Base VIP.

Table of Contents
-----------------

[**Base VIP**](#basevip)D
* [**Features**](#features)

<br />

<a name="basevip"></a>
Base VIP (TL;DR)
--------------------------

Base VIP is a fully featured UVM verification IP to be used as basis for building more complex verification IP customized to any specific need. 
<a name="features"></a>
* integrates score boarding (scbd) and comparator when needed:
	* driver (drv) versus monitor (mon) if configured as ACTIVE (default: PASSIVE)
	* composer (cpsr) versus monitor (mon) if configured to have a composer (default: no composer)
* integrates a register model adapter (adp) if configured to have an adapter (default: no adapter)
* integrates score board filtering to filter out specific transactions (default: filter forward all transactions to score board)
* integrates coverage collection if configured to have coverage (default: UVM_NO_COVERAGE)

