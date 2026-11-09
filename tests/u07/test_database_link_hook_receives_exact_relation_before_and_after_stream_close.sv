/*
:name: test_database_link_hook_receives_exact_relation_before_and_after_stream_close
:description: do_establish_link receives an exact valid link with open or closed nonfreed endpoints (7.1.6.4)
:tags: u07 uvm
:type: simulation
:lrm: 1800.2-2020 7.1.6.4 7.1.5 7.2.4 7.3.4.2.2 7.2.4.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_database_link_hook_receives_exact_relation_before_and_after_stream_close.expected
*/
// What it checks:
// 1. Database establish_link dispatches the relation to its backend.
// 2. The link backend receives the exact relation object without changing its
//    endpoints.
// 3. Closing an endpoint without freeing it still permits establishment of a
//    stream link.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 7.1.5 (UVM-RECORDING-LINK-DISPATCH-BACKEND) gives rule 1
//    above. Setup: Submit one relation twice while its endpoints remain live.
//    Expected: The backend receives two calls for that exact relation.
// 2. 1800.2-2020 7.1.6.4 (UVM-RECORDING-LINK-BACKEND-EXACT-RELATION) gives
//    rule 2 above. Setup: Observe a related link between two streams on one
//    database. Expected: The relation and both endpoint handles remain exact.
// 3. 1800.2-2020 7.2.4 (UVM-RECORDING-LINK-CLOSED-STREAM-ALLOWED) gives rule 3
//    above. Setup: Close one of two linked streams, retain both handles and
//    submit the relation again. Expected: The backend receives the second
//    exact relation while the closed/open endpoint states remain distinct.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_database_link_hook_receives_exact_relation_before_and_after_stream_close;
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
    automatic local_stream left = new("left");
    automatic local_stream right = new("right");
    automatic uvm_related_link relation;
    if (!db.open_db()) $fatal(1, "database open failed");
    db.candidate = left;
    if (db.open_stream("left") != left) $fatal(1, "left missing");
    db.candidate = right;
    if (db.open_stream("right") != right) $fatal(1, "right missing");
    relation = uvm_related_link::get_link(left, right, "relation");
    db.establish_link(relation);
    $display("UT: open_relation calls %0d exact %0d endpoints %0d %0d", db.link_calls,
             db.seen_link == relation, relation.get_lhs() == left, relation.get_rhs() == right);
    left.close(); db.establish_link(relation);
    $display("UT: closed_relation calls %0d exact %0d left_closed %0d right_open %0d",
             db.link_calls, db.seen_link == relation, left.is_closed(), right.is_open());
    $finish;
  end
endmodule
