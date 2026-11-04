/*
:name: test_run_test_callback_membership_uses_handle_identity_and_rejects_duplicate_and_null_entries
:description: Run-test callback registration distinguishes handle identity from names and reports duplicate/null membership
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.6.2.5 F.6.2.6 F.6.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_run_test_callback_membership_uses_handle_identity_and_rejects_duplicate_and_null_entries.expected
*/
module
  test_run_test_callback_membership_uses_handle_identity_and_rejects_duplicate_and_null_entries;
  import uvm_pkg::*;
  class callback_type extends uvm_run_test_callback;
    function new(); super.new("same57"); endfunction
  endclass
  initial begin
    automatic callback_type first_cb=new();
    automatic callback_type second_cb=new();
    bit first_added,duplicate_added,second_added,removed,repeated,peer_removed;
    first_added=uvm_run_test_callback::add(first_cb);
    duplicate_added=uvm_run_test_callback::add(first_cb);
    second_added=uvm_run_test_callback::add(second_cb);
    removed=uvm_run_test_callback::delete(first_cb);
    repeated=uvm_run_test_callback::delete(first_cb);
    peer_removed=uvm_run_test_callback::delete(second_cb);
    $display("UT: callback_add first %0d duplicate %0d same_name_peer %0d null %0d",
      first_added,!duplicate_added,second_added,!uvm_run_test_callback::add(null));
    $display("UT: callback_delete removed %0d repeated %0d peer %0d null %0d",
      removed,!repeated,peer_removed,!uvm_run_test_callback::delete(null));
    $finish;
  end
endmodule
