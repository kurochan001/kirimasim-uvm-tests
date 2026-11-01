/*
:name: test_pool_global_accessors_share_a_singleton_and_leave_local_storage_independent
:description: global pool handles and keyed access share state without changing a local pool (IEEE 1800.2-2020 Section 11.2.2.2)
:tags: u11 uvm
:type: simulation
:lrm: 1800.2-2020 11.2.2.2 11.2.2.3 11.2.2.4 11.2.2.5 11.2.2.6 11.2.2.7 11.2.2.8 1800-2023 6.11.2 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pool_global_accessors_share_a_singleton_and_leave_local_storage_independent.expected
*/
module test_pool_global_accessors_share_a_singleton_and_leave_local_storage_independent;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  typedef bit [31:0] word_t;
  class warning_probe extends uvm_report_catcher;
    int warnings = 0;
    function new(); super.new("probe"); endfunction
    virtual function action_e catch();
      if (get_severity() == UVM_WARNING) begin warnings++; return CAUGHT; end
      return THROW;
    endfunction
  endclass

  initial begin
    uvm_pool#(string, word_t) first;
    uvm_pool#(string, word_t) second;
    automatic uvm_pool#(string, word_t) local_pool = new("local_pool");
    word_t value;
    first = uvm_pool#(string, word_t)::get_global_pool();
    second = uvm_pool#(string, word_t)::get_global_pool();
    local_pool.add("entry", 91); first.add("entry", 42);
    value = uvm_pool#(string, word_t)::get_global("entry");
    $display("UT: singleton %0d value %0d local %0d", first == second, value,
        local_pool.get("entry"));
    second.add("entry", 73);
    $display("UT: replacement shared %0d count %0d", first.get("entry") == 73, first.num());
    first.delete("entry");
    value = uvm_pool#(string, word_t)::get_global("entry");
    $display("UT: recreate default %0d present %0d count %0d local %0d", value,
             second.exists("entry"), second.num(), local_pool.get("entry"));
    $finish;
  end

endmodule
