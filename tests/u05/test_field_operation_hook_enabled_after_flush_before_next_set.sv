/*
:name: test_field_operation_hook_enabled_after_flush_before_next_set
:description: The hook-enable default is queried after flush before next set
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.7.2.7 5.7.2.9 5.7.2.8 5.7.2.2 6.6.3.2 6.6.5 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_field_operation_hook_enabled_after_flush_before_next_set.expected
*/
module test_field_operation_hook_enabled_after_flush_before_next_set;
  import uvm_pkg::*;
  class reports extends uvm_report_catcher;
    bit gated=0;
    int errors=0;
    virtual function action_e catch();
      if (gated && (get_severity()==UVM_ERROR || get_severity()==UVM_FATAL)) begin
        errors++; return CAUGHT;
      end
      return THROW;
    endfunction
  endclass
  initial begin
    uvm_field_op operation;
    uvm_copier policy;
    reports catcher;
    bit enabled;
    operation=new(); policy=new(); catcher=new();
    operation.set(UVM_COPY,policy); operation.disable_user_hook(); operation.flush();
    uvm_report_cb::add(null,catcher); catcher.gated=1;
    enabled=operation.user_hook_enabled(); catcher.gated=0;
    $display("UT: hook_default enabled %0d no_error %0d",enabled,catcher.errors==0);
    uvm_report_cb::delete(null,catcher);
    $finish;
  end
  initial begin #100; $fatal(1,"base-class fixture watchdog expired"); end
endmodule
