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
// What it checks:
// 1. Adding previously unregistered callback handles returns true
//    independently of equal names.
// 2. Adding an already registered callback returns false.
// 3. Adding a null callback returns false.
// 4. Deleting a registered callback returns true and preserves the peer
//    registration.
// 5. Deleting a callback no longer registered returns false.
// 6. Deleting a null callback returns false.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 F.6.2.5 (UVM-PACKAGE-AUDIT-CALLBACK-ADD-IDENTITY) gives rule
//    1 above. Setup: Two original concrete callbacks share a name; static
//    registration/deletion receives the same, distinct and null handles.
//    Expected: Two different handles with the same name each add successfully.
// 2. 1800.2-2020 F.6.2.5 (UVM-PACKAGE-AUDIT-CALLBACK-ADD-DUPLICATE) gives rule
//    2 above. Setup: Two original concrete callbacks share a name; static
//    registration/deletion receives the same, distinct and null handles.
//    Expected: The second add of the first handle is false.
// 3. 1800.2-2020 F.6.2.5 (UVM-PACKAGE-AUDIT-CALLBACK-ADD-NULL) gives rule 3
//    above. Setup: Two original concrete callbacks share a name; static
//    registration/deletion receives the same, distinct and null handles.
//    Expected: The null add returns zero.
// 4. 1800.2-2020 F.6.2.6 (UVM-PACKAGE-AUDIT-CALLBACK-DELETE-IDENTITY) gives
//    rule 4 above. Setup: Two original concrete callbacks share a name; static
//    registration/deletion receives the same, distinct and null handles.
//    Expected: Both distinct handles can each be deleted successfully.
// 5. 1800.2-2020 F.6.2.6 (UVM-PACKAGE-AUDIT-CALLBACK-DELETE-ABSENT) gives rule
//    5 above. Setup: Two original concrete callbacks share a name; static
//    registration/deletion receives the same, distinct and null handles.
//    Expected: The repeated delete of the first handle is false.
// 6. 1800.2-2020 F.6.2.6 (UVM-PACKAGE-AUDIT-CALLBACK-DELETE-NULL) gives rule 6
//    above. Setup: Two original concrete callbacks share a name; static
//    registration/deletion receives the same, distinct and null handles.
//    Expected: The null delete returns zero.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
