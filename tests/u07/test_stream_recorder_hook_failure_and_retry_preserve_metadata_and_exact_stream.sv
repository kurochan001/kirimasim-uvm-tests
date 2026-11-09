/*
:name: test_stream_recorder_hook_failure_and_retry_preserve_metadata_and_exact_stream
:description: do_open_recorder failure and retry forward explicit metadata and exact stream identity (7.2.7.4)
:tags: u07 uvm
:type: simulation
:lrm: 1800.2-2020 7.2.7.4 7.2.5.1 7.2.5.2 16.4.7.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_stream_recorder_hook_failure_and_retry_preserve_metadata_and_exact_stream.expected
*/
// What it checks:
// 1. The recorder backend receives the requested name, opening time and record
//    type.
// 2. A null recorder backend result fails without initializing/registering the
//    candidate and permits a successful retry.
// 3. A successful recorder backend result invokes its open callback with the
//    exact stream and supplied metadata.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 7.2.7.4 (UVM-RECORDING-RECORDER-BACKEND-ARGUMENTS) gives rule
//    1 above. Setup: Request txn at explicit recording time seventeen with
//    type packet. Expected: Backend arguments are txn/17/packet.
// 2. 1800.2-2020 7.2.5.1 (UVM-RECORDING-RECORDER-NULL-RESULT-RETRY) gives rule
//    2 above. Setup: Return null and then a preconstructed recorder on an open
//    stream. Expected: Failure has zero opens/registrations; retry returns the
//    exact recorder with one open and one queue entry.
// 3. 1800.2-2020 16.4.7.1 (UVM-RECORDING-RECORDER-OPEN-HOOK-STREAM-IDENTITY)
//    gives rule 3 above. Setup: Retry the failed recorder open with explicit
//    time/type metadata. Expected: The recorder opens once with the original
//    stream, time seventeen and packet type.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_stream_recorder_hook_failure_and_retry_preserve_metadata_and_exact_stream;
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
    automatic local_stream stream_value = new("stream");
    automatic local_recorder candidate = new("txn");
    automatic uvm_recorder result;
    uvm_recorder records[$];
    db.candidate = stream_value; stream_value.record_candidate = candidate;
    if (!db.open_db() || db.open_stream("stream") != stream_value) $fatal(1, "stream open failed");
    stream_value.allow_record = 0;
    result = stream_value.open_recorder("txn", 17, "packet");
    void'(stream_value.get_recorders(records));
    $display("UT: failed null %0d calls %0d opens %0d registered %0d", result == null,
             stream_value.recorder_calls, candidate.opens, records.size());
    stream_value.allow_record = 1;
    result = stream_value.open_recorder("txn", 17, "packet");
    records.delete(); void'(stream_value.get_recorders(records));
    $display("UT: retried exact %0d calls %0d opens %0d registered_exact %0d", result == candidate,
             stream_value.recorder_calls, candidate.opens,
             records.size() == 1 && records[0] == candidate);
    $display("UT: backend %s %0d %s recorder_stream %0d metadata %0d %s",
             stream_value.recorder_name, stream_value.recorder_time, stream_value.recorder_type,
             candidate.seen_stream == stream_value, candidate.seen_time, candidate.seen_type);
    $finish;
  end
endmodule
