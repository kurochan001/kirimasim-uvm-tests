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
