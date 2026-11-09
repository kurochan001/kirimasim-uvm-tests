/*
:name: test_component_enabled_recording_defers_properties_until_end_and_honors_free_handle
:description: component recording defers properties until end and honors recorder retention (IEEE 1800.2-2020 Section 13.1.7.5)
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.7.5 13.1.7.3 13.1.7.4 13.1.7.6 13.1.7.9 13.1.7.11 13.1.7.13 5.3.7.2 16.4.4.4 16.4.4.6 16.4.5.1 16.4.5.2 16.4.3 13.1.2.1 13.1.3.2 7.1.3.1 7.1.4.1 7.1.6.1 7.1.6.2 7.1.6.3 7.1.6.4 7.2.3.1 7.2.3.2 7.2.3.3 7.2.5.1 7.2.7.1 7.2.7.2 7.2.7.3 7.2.7.4 16.4.7.1 16.4.7.2 16.4.7.3 16.4.7.4 16.4.7.5 16.4.7.6 16.4.7.9 16.4.7.10 16.4.7.11 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_enabled_recording_defers_properties_until_end_and_honors_free_handle.expected
*/
// What it checks:
// 1. Enabled component begin opens a recorder without recording transaction
//    properties.
// 2. Enabled component end records properties after its post-end hook.
// 3. Ending with free_handle zero closes the recorder without freeing it.
// 4. Default component end frees its recorder after closing it.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 13.1.7.3 (UVM-COMPONENT-BEGIN-DEFERS-PROPERTY-RECORDING)
//    gives rule 1 above. Setup: Enable component recording but disable
//    transaction self-recording. Expected: The recorder is open, the begin
//    hook receives its nonzero handle and property-hook count remains zero.
// 2. 1800.2-2020 13.1.7.5 (UVM-COMPONENT-END-RECORDS-AFTER-POST-HOOK) gives
//    rule 2 above. Setup: End two transactions with the same local stream.
//    Expected: Each transaction records once and the first post-end hook
//    observes no prior property record.
// 3. 1800.2-2020 13.1.7.5 (UVM-COMPONENT-END-RETAINS-CLOSED-RECORDER) gives
//    rule 3 above. Setup: End the first transaction with free_handle
//    explicitly zero. Expected: The recorder is closed, has no free hook and
//    its handle still resolves exactly.
// 4. 1800.2-2020 13.1.7.5 (UVM-COMPONENT-END-DEFAULT-FREES-RECORDER) gives
//    rule 4 above. Setup: End a second transaction without a free_handle
//    argument. Expected: There is one close and one free, its old handle
//    becomes invalid and the retained peer remains valid.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use local in-memory recording hooks, explicit timestamps and named objects.
// No external database format, vendor attributes, events or DPI are observed.
module test_component_enabled_recording_defers_properties_until_end_and_honors_free_handle;
  import uvm_pkg::*;

  class local_recorder extends uvm_recorder;
    int opens = 0;
    int closes = 0;
    int frees = 0;
    function new(string name="recorder"); super.new(name); endfunction
    protected virtual function void do_open(uvm_tr_stream stream, time open_time,
    string type_name); opens++; endfunction
    protected virtual function void do_close(time close_time); closes++; endfunction
    protected virtual function void do_free(); frees++; endfunction
    protected virtual function void do_record_field(string name, uvm_bitstream_t value, int size,
    uvm_radix_enum radix); endfunction
    protected virtual function void do_record_field_int(string name, uvm_integral_t value,
    int size, uvm_radix_enum radix); endfunction
    protected virtual function void do_record_field_real(string name, real value); endfunction
    protected virtual function void do_record_string(string name, string value); endfunction
    protected virtual function void do_record_time(string name, time value); endfunction
    protected virtual function void do_record_generic(string name, string value,
    string type_name); endfunction
  endclass
  class local_stream extends uvm_tr_stream;
    local_recorder created[$];
    function new(string name="stream"); super.new(name); endfunction
    protected virtual function void do_open(uvm_tr_database db, string scope,
    string stream_type_name); endfunction
    protected virtual function void do_close(); endfunction
    protected virtual function void do_free(); endfunction
    protected virtual function uvm_recorder do_open_recorder(string name, time open_time,
    string type_name);
      local_recorder result_value = new(name); created.push_back(result_value); return result_value;
    endfunction
  endclass
  class local_database extends uvm_tr_database;
    int stream_calls = 0;
    function new(string name="db"); super.new(name); endfunction
    protected virtual function bit do_open_db(); return 1; endfunction
    protected virtual function bit do_close_db(); return 1; endfunction
    protected virtual function uvm_tr_stream do_open_stream(string name, string scope,
    string type_name);
      local_stream result_value = new(name); stream_calls++; return result_value;
    endfunction
    protected virtual function void do_establish_link(uvm_link_base link); endfunction
  endclass
  class transaction extends uvm_transaction;
    int records = 0;
    function new(string name="tr"); super.new(name); endfunction
    function void do_record(uvm_recorder recorder); records++; endfunction
  endclass
  class observer extends uvm_component;
    int accepts = 0;
    int begins = 0;
    int ends = 0;
    uvm_transaction seen;
    string stream_seen;
    int begin_handle;
    int end_handle;
    time accepted_at_hook;
    time begun_at_hook;
    time ended_at_hook;
    int records_at_end_hook = -1;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    protected virtual function void do_accept_tr(uvm_transaction tr);
      accepts++; seen = tr; accepted_at_hook = tr.get_accept_time();
    endfunction
    protected virtual function void do_begin_tr(uvm_transaction tr, string stream_name,
    int tr_handle);
      begins++; seen = tr; stream_seen = stream_name; begin_handle = tr_handle;
      begun_at_hook = tr.get_begin_time();
    endfunction
    protected virtual function void do_end_tr(uvm_transaction tr, int tr_handle);
      transaction typed;
      ends++; seen = tr; end_handle = tr_handle; ended_at_hook = tr.get_end_time();
      if ($cast(typed, tr)) records_at_end_hook = typed.records;
    endfunction
  endclass

  initial begin
    automatic observer first = new("first", null);
    automatic observer peer = new("peer", null);

    automatic local_database db = new();
    automatic transaction kept = new("kept");
    automatic transaction freed = new("freed");
    local_stream stream_value;
    uvm_recorder opened_record;
    int kept_handle;
    int freed_handle;
    int handle_value;
    bit opened;


    opened = db.open_db(); first.set_tr_database(db); first.set_recording_enabled(1);
    kept.disable_recording(); freed.disable_recording();
    handle_value = first.begin_tr(kept, "traffic", "", "", 23);
    opened_record = uvm_recorder::get_recorder_from_handle(first.begin_handle);
    if (opened_record == null) $fatal(1, "begin hook did not supply a recorder");
    if (!$cast(stream_value, opened_record.get_stream()) || stream_value.created.size() != 1)
      $fatal(1, "recorder stream missing");
    kept_handle = stream_value.created[0].get_handle();
    $display("UT: begin properties %0d open %0d hook_handle %0d nonzero %0d", kept.records,
    stream_value.created[0].is_open(), first.begin_handle == kept_handle, kept_handle != 0);
    first.end_tr(kept, 29, 0);
    $display("UT: kept records %0d hook_before_record %0d closed %0d frees %0d lookup %0d",
    kept.records, first.records_at_end_hook == 0, stream_value.created[0].is_closed(),
    stream_value.created[0].frees,
    uvm_recorder::get_recorder_from_handle(kept_handle) == stream_value.created[0]);
    handle_value = first.begin_tr(freed, "traffic", "", "", 31);
    if (stream_value.created.size() != 2) $fatal(1, "second recorder missing");
    freed_handle = stream_value.created[1].get_handle(); first.end_tr(freed, 37);
    $display("UT: freed records %0d closes %0d frees %0d lookup_null %0d kept_valid %0d",
    freed.records, stream_value.created[1].closes, stream_value.created[1].frees,
    uvm_recorder::get_recorder_from_handle(freed_handle) == null,
    uvm_recorder::get_recorder_from_handle(kept_handle) == stream_value.created[0]);

    $finish;
  end

endmodule
