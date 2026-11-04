/*
:name: test_resource_pool_null_scope_insertion_warns_and_leaves_registered_resources_unchanged
:description: Inserting a null resource generates WARNING without altering a registered control
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.4.3.1 C.2.4.4.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_pool_null_scope_insertion_warns_and_leaves_registered_resources_unchanged.expected
*/
module test_resource_pool_null_scope_insertion_warns_and_leaves_registered_resources_unchanged;
  import uvm_pkg::*;

  class report_probe extends uvm_report_catcher;
    bit gated=0;
    int messages=0,warnings=0,errors=0;
    virtual function action_e catch();
      if (!gated) return THROW;
      messages++; warnings+=get_severity()==UVM_WARNING; errors+=get_severity()==UVM_ERROR;
      return CAUGHT;
    endfunction
  endclass

  initial begin
    automatic uvm_resource_pool pool=new();
    automatic uvm_resource#(int) resource=new("slot58");
    automatic report_probe reports=new();
    uvm_resource_types::rsrc_q_t values;
    pool.set_scope(resource,"scope58"); uvm_report_cb::add(null,reports);
    reports.gated=1; pool.set_scope(null,"scope58"); reports.gated=0;
    values=pool.lookup_name("scope58","slot58",uvm_resource#(int)::get_type(),0);
    $display("UT: null_scope warning %0d intact %0d",reports.warnings>0,
      values.size()==1 && values.get(0)==resource);
    $finish;
  end
endmodule
