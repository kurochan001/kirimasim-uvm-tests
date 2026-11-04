/*
:name: test_resource_read_only_failure_does_not_notify_a_pending_modification_waiter
:description: A rejected read-only write changes neither resource storage nor a pending modification notification
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.5.4.2 C.2.3.4 C.2.3.3.1 C.3.2.3.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_read_only_failure_does_not_notify_a_pending_modification_waiter.expected
*/
module test_resource_read_only_failure_does_not_notify_a_pending_modification_waiter;
  import uvm_pkg::*;
  typedef bit [7:0] word_type;

  class report_probe extends uvm_report_catcher;
    bit gated=0;
    int messages=0,warnings=0,errors=0;
    virtual function action_e catch();
      if (!gated) return THROW;
      messages++; warnings+=get_severity()==UVM_WARNING; errors+=get_severity()==UVM_ERROR;
      return CAUGHT;
    endfunction
  endclass

  uvm_resource#(word_type) resource;
  bit woke=0;
  initial begin
    automatic report_probe reports=new();
    resource=uvm_resource_db#(word_type)::set_default("scope58","readonly58");
    if (resource==null) $fatal(1,"missing default resource");
    resource.set_read_only(); uvm_report_cb::add(null,reports);
    fork begin resource.wait_modified(); woke=1; end join_none
    #1; reports.gated=1; resource.write('h58); reports.gated=0; #1;
    $display("UT: read_only_notify error %0d unchanged %0d still_waiting %0d",
      reports.errors>0,resource.read()==0,!woke);
    disable fork; $finish;
  end
endmodule
