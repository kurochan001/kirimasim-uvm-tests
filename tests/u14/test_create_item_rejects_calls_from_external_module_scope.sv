/*
:name: test_create_item_rejects_calls_from_external_module_scope
:description: A sequence's protected create_item cannot be called by an external module (IEEE 1800.2-2020 Section 14.2.6.1)
:tags: u14 uvm
:type: elaboration
:lrm: 1800.2-2020 14.2.6.1 1800-2023 8.18 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: module scope cannot call the protected create_item method
:expected_stderr_regex: (?i)^(?=.*test_create_item_rejects_calls_from_external_module_scope\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:protected|private|inaccessible)\b)(?=.*\bcreate_item\b).*error
*/
// Section 14.2.6.1 declares create_item protected. The companion positive
// test calls it inside a derived sequence. Here only the caller changes. The
// rejection must identify this file, the method and the accessibility error.
module test_create_item_rejects_calls_from_external_module_scope;
  import uvm_pkg::*;
  class client extends uvm_sequence #(uvm_sequence_item);
  endclass

  initial begin
    automatic client seq_value = new;
    uvm_sequence_item product;
    product = seq_value.create_item(uvm_sequence_item::get_type(), null, "item");
  end
endmodule
