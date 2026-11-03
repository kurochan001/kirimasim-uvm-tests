/*
:name: test_reg_adapter_concrete_subclass_must_implement_reg2bus
:description: reg adapter concrete subclass must implement reg2bus (IEEE 1800.2-2020 Section 19.2.1.2.5)
:tags: u19 uvm
:type: elaboration
:lrm: 1800.2-2020 19.2.1.2.5 19.2.1.1 19.2.1.2.1 1800-2023 8.21 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a concrete subclass must implement the selected pure virtual method
:expected_stderr_regex: (?i)^(?=.*test_reg_adapter_concrete_subclass_must_implement_reg2bus\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:pure|virtual|abstract|missing implementation)\b)(?=.*\breg2bus\b).*error
*/
// Isolate one forbidden condition; other interfaces have original bodies.
// Rejection must identify this fixture and the selected method or parameter.
// This is a compile-stage expectation, without a runtime binary or seed.
module test_reg_adapter_concrete_subclass_must_implement_reg2bus;
  import uvm_pkg::*;
  class packet extends uvm_sequence_item;
    uvm_reg_bus_op operation;
    function new(); super.new("packet"); endfunction
  endclass
  class incomplete_adapter extends uvm_reg_adapter;
    virtual function void bus2reg(uvm_sequence_item value,ref uvm_reg_bus_op rw);
      packet result;
      if (!$cast(result,value)) return;
      rw = result.operation;
    endfunction
  endclass
  initial begin
    incomplete_adapter illegal_value;
    illegal_value = new();
  end
endmodule
