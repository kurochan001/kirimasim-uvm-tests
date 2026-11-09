/*
:name: test_component_domain_selection_inherits_by_default_and_distinguishes_local_updates
:description: component domain selection inherits by default and distinguishes local updates
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.4.4.1 13.1.4.4.2 13.1.4.4.3 9.4.2.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_domain_selection_inherits_by_default_and_distinguishes_local_updates.expected
*/
// What it checks:
// 1. New selected components use the registered uvm domain.
// 2. The omitted hier argument recursively applies the selected domain to the
//    receiver and descendants.
// 3. Explicit hier zero changes only the receiver and preserves its parent,
//    child and independent peer domains.
// 4. The public domain getter returns the exact selected domain after
//    inherited and local updates.
// 5. set_domain invokes the selected component virtual define_domain hook with
//    the supplied domain.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 13.1.4.4.1 (UVM-COMPONENT-AUDIT-DOMAIN-DEFAULT) gives rule 1
//    above. Setup: Use the selected original concrete component subtypes,
//    legal unique names, declared public types and linked observations.
//    Construct the hierarchy before phasing where phase callbacks are
//    observed. Expected: New selected components use the registered uvm
//    domain.
// 2. 1800.2-2020 13.1.4.4.1 (UVM-COMPONENT-AUDIT-DOMAIN-HIER-DEFAULT) gives
//    rule 2 above. Setup: Use the selected original concrete component
//    subtypes, legal unique names, declared public types and linked
//    observations. Construct the hierarchy before phasing where phase
//    callbacks are observed. Expected: The omitted hier argument recursively
//    applies the selected domain to the receiver and descendants.
// 3. 1800.2-2020 13.1.4.4.1 (UVM-COMPONENT-AUDIT-DOMAIN-LOCAL-UPDATE) gives
//    rule 3 above. Setup: Use the selected original concrete component
//    subtypes, legal unique names, declared public types and linked
//    observations. Construct the hierarchy before phasing where phase
//    callbacks are observed. Expected: Explicit hier zero changes only the
//    receiver and preserves its parent, child and independent peer domains.
// 4. 1800.2-2020 13.1.4.4.2 (UVM-COMPONENT-AUDIT-DOMAIN-GET-HANDLE) gives rule
//    4 above. Setup: Use the selected original concrete component subtypes,
//    legal unique names, declared public types and linked observations.
//    Construct the hierarchy before phasing where phase callbacks are
//    observed. Expected: The public domain getter returns the exact selected
//    domain after inherited and local updates.
// 5. 1800.2-2020 13.1.4.4.1 (UVM-COMPONENT-AUDIT-DOMAIN-DEFINE-CALLBACK) gives
//    rule 5 above. Setup: Use the selected original concrete component
//    subtypes, legal unique names, declared public types and linked
//    observations. Construct the hierarchy before phasing where phase
//    callbacks are observed. Expected: set_domain invokes the selected
//    component virtual define_domain hook with the supplied domain.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_component_domain_selection_inherits_by_default_and_distinguishes_local_updates;
  import uvm_pkg::*;
  class domain_actor extends uvm_component;
    int callbacks=0;
    uvm_domain seen;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    protected virtual function void define_domain(uvm_domain domain);
      callbacks++; seen=domain; super.define_domain(domain);
    endfunction
  endclass
  initial begin
    automatic domain_actor root=new("root46",null);
    automatic domain_actor child=new("child",root);
    automatic domain_actor grand=new("grand",child);
    automatic domain_actor peer=new("peer46",null);
    automatic uvm_domain selected=new("selected46");
    automatic uvm_domain local_domain=new("local46");
    uvm_domain domains[string];
    uvm_domain::get_domains(domains);
    if (!domains.exists("uvm")) $fatal(1,"standard domain missing");
    $display("UT: default_domains root %0d child %0d grand %0d peer %0d",
             root.get_domain()==domains["uvm"],child.get_domain()==domains["uvm"],
             grand.get_domain()==domains["uvm"],peer.get_domain()==domains["uvm"]);
    root.callbacks=0; root.set_domain(selected);
    $display("UT: inherited_domains root %0d child %0d grand %0d peer %0d callback %0d",
             root.get_domain()==selected,child.get_domain()==selected,grand.get_domain()==selected,
             peer.get_domain()==domains["uvm"],root.callbacks>0 && root.seen==selected);
    child.callbacks=0; child.set_domain(local_domain,0);
    $display("UT: local_domain root %0d child %0d grand %0d peer %0d callback %0d",
             root.get_domain()==selected,child.get_domain()==local_domain,
             grand.get_domain()==selected,peer.get_domain()==domains["uvm"],
             child.callbacks>0 && child.seen==local_domain);
    $finish;
  end
endmodule
