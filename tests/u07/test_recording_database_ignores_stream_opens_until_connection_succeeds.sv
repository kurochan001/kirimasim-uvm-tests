/*
:name: test_recording_database_ignores_stream_opens_until_connection_succeeds
:description: closed databases reject stream opens without invoking the stream hook (IEEE 1800.2-2020 Section 7.1.4.1)
:tags: u07 uvm
:type: simulation
:lrm: 1800.2-2020 7.1.4.1 7.1.3.3 7.1.1 7.1.3.1 7.1.3.2 7.1.6.1 7.1.6.2 7.1.6.3 7.1.6.4 7.2.7.1 7.2.7.2 7.2.7.3 7.2.7.4 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_recording_database_ignores_stream_opens_until_connection_succeeds.expected
*/
// What it checks:
// Only an open database accepts stream creation requests.
//
// How the expected output follows from the standard:
// 1800.2-2020 7.1.4.1 (UVM-RECORDING-CLOSED-STREAM-OPEN-GUARD) gives the rule
// above. Setup: Attempt stream creation before opening, after connection
// failure and after successful opening. Expected: Closed/failed states return
// null without a stream-hook call; successful opening permits one open stream.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Local hooks supply in-memory streams; no database file or external backend
// is opened. Recorder creation and record contents are outside these cases.
// The pinned library implicitly opens a closed database. Independent failed
// and successful databases keep the later controls isolated from that change.
module test_recording_database_ignores_stream_opens_until_connection_succeeds;
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
    local_database failed_db;
    local_database working_db;

    db = new("db");

    first_stream = db.open_stream("before");
    $display("UT: closed null %0d calls %0d", first_stream == null, db.stream_calls);
    failed_db = new("failed_db"); failed_db.allow_open = 0;
    result_value = failed_db.open_db(); first_stream = failed_db.open_stream("failed");
    $display("UT: failed open %0d null %0d calls %0d", result_value,
             first_stream == null, failed_db.stream_calls);
    working_db = new("working_db"); result_value = working_db.open_db();
    first_stream = working_db.open_stream("accepted");
    $display("UT: connected %0d stream %0d calls %0d", result_value,
             first_stream != null && first_stream.is_open(), working_db.stream_calls);
    $finish;
  end

endmodule
