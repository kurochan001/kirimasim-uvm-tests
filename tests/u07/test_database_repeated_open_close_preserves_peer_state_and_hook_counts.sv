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
