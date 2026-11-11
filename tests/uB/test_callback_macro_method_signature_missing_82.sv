/*
:name: test_callback_macro_method_signature_missing_82
:description: The callback METHOD must exist with a signature accepting the supplied arguments
:tags: uB uvm
:type: elaboration
:lrm: 1800.2-2020 B.4.3 B.4.1 10.7.2.2.1 10.7.2.2.2 1800-2023 6.21 8.20 8.23 8.25 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers82/callbacks82.svh
:should_fail_because: callback METHOD must have the required hook82 signature
:expected_stderr_regex: (?i)^(?=.*test_callback_macro_method_signature_missing_82\.sv:[0-9]+:[0-9]+:)(?=.*\bhook82\b)(?=.*(?:not found|unknown|no such|member)).*error
*/
// What it checks:
// The CB class method signature must accept the METHOD invocation supplied to
// the macro.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.4.3 (UVM-CALLBACK-MACRO-METHOD-SIGNATURE-CONSTRAINT) gives the
// rule above. Setup: Original legal object/callback derivatives use actual
// registration and implicit dispatch macros. Cases include global/class-local
// aliases of parameterized callbacks, shared handles in separate instance
// queues, explicit mode0/1, related/unrelated callback families, inherited
// typewide state and completed-call reconfiguration. METHOD receives original
// object/token and mutable reference arguments. No factory-utility
// prerequisite is added. Expected: Missing-method and incompatible-argument
// designs reject with the declared fixture/member diagnostic and execute no
// runtime seed.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original callback arithmetic/trace is stimulus; no private registration bits.
module test_callback_macro_method_signature_missing_82;
  import uvm_pkg::*;
  `include "callbacks82.svh"
  class bad_callback82 extends uvm_callback;
    function new(); super.new("bad82"); endfunction
    function void unrelated82(); endfunction
  endclass
  class bad_owner82 extends uvm_object;
    `uvm_register_cb(bad_owner82,bad_callback82)
    function new(); super.new("bad_owner82"); endfunction
    function void fire82(input int token,ref int acc,ref string trace);
      `uvm_do_callbacks(bad_owner82,bad_callback82,hook82(this,token,acc,trace))
    endfunction
  endclass
  initial begin
    automatic bad_owner82 target=new();
    int acc;
    string trace;
    acc=0; trace=""; target.fire82(1,acc,trace);
    $finish;
  end
endmodule
