/*
:name: test_database_stream_hook_forwards_arguments_and_initializes_only_a_successful_result
:description: do_open_stream failure and retry preserve arguments and dispatch do_open only for success (7.1.6.3)
:tags: u07 uvm
:type: simulation
:lrm: 1800.2-2020 7.1.6.3 7.1.4.1 7.2.7.1 7.1.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_database_stream_hook_forwards_arguments_and_initializes_only_a_successful_result.expected
*/
// What it checks:
// 1. The stream backend receives the requested name, scope and record type.
// 2. A null backend stream result fails without registering the candidate and
//    a later retry can succeed.
// 3. A successful backend stream result triggers do_open with the database and
//    opening metadata.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 7.1.6.3 (UVM-RECORDING-STREAM-BACKEND-ARGUMENTS) gives rule 1
//    above. Setup: Request requested/scope.child/events through open_stream.
//    Expected: The backend captures those exact strings.
// 2. 1800.2-2020 7.1.4.1 (UVM-RECORDING-STREAM-NULL-RESULT-RETRY) gives rule 2
//    above. Setup: Return null, then the same preconstructed candidate from
//    consecutive stream requests. Expected: First result is null with zero
//    registrations; retry returns the exact candidate once.
// 3. 1800.2-2020 7.2.7.1 (UVM-RECORDING-STREAM-OPEN-HOOK-SUCCESS-GATE) gives
//    rule 3 above. Setup: Observe the same candidate across one failed and one
//    successful backend result. Expected: No open hook runs on failure;
//    success runs it once with the exact database, scope and type.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_database_stream_hook_forwards_arguments_and_initializes_only_a_successful_result;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  // Original in-memory callbacks; no external recording backend or files.
  class local_recorder extends uvm_recorder;
    int opens = 0;
    uvm_tr_stream seen_stream;
    time seen_time;
    string seen_type;
    function new(string name); super.new(name); endfunction
    protected function void do_open(uvm_tr_stream stream, time open_time, string type_name);
      opens++; seen_stream = stream; seen_time = open_time; seen_type = type_name;
    endfunction
    protected function void do_close(time close_time); endfunction
    protected function void do_free(); endfunction
    protected function void do_record_field(string name, uvm_bitstream_t value,
                                            int size, uvm_radix_enum radix); endfunction
    protected function void do_record_field_int(string name, uvm_integral_t value,
                                                int size, uvm_radix_enum radix); endfunction
    protected function void do_record_field_real(string name, real value); endfunction
    protected function void do_record_string(string name, string value); endfunction
    protected function void do_record_time(string name, time value); endfunction
    protected function void do_record_generic(string name, string value, string type_name);
    endfunction
  endclass
  class local_stream extends uvm_tr_stream;
    int opens = 0;
    int recorder_calls = 0;
    bit allow_record = 1;
    local_recorder record_candidate;
    uvm_tr_database seen_db;
    string seen_scope, seen_type, recorder_name, recorder_type;
    time recorder_time;
    function new(string name); super.new(name); endfunction
    protected function void do_open(uvm_tr_database db, string scope, string stream_type_name);
      opens++; seen_db = db; seen_scope = scope; seen_type = stream_type_name;
    endfunction
    protected function void do_close(); endfunction
    protected function void do_free(); endfunction
    protected function uvm_recorder do_open_recorder(string name, time open_time, string type_name);
      recorder_calls++; recorder_name = name; recorder_time = open_time; recorder_type = type_name;
      return allow_record ? record_candidate : null;
    endfunction
  endclass
  class local_database extends uvm_tr_database;
    bit allow_open = 1;
    bit allow_close = 1;
    bit allow_stream = 1;
    int open_calls = 0;
    int close_calls = 0;
    int stream_calls = 0;
    int link_calls = 0;
    local_stream candidate;
    uvm_link_base seen_link;
    string stream_name, stream_scope, stream_type;
    function new(string name); super.new(name); endfunction
    protected function bit do_open_db(); open_calls++; return allow_open; endfunction
    protected function bit do_close_db(); close_calls++; return allow_close; endfunction
    protected function uvm_tr_stream do_open_stream(string name, string scope, string type_name);
      stream_calls++; stream_name = name; stream_scope = scope; stream_type = type_name;
      return allow_stream ? candidate : null;
    endfunction
    protected function void do_establish_link(uvm_link_base link);
      link_calls++; seen_link = link;
    endfunction
  endclass
  initial begin
    automatic local_database db = new("db");
    automatic local_stream candidate = new("requested");
    automatic uvm_tr_stream result;
    uvm_tr_stream streams[$];
    db.candidate = candidate;
    if (!db.open_db()) $fatal(1, "database open failed");
    db.allow_stream = 0; result = db.open_stream("requested", "scope.child", "events");
    void'(db.get_streams(streams));
    $display("UT: failed null %0d calls %0d opens %0d registered %0d", result == null,
             db.stream_calls, candidate.opens, streams.size());
    db.allow_stream = 1; result = db.open_stream("requested", "scope.child", "events");
    streams.delete(); void'(db.get_streams(streams));
    $display("UT: retried exact %0d calls %0d opens %0d registered_exact %0d",
             result == candidate, db.stream_calls, candidate.opens,
             streams.size() == 1 && streams[0] == candidate);
    $display("UT: backend_args %s %s %s open_args %0d %s %s", db.stream_name,
             db.stream_scope, db.stream_type, candidate.seen_db == db,
             candidate.seen_scope, candidate.seen_type);
    $finish;
  end
endmodule
