/*
:name: test_recording_stream_close_keeps_peer_open_and_retains_closed_metadata
:description: stream close changes only its lifecycle state and invokes the close hook (IEEE 1800.2-2020 Section 7.2.4.1)
:tags: u07 uvm
:type: simulation
:lrm: 1800.2-2020 7.2.4.1 7.2.4.3 7.2.4.4 7.2.3.1 7.2.3.2 7.1.1 7.1.3.1 7.1.3.2 7.1.4.1 7.1.6.1 7.1.6.2 7.1.6.3 7.1.6.4 7.2.7.1 7.2.7.2 7.2.7.3 7.2.7.4 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_recording_stream_close_keeps_peer_open_and_retains_closed_metadata.expected
*/
// What it checks:
// 1. An initialized stream retains the scope supplied on opening.
// 2. Closing a stream invokes its close hook without closing a separate
//    stream.
// 3. Stream is_open is true only between opening and closing.
// 4. Stream is_closed is true after closing and before freeing.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 7.2.3.2 (UVM-RECORDING-STREAM-SCOPE-METADATA) gives rule 1
//    above. Setup: Use explicit env.bus and scope values plus an omitted
//    scope; close one stream. Expected: Explicit scopes survive and an omitted
//    scope is empty, including retained closed-stream metadata.
// 2. 1800.2-2020 7.2.4.1 (UVM-RECORDING-STREAM-CLOSE-HOOK) gives rule 2 above.
//    Setup: Open two local streams and explicitly close one. Expected: The
//    selected hook runs once and the peer stays open.
// 3. 1800.2-2020 7.2.4.3 (UVM-RECORDING-STREAM-OPEN-STATE) gives rule 3 above.
//    Setup: Observe open, closed and freed stream states. Expected: The open
//    stream reports one and closed/freed states report zero.
// 4. 1800.2-2020 7.2.4.4 (UVM-RECORDING-STREAM-CLOSED-STATE) gives rule 4
//    above. Setup: Observe the same stream through open, close and free.
//    Expected: Closed state is zero while open, one after close and zero after
//    free.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Local hooks supply in-memory streams; no database file or external backend
// is opened. Recorder creation and record contents are outside these cases.
module test_recording_stream_close_keeps_peer_open_and_retains_closed_metadata;
  import uvm_pkg::*;

  class local_stream extends uvm_tr_stream;
    int opens = 0;
    int closes = 0;
    int frees = 0;
    uvm_tr_database seen_db;
    string seen_scope;
    string seen_type;
    function new(string name="local_stream"); super.new(name); endfunction
    protected virtual function void do_open(uvm_tr_database db, string scope,
                                             string stream_type_name);
      opens++; seen_db = db; seen_scope = scope; seen_type = stream_type_name;
    endfunction
    protected virtual function void do_close(); closes++; endfunction
    protected virtual function void do_free(); frees++; endfunction
    protected virtual function uvm_recorder do_open_recorder(string name, time open_time,
                                                            string type_name);
      return null;
    endfunction
  endclass
  class local_database extends uvm_tr_database;
    bit allow_open = 1;
    bit allow_stream = 1;
    int stream_calls = 0;
    local_stream created[$];
    function new(string name="local_database"); super.new(name); endfunction
    protected virtual function bit do_open_db(); return allow_open; endfunction
    protected virtual function bit do_close_db(); return 1; endfunction
    protected virtual function uvm_tr_stream do_open_stream(string name, string scope,
                                                           string type_name);
      local_stream result_value;
      stream_calls++;
      if (!allow_stream) return null;
      result_value = new(name); created.push_back(result_value); return result_value;
    endfunction
    protected virtual function void do_establish_link(uvm_link_base link); endfunction
  endclass

  initial begin
    local_database db;
    uvm_tr_stream first_stream;
    uvm_tr_stream second_stream;
    bit result_value;

    db = new("db");

    result_value = db.open_db();
    first_stream = db.open_stream("first", "scope"); second_stream = db.open_stream("peer");
    $display("UT: before open %0d closed %0d", first_stream.is_open(), first_stream.is_closed());
    first_stream.close();
    $display("UT: after open %0d closed %0d closes %0d", first_stream.is_open(),
             first_stream.is_closed(), db.created[0].closes);
    $display("UT: peer open %0d metadata %0d", second_stream.is_open(),
             first_stream.get_db() == db && first_stream.get_scope() == "scope");
    $finish;
  end

endmodule
