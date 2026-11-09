/*
:name: test_database_close_hook_failure_preserves_open_state_until_a_successful_retry
:description: do_close_db failure propagates and permits a later successful close (7.1.6.2)
:tags: u07 uvm
:type: simulation
:lrm: 1800.2-2020 7.1.6.2 7.1.3.2 7.1.3.3 7.1.6.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_database_close_hook_failure_preserves_open_state_until_a_successful_retry.expected
*/
// What it checks:
// 1. The database close backend result is propagated and a failed close can be
//    retried.
// 2. A failed backend close leaves the successfully opened database open until
//    closing succeeds.
// 3. After a failed close and successful retry, another close succeeds without
//    reentering the backend.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 7.1.6.2 (UVM-RECORDING-CLOSE-HOOK-FAILURE-RESULT) gives rule
//    1 above. Setup: Return zero once and then one from do_close_db on an
//    opened database. Expected: Results are zero/one and the backend is called
//    once per attempted close.
// 2. 1800.2-2020 7.1.3.3 (UVM-RECORDING-FAILED-CLOSE-OPEN-STATUS) gives rule 2
//    above. Setup: Query status after failed and successful close attempts
//    without streams. Expected: Status is open after failure and closed after
//    the successful retry.
// 3. 1800.2-2020 7.1.3.2 (UVM-RECORDING-CLOSE-RETRY-IDEMPOTENT-SUCCESS) gives
//    rule 3 above. Setup: Perform three close calls with backend results zero
//    then one. Expected: The final call returns one and total backend close
//    calls remain two.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_database_close_hook_failure_preserves_open_state_until_a_successful_retry;
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
    automatic bit result;
    if (!db.open_db()) $fatal(1, "database open failed");
    db.allow_close = 0; result = db.close_db();
    $display("UT: failed result %0d open %0d closes %0d", result, db.is_open(), db.close_calls);
    db.allow_close = 1; result = db.close_db();
    $display("UT: retried result %0d closed %0d closes %0d", result, !db.is_open(), db.close_calls);
    result = db.close_db();
    $display("UT: already_closed result %0d closes %0d", result, db.close_calls);
    $finish;
  end
endmodule
