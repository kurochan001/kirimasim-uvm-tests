/*
:name: test_push_driver_export_dispatches_an_override_before_the_default_put_error
:description: push driver export dispatches an override before the default put error
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.8.2.1 12.2.2.1 6.6.5 D.4.4 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_push_driver_export_dispatches_an_override_before_the_default_put_error.expected
*/
module test_push_driver_export_dispatches_an_override_before_the_default_put_error;
  import uvm_pkg::*;
  class request_item extends uvm_sequence_item; endclass
  class original_driver extends uvm_push_driver#(request_item);
    request_item received;
    bit completed=0;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    virtual task put(request_item value);
      received=value; #2; completed=1;
    endtask
  endclass
  class stop_on_error extends uvm_report_catcher;
    int errors=0;
    bit terminal=0;
    virtual function action_e catch();
      if (get_severity() inside {UVM_ERROR,UVM_FATAL}) begin
        errors++;
        if (terminal) begin $display("UT: default_push_put_error 1"); $finish; end
        return CAUGHT;
      end
      return THROW;
    endfunction
  endclass
  initial begin
    automatic original_driver original=new("original46",null);
    automatic uvm_push_driver#(request_item) stock=new("stock46",null);
    automatic request_item item=new();
    automatic stop_on_error probe=new();
    automatic time before_put=$time;
    uvm_report_cb::add(null,probe);
    original.req_export.put(item);
    $display("UT: overridden_push_put same %0d completed %0d blocked %0d no_error %0d",
             original.received==item,original.completed,$time-before_put>=2,probe.errors==0);
    // No super.put in the override. Stop inside our catcher on the stock error.
    probe.terminal=1; stock.req_export.put(item);
    $fatal(1,"missing expected default put error");
  end
endmodule
