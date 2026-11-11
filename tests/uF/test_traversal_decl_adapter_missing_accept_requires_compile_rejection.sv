/*
:name: test_traversal_decl_adapter_missing_accept_requires_compile_rejection
:description: A concrete subtype implements the declared pure accept method.
:tags: uF uvm
:type: elaboration
:lrm: 1800.2-2020 F.5.3.2.2 F.5.1.1 F.5.1.2.1 F.5.1.2.2 F.5.1.2.3 F.5.2.1 F.5.2.2.1 F.5.2.2.2 F.5.3.1 F.5.3.2.1 F.5.4.1 F.5.4.2 F.5.5.1 F.5.5.2 F.5.6.1 F.5.6.2 F.5.7.1 F.5.7.2 F.5.7 5.3.1 5.3.2 5.3.4.2 13.1.2.1 1800-2023 6.21 8.13 8.17 8.20 8.21 8.22 8.25 13.5.2
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: Omit exactly the selected pure method in a directly instantiated concrete subtype.
:expected_stderr_regex: (?i)^(?=.*test_traversal_decl_adapter_missing_accept_requires_compile_rejection\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:pure|virtual|abstract|missing implementation)\b)(?=.*\baccept\b).*error
*/
// What it checks:
// A concrete subtype implements the declared pure accept method.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.5.3.2.2
// (UVM-TRAVERSAL-DECL-ADAPTER-MISSING-ACCEPT-REQUIRES-COMPILE-REJECTION) gives
// the rule above. Setup: Omit exactly the selected pure method in a directly
// instantiated concrete subtype. Expected: The compiler rejects the selected
// illegal condition with its fixture/type/method diagnostic.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original declarations and observations derived from the cited standards.
module
  test_traversal_decl_adapter_missing_accept_requires_compile_rejection;
  import uvm_pkg::*;
  class incomplete69 extends
      uvm_visitor_adapter#(uvm_component,uvm_visitor#(uvm_component));
  endclass
  initial begin
    incomplete69 illegal_value;
    illegal_value=new();
  end
endmodule
