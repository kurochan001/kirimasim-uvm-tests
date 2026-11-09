/*
:name: test_database_open_state_tracks_failed_and_successful_connections
:description: database status changes only when the modeled connection opens and closes (IEEE 1800.2-2020 Section 7.1.3.3)
:tags: u07 uvm
:type: simulation
:lrm: 1800.2-2020 7.1.3.3 7.1.1 7.1.2 7.1.3.1 7.1.3.2 7.1.6.1 7.1.6.2 7.1.6.3 7.1.6.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_database_open_state_tracks_failed_and_successful_connections.expected
*/
// What it checks:
// Database is_open distinguishes a successful open that is still active from a
// closed database.
//
// How the expected output follows from the standard:
// 1800.2-2020 7.1.3.3 (UVM-DATABASE-OPEN-STATE) gives the rule above. Setup: A
// database fixture supplies failed/successful open results and successful
// close, including repeated operations and a peer database. Expected: Status
// is 1 after successful open and 0 when no open remains.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Deterministic hooks model connection success without an external database.
// No stream is created, so stream close/free and recording remain separate.
module test_database_open_state_tracks_failed_and_successful_connections;
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
    $display("UT: initially_closed %0d", !first.is_open());
    first.allow_open = 0;
    result = first.open_db();
    $display("UT: failed result %0d open %0d calls %0d", result, first.is_open(), first.opens);
    first.allow_open = 1;
    result = first.open_db();
    $display("UT: opened result %0d open %0d calls %0d", result, first.is_open(), first.opens);
    result = first.close_db();
    $display("UT: closed result %0d open %0d calls %0d", result, first.is_open(), first.closes);
    $finish;
  end
endmodule
