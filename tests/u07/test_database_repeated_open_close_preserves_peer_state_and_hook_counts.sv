/*
:name: test_database_repeated_open_close_preserves_peer_state_and_hook_counts
:description: already-open and already-closed operations do not call connection hooks again (IEEE 1800.2-2020 Section 7.1.3.1)
:tags: u07 uvm
:type: simulation
:lrm: 1800.2-2020 7.1.3.1 7.1.1 7.1.2 7.1.3.1 7.1.3.2 7.1.6.1 7.1.6.2 7.1.6.3 7.1.6.4 7.1.3.3
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_database_repeated_open_close_preserves_peer_state_and_hook_counts.expected
*/
// What it checks:
// 1. Database is_open distinguishes a successful open that is still active
//    from a closed database.
// 2. Opening an already open database succeeds without reopening its backend.
// 3. Closing an already closed database succeeds without calling the close
//    hook.
// 4. Repeated opening of an already opened database does not repeat the open
//    backend callback.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 7.1.3.3 (UVM-DATABASE-OPEN-STATE) gives rule 1 above. Setup:
//    A database fixture supplies failed/successful open results and successful
//    close, including repeated operations and a peer database. Expected:
//    Status is 1 after successful open and 0 when no open remains.
// 2. 1800.2-2020 7.1.3.1 (UVM-DATABASE-OPEN-IDEMPOTENCE) gives rule 2 above.
//    Setup: Use two local hook-backed databases and repeat calls while
//    preserving the peer state. Expected: The second open returns 1 while the
//    open-hook count stays 1.
// 3. 1800.2-2020 7.1.3.2 (UVM-DATABASE-CLOSE-IDEMPOTENCE) gives rule 3 above.
//    Setup: Use two local hook-backed databases and repeat calls while
//    preserving the peer state. Expected: A fresh closed database needs zero
//    close hooks; a repeated close retains one previous close call.
// 4. 1800.2-2020 7.1.6.1 (UVM-RECORDING-EXISTING-OPEN-BACKEND-IDEMPOTENCE)
//    gives rule 4 above. Setup: Use the unchanged explicit open/reopen
//    fixture. Expected: Both operations succeed with one backend open call.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Deterministic hooks model connection success without an external database.
// No stream is created, so stream close/free and recording remain separate.
module test_database_repeated_open_close_preserves_peer_state_and_hook_counts;
  import uvm_pkg::*;
  class status_database extends uvm_tr_database;
    bit allow_open = 1;
    int opens = 0;
    int closes = 0;
    function new(string name="status_database"); super.new(name); endfunction
    protected virtual function bit do_open_db();
      opens++;
      return allow_open;
    endfunction
    protected virtual function bit do_close_db();
      closes++;
      return 1;
    endfunction
    protected virtual function uvm_tr_stream do_open_stream(string name,
                                                          string scope,
                                                          string type_name);
      return null;
    endfunction
    protected virtual function void do_establish_link(uvm_link_base link);
    endfunction
  endclass
  initial begin
    status_database first;
    status_database second;
    bit result;
    first = new("first");
    second = new("second");
    result = first.close_db();
    $display("UT: fresh_close %0d hook_calls %0d", result, first.closes);
    result = first.open_db();
    result = first.open_db();
    $display("UT: repeated_open %0d hook_calls %0d", result, first.opens);
    result = second.open_db();
    result = first.close_db();
    $display("UT: independent first_closed %0d second_open %0d",
             !first.is_open(), second.is_open());
    result = first.close_db();
    $display("UT: repeated_close %0d hook_calls %0d", result, first.closes);
    $finish;
  end
endmodule
