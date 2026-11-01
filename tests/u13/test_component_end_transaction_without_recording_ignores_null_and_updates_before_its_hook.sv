/*
:name: test_component_end_transaction_without_recording_ignores_null_and_updates_before_its_hook
:description: component end ignores null and updates transaction end before its hook (IEEE 1800.2-2020 Section 13.1.7.5)
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.7.5 13.1.7.6 13.1.7.3 13.1.7.13 5.4.2.6 5.4.2.14 5.4.2.12 13.1.2.1 13.1.3.2 7.1.3.1 7.1.4.1 7.1.6.1 7.1.6.2 7.1.6.3 7.1.6.4 7.2.3.1 7.2.3.2 7.2.3.3 7.2.5.1 7.2.7.1 7.2.7.2 7.2.7.3 7.2.7.4 16.4.7.1 16.4.7.2 16.4.7.3 16.4.7.4 16.4.7.5 16.4.7.6 16.4.7.9 16.4.7.10 16.4.7.11 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_end_transaction_without_recording_ignores_null_and_updates_before_its_hook.expected
*/
// Use local in-memory recording hooks, explicit timestamps and named objects.
// No external database format, vendor attributes, events or DPI are observed.
module test_component_end_transaction_without_recording_ignores_null_and_updates_before_its_hook;
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

    automatic transaction tr = new();
    int handle_value;


    tr.disable_recording(); first.set_recording_enabled(0);
    handle_value = first.begin_tr(tr, "traffic", "", "", 23);
    first.end_tr(null, 29);
    $display("UT: null end_calls %0d", first.ends);
    first.end_tr(tr, 29);
    $display("UT: ended calls %0d identity %0d time %0d hook_time %0d", first.ends,
    first.seen == tr, tr.get_end_time(), first.ended_at_hook);
    $display("UT: recording hook_handle %0d inactive %0d records %0d", first.end_handle,
    !tr.is_active(), tr.records);

    $finish;
  end

endmodule
