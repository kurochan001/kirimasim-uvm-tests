/*
:name: test_event_object_trigger_data_retains_live_handle_aliases_replacement_and_null
:description: event object trigger data retains live handle aliases replacement and null (IEEE 1800.2-2020 Section 10.1.2.2.5)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.1.2.2.5 10.1.2.1 10.1.2.2.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_event_object_trigger_data_retains_live_handle_aliases_replacement_and_null.expected
*/
// What it checks:
// 1. The event data getter returns the supplied object handle from the latest
//    trigger.
// 2. Returned object data remains a live alias of the supplied payload.
// 3. Later explicit object and null triggers replace the current data without
//    changing an earlier returned handle.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.1.2.2.5 (UVM-SYNC-REVIEW-OBJECT-DATA-IDENTITY) gives rule
//    1 above. Setup: Trigger with an original payload object and read the data
//    handle. Expected: The returned handle denotes the supplied object.
// 2. 1800.2-2020 10.1.2.2.5 (UVM-SYNC-REVIEW-OBJECT-DATA-LIVE-ALIAS) gives
//    rule 2 above. Setup: Mutate first through the original object and then
//    through its returned view. Expected: The view sees thirty-five and the
//    original later sees forty-seven.
// 3. 1800.2-2020 10.1.2.2.5 (UVM-SYNC-REVIEW-OBJECT-DATA-REPLACEMENT-NULL)
//    gives rule 3 above. Setup: Trigger a second payload and then explicit
//    null after retaining the first result. Expected: The latest getter
//    follows each replacement while the saved handle still denotes the first
//    payload.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Trigger data of object type is a supplied handle value, not an implicit
// clone. Inspect only accepted explicit payloads, including explicit null.
// Previously returned handles retain ordinary class aliasing; no default data,
// pre-trigger contents, ownership transfer or deep-copy policy is inferred.
module test_event_object_trigger_data_retains_live_handle_aliases_replacement_and_null;
  import uvm_pkg::*;
  class payload extends uvm_object;
    int value;
    function new(int selected); super.new("payload"); value = selected; endfunction
  endclass
  initial begin
    automatic uvm_event subject = new("subject");
    automatic payload first = new(13);
    automatic payload second = new(27);
    uvm_object saved;
    payload view;
    subject.trigger(first); saved = subject.get_trigger_data();
    if (!$cast(view,saved)) $fatal(1,"wrong original payload");
    first.value = 35;
    $display("UT: event_data_alias identity %0d live %0d",saved == first,view.value);
    view.value = 47;
    subject.trigger(second);
    $display("UT: event_data_replacement current %0d retained %0d first_value %0d second_value %0d",
             subject.get_trigger_data() == second,saved == first,first.value,second.value);
    subject.trigger(null);
    $display("UT: event_data_null current %0d retained %0d",subject.get_trigger_data() == null,
             saved == first);
    $finish;
  end
endmodule
