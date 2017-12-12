# uvm.vip

UVM.VIP allows creation of a custom VIP extending a Base VIP.

Table of Contents
-----------------

* [Base VIP](#basevip)
    * [Features](#features)
* [How to use](#howtouse)


Base VIP <a name="basevip"></a>
--------------------------

Base VIP is a fully featured UVM verification IP to be used as basis for building more complex verification IP customized to any specific need. 
<a name="features"></a>
* integrates score boarding (scbd) and comparator when needed:
	* driver (drv) versus monitor (mon) if configured as ACTIVE (default: PASSIVE)
	* composer (cpsr) versus monitor (mon) if configured to have a composer (default: no composer)
* integrates a register model adapter (adp) if configured to have an adapter (default: no adapter)
* integrates score board filtering to filter out specific transactions (default: filter forward all transactions to score board)
* integrates coverage collection if configured to have coverage (default: UVM_NO_COVERAGE)

How to use <a name="howtouse"></a>
--------------------------

Use Eclipse Oxygen for Java coming with Git integration

Use Java 9 w/JDK
http://www.oracle.com/technetwork/java/javase/downloads/jdk9-downloads-3848520.html
Install

Install Eclipse

Launch Eclipse
Install CDT for Eclipse via Install New Software

.....



Launching build:

Run > External tools > External tools configurations
Ant Build >
  Build.xml     /   Make sure Correct JRE is used
