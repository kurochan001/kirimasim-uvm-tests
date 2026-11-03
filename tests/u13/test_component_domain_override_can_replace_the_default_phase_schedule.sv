/*
:name: test_component_domain_override_can_replace_the_default_phase_schedule
:description: component domain override can replace the default phase schedule
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.4.4.3 13.1.4.4.1 9.3.1.6.1 9.3.1.4.4 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_domain_override_can_replace_the_default_phase_schedule.expected
*/
module test_component_domain_override_can_replace_the_default_phase_schedule;
  import uvm_pkg::*;
  class custom_actor extends uvm_component;
    bit called=0;
    uvm_domain seen;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    protected virtual function void define_domain(uvm_domain domain);
      called=1; seen=domain; domain.add(uvm_main_phase::get());
    endfunction
  endclass
  initial begin
    automatic custom_actor actor=new("actor46",null);
    automatic uvm_domain domain=new("custom46");
    automatic uvm_component view=actor;
    view.set_domain(domain,0);
    $display("UT: domain_override callback %0d selected %0d main %0d no_reset %0d",
             actor.called && actor.seen==domain,actor.get_domain()==domain,
             domain.find(uvm_main_phase::get())!=null,
             domain.find(uvm_pre_reset_phase::get())==null);
    $finish;
  end
endmodule
