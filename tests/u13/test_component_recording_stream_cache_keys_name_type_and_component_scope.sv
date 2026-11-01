/*
:name: test_component_recording_stream_cache_keys_name_type_and_component_scope
:description: component stream cache distinguishes name type and component scope (IEEE 1800.2-2020 Section 13.1.7.9)
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.7.9 13.1.7.11 13.1.2.1 13.1.3.2 7.1.3.1 7.1.4.1 7.1.6.1 7.1.6.2 7.1.6.3 7.1.6.4 7.2.3.1 7.2.3.2 7.2.3.3 7.2.5.1 7.2.7.1 7.2.7.2 7.2.7.3 7.2.7.4 16.4.7.1 16.4.7.2 16.4.7.3 16.4.7.4 16.4.7.5 16.4.7.6 16.4.7.9 16.4.7.10 16.4.7.11 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_recording_stream_cache_keys_name_type_and_component_scope.expected
*/
// Use local in-memory recording hooks, explicit timestamps and named objects.
// No external database format, vendor attributes, events or DPI are observed.
module test_component_recording_stream_cache_keys_name_type_and_component_scope;
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
    uvm_tr_stream original_stream;
    uvm_tr_stream other_type;
    uvm_tr_stream other_name;
    uvm_tr_stream peer_stream;
    bit opened;


    opened = db.open_db(); first.set_tr_database(db); peer.set_tr_database(db);
    original_stream = first.get_tr_stream("main", "packet");
    other_type = first.get_tr_stream("main", "control");
    other_name = first.get_tr_stream("side", "packet");
    peer_stream = peer.get_tr_stream("main", "packet");
    if (original_stream == null || other_type == null || other_name == null ||
    peer_stream == null) $fatal(1, "missing stream");
    $display("UT: reused %0d distinct_type %0d distinct_name %0d distinct_scope %0d calls %0d",
    first.get_tr_stream("main", "packet") == original_stream, other_type != original_stream,
    other_name != original_stream, peer_stream != original_stream, db.stream_calls);
    $display("UT: metadata name %s type %s scope %s peer_scope %s", original_stream.get_name(),
    original_stream.get_stream_type_name(), original_stream.get_scope(), peer_stream.get_scope());

    $finish;
  end

endmodule
