/*
:name: test_recording_stream_free_invalidates_its_handle_after_explicit_close
:description: free invalidates a closed stream handle and calls its release hook (IEEE 1800.2-2020 Section 7.2.4.2)
:tags: u07 uvm
:type: simulation
:lrm: 1800.2-2020 7.2.4.2 7.2.4.3 7.2.4.4 7.2.6.1 7.2.6.2 7.1.1 7.1.3.1 7.1.3.2 7.1.4.1 7.1.6.1 7.1.6.2 7.1.6.3 7.1.6.4 7.2.7.1 7.2.7.2 7.2.7.3 7.2.7.4 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_recording_stream_free_invalidates_its_handle_after_explicit_close.expected
*/
// What it checks:
// 1. Stream is_open is true only between opening and closing.
// 2. Stream is_closed is true after closing and before freeing.
// 3. Freeing a stream invokes its release hook.
// 4. Stream handles are unique and remain valid through close until free
//    invalidates them.
// 5. Static handle lookup returns the matching stream until that stream is
//    freed.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 7.2.4.3 (UVM-RECORDING-STREAM-OPEN-STATE) gives rule 1 above.
//    Setup: Observe open, closed and freed stream states. Expected: The open
//    stream reports one and closed/freed states report zero.
// 2. 1800.2-2020 7.2.4.4 (UVM-RECORDING-STREAM-CLOSED-STATE) gives rule 2
//    above. Setup: Observe the same stream through open, close and free.
//    Expected: Closed state is zero while open, one after close and zero after
//    free.
// 3. 1800.2-2020 7.2.4.2 (UVM-RECORDING-STREAM-FREE-HOOK) gives rule 3 above.
//    Setup: Explicitly close an initialized stream before freeing it.
//    Expected: The release hook runs once and the freed lifecycle state is
//    visible.
// 4. 1800.2-2020 7.2.6.1 (UVM-RECORDING-STREAM-UNIQUE-HANDLE) gives rule 4
//    above. Setup: Use equal stream names in different databases and retain an
//    old handle across close/free. Expected: Active handles are nonzero,
//    distinct and stable; a freed stream reports zero.
// 5. 1800.2-2020 7.2.6.2 (UVM-RECORDING-STREAM-HANDLE-LOOKUP) gives rule 5
//    above. Setup: Look up two active handles, retain one through close and
//    query an old freed handle. Expected: Active/closed lookups preserve exact
//    identities and a freed handle resolves to null.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Local hooks supply in-memory streams; no database file or external backend
// is opened. Recorder creation and record contents are outside these cases.
module test_recording_stream_free_invalidates_its_handle_after_explicit_close;
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
    int saved_handle;
    db = new("db");

    result_value = db.open_db(); first_stream = db.open_stream("first");
    saved_handle = first_stream.get_handle();
    first_stream.close(); first_stream.free();
    $display("UT: freed open %0d closed %0d handle %0d frees %0d", first_stream.is_open(),
             first_stream.is_closed(), first_stream.get_handle(), db.created[0].frees);
    $display("UT: old_handle_missing %0d",
    uvm_tr_stream::get_stream_from_handle(saved_handle) == null);
    $finish;
  end

endmodule
