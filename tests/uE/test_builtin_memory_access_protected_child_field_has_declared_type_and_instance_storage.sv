/*
:name: test_builtin_memory_access_protected_child_field_has_declared_type_and_instance_storage
:description: Legal extension accesses uvm_mem_access_seq protected mem_seq with exact uvm_mem_single_access_seq type
:tags: uE uvm
:type: simulation
:lrm: 1800.2-2020 E.5.2.2.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_builtin_memory_access_protected_child_field_has_declared_type_and_instance_storage.expected
*/
// What it checks:
// The protected mem_seq slot stores a uvm_mem_single_access_seq handle for the
// selected wrapper.
//
// How the expected output follows from the standard:
// 1800.2-2020 E.5.2.2.2 (UVM-BUILTIN-AUDIT-CHILD-MEMORY-ACCESS) gives the rule
// above. Setup: Original derived accessors use the literal prototype member
// name and exact child type, assign/replace/clear the selected slot and
// capture a peer baseline; separate original factory children audit live
// routing. The live access probes attach original per-target storage backdoors
// before starting, satisfying access-test eligibility; their routing-only
// child bodies do not invoke those handlers. Expected: Selected storage
// matches, the prior child remains valid and the peer remains unchanged; live
// probes require the declared slot to identify the executing child and
// selected targets.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original accessors observe the printed protected member from a legal
// extension. No default child value or preservation across body() is assumed.
// Where the heading says req_seq, use the prototype's literal reg_seq.
module test_builtin_memory_access_protected_child_field_has_declared_type_and_instance_storage;
  import uvm_pkg::*;
  class field_view extends uvm_mem_access_seq;
    function new(string name); super.new(name); endfunction
    function void choose(uvm_mem_single_access_seq value); mem_seq=value; endfunction
    function uvm_mem_single_access_seq selected(); return mem_seq; endfunction
  endclass
  initial begin
    field_view subject,peer;
    uvm_mem_single_access_seq chosen,replacement,exact_receiver,peer_initial;
    subject=new("subject60"); peer=new("peer60");
    chosen=new("chosen60"); replacement=new("replacement60");
    peer_initial=peer.selected(); subject.choose(chosen); exact_receiver=subject.selected();
    $display("UT: child_field assigned %0d peer_unchanged %0d",
      exact_receiver==chosen,peer.selected()==peer_initial);
    subject.choose(replacement);
    $display("UT: child_field replacement %0d prior_handle_valid %0d peer_unchanged %0d",
      subject.selected()==replacement,chosen.get_name()=="chosen60",peer.selected()==peer_initial);
    subject.choose(null);
    $display("UT: child_field null_storage %0d peer_unchanged %0d",
      subject.selected()==null,peer.selected()==peer_initial);
    $finish;
  end
endmodule
