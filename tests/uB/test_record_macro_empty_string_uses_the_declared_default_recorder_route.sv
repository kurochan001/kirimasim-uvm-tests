/*
:name: test_record_macro_empty_string_uses_the_declared_default_recorder_route
:description: Original record macro empty string uses the declared default recorder route under a live transaction recorder
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.2.3.3 B.2.3 B.2.3.1 5.3.7.1 5.3.7.2 5.4.2.4 5.4.2.6 5.4.2.8 16.4.2.1 16.4.5.1 16.4.5.2 16.4.6.1 16.4.6.3 16.4.6.5 16.4.6.6 16.4.6.7 16.4.6.8 16.4.6.9 16.4.7.1 16.4.7.2 16.4.7.3 16.4.7.4 16.4.7.5 16.4.7.6 16.4.7.9 16.4.7.10 16.4.7.11 7.1.4.1 7.1.3.1 7.1.6.1 7.1.6.2 7.1.6.3 7.1.6.4 7.2.5.1 1800-2023 6.21 6.24 8.20 8.21 13.5.2 21.2.1
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers68/recording_fixture68.svh
:expected_exit: 0
:expected_stdout: @test_record_macro_empty_string_uses_the_declared_default_recorder_route.expected
*/
// What it checks:
// The default recording macro forwards the selected name/value and metadata to
// its declared recorder interface.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.2.3.3 (UVM-MACRO-IO-AUDIT-RECORD-DEFAULT-EMPTY-STRING) gives
// the rule above. Setup: Use the unmodified default recording macros with
// attribute support disabled, an open original recorder and a live handle
// obtained through transaction begin_tr. Keep a separate peer recorder.
// Expected: The selected original recording hook receives the exact value/name
// and applicable size/radix or required generic conversion, preserving the
// other recorder.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Expected values are original; no serialized stream layout is prescribed.
module
  test_record_macro_empty_string_uses_the_declared_default_recorder_route;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "recording_fixture68.svh"
  typedef struct packed {bit [12:0] code;bit [7:0] mode;} sample68;
  int peer_handle68;
  class subject68 extends uvm_object;
    int do_record_entries68=0;
    string value="";
    function new();super.new("subject68");endfunction
    virtual function void do_record(uvm_recorder recorder);
      do_record_entries68++;
      `uvm_record_string("tag68",value);
    endfunction
  endclass
  initial begin
    automatic recorder68 recorder=new("selected68"),peer=new("peer68");
    automatic transaction68 selected_transaction=new(),peer_transaction=new();
    automatic subject68 subject=new();
    activate68(recorder,selected_transaction);activate68(peer,peer_transaction);
    peer_handle68=peer.get_handle();subject.record(recorder);
    $display("UT: %s delegated %0d isolated %0d",
      "record_empty_string",recorder.string_calls==1 && recorder.string_name=="tag68" &&
         recorder.string_value==subject.value,
      peer.calls68()==0 && recorder.calls68()==1);
    $display("DETAIL: %s fields %0d ints %0d generic %0d handles %0d",
      "record_empty_string",recorder.field_calls,recorder.int_calls,
      recorder.generic_calls,recorder.handle_queries);
    $display("DETAIL: macro_entries %0d",subject.do_record_entries68);
  selected_transaction.end_tr();peer_transaction.end_tr();$finish;
  end
endmodule
