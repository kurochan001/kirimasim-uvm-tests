/*
:name: test_record_macro_attribute_real_fourth_argument_compatibility_control
:description: Separate typed attribute control permits the unlisted fourth recorder argument without replacing the printed three-argument input
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.2.3.5 B.2.3 B.2.3.1 5.3.7.1 5.3.7.2 5.4.2.4 5.4.2.6 5.4.2.8 16.4.2.1 16.4.5.1 16.4.5.2 16.4.6.1 16.4.6.3 16.4.6.5 16.4.6.6 16.4.6.7 16.4.6.8 16.4.6.9 16.4.7.1 16.4.7.2 16.4.7.3 16.4.7.4 16.4.7.5 16.4.7.6 16.4.7.9 16.4.7.10 16.4.7.11 7.1.4.1 7.1.3.1 7.1.6.1 7.1.6.2 7.1.6.3 7.1.6.4 7.2.5.1 1800-2023 6.21 6.24 8.20 8.21 13.5.2 21.2.1
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers68/recording_fixture68.svh
:expected_exit: 0
:expected_stdout: @test_record_macro_attribute_real_fourth_argument_compatibility_control.expected
*/
// What it checks:
// It is a control: it supports the setup or conditions of this duty, which
// other tests check directly:
// The enabled recording macro forwards the original typed value to the
// user-specific attribute API.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.2.3.5 (UVM-MACRO-IO-AUDIT-RECORD-ATTRIBUTE-REAL) gives the
// rule above. Setup: Enable recorder attribute support and provide an original
// user-specific attribute macro whose VALUE binds to an exact const-ref type.
// Use a valid transaction recorder and an overridden tool handle, without
// changing the surrounding recording macro. Keep the printed three-argument
// attribute definition; the separate compatibility control tolerates an
// unlisted fourth recorder argument and does not pass this original premise.
// Expected: The exact typed value and name reach the original capture function
// with the overridden tool handle, without recorder-policy fallback.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Expected values are original; no serialized stream layout is prescribed.
module
  test_record_macro_attribute_real_fourth_argument_compatibility_control;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "recording_fixture68.svh"
  typedef real sample_t;
  sample_t expected68;
  int captures68=0;
  bit capture_ok68=0;
  function automatic void capture68(int handle_value,string name,const ref sample_t value);
    captures68++;capture_ok68=handle_value==4343 && name=="tag68" && value==expected68;
  endfunction
  `undef uvm_record_attribute
  `define uvm_record_attribute(TR_HANDLE,NAME,VALUE,EXTRA_RECORDER68) begin \
    capture68(TR_HANDLE,NAME,VALUE); end
  class subject68 extends uvm_object;
    int do_record_entries68=0;
    sample_t value;
    function new();super.new("subject68");endfunction
    virtual function void do_record(uvm_recorder recorder);
      do_record_entries68++;
      `uvm_record_real("tag68",value);
    endfunction
  endclass
  initial begin
    automatic recorder68 recorder=new();
    automatic transaction68 transaction=new();
    automatic subject68 subject=new();
    expected68=-12.75;
    subject.value=expected68;activate68(recorder,transaction);recorder.attributes=1;
    subject.record(recorder);
    $display("UT: %s calls %0d typed_value %0d handle %0d fallback %0d",
      "record_attribute_real",captures68,capture_ok68,
      recorder.handle_queries>0,recorder.calls68());
    $display("DETAIL: macro_entries %0d",subject.do_record_entries68);
  transaction.end_tr();$finish;
  end
endmodule
