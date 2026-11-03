/*
:name: test_component_default_domain_definition_populates_only_an_empty_schedule
:description: component default domain definition populates only an empty schedule
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.4.4.3 13.1.4.4.1 9.3.1.4.4 9.3.1.6.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_default_domain_definition_populates_only_an_empty_schedule.expected
*/
module test_component_default_domain_definition_populates_only_an_empty_schedule;
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
    automatic domain_actor selected=new("selected46",null);
    automatic domain_actor peer=new("peer46",null);
    automatic uvm_domain empty=new("empty46");
    automatic uvm_domain populated=new("populated46");
    uvm_phase existing;
    $display("UT: domain_before empty %0d",empty.find(uvm_pre_reset_phase::get())==null);
    selected.set_domain(empty,0);
    $display("UT: domain_after has_reset %0d has_main %0d",
             empty.find(uvm_pre_reset_phase::get())!=null,empty.find(uvm_main_phase::get())!=null);
    populated.add(uvm_main_phase::get()); existing=populated.find(uvm_main_phase::get());
    peer.set_domain(populated,0);
    $display("UT: domain_populated same_main %0d no_reset %0d",
             populated.find(uvm_main_phase::get())==existing,
             populated.find(uvm_pre_reset_phase::get())==null);
    $finish;
  end
endmodule
