/*
:name: test_builtin_shared_memory_protected_child_field_has_declared_type_and_instance_storage
:description: Legal extension accesses uvm_reg_mem_shared_access_seq protected mem_seq with exact uvm_mem_shared_access_seq type
:tags: uE uvm
:type: simulation
:lrm: 1800.2-2020 E.4.3.2.3 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_builtin_shared_memory_protected_child_field_has_declared_type_and_instance_storage.expected
*/
// Original accessors observe the printed protected member from a legal
// extension. No default child value or preservation across body() is assumed.
// Where the heading says req_seq, use the prototype's literal reg_seq.
module test_builtin_shared_memory_protected_child_field_has_declared_type_and_instance_storage;
  import uvm_pkg::*;
  class field_view extends uvm_reg_mem_shared_access_seq;
    function new(string name); super.new(name); endfunction
    function void choose(uvm_mem_shared_access_seq value); mem_seq=value; endfunction
    function uvm_mem_shared_access_seq selected(); return mem_seq; endfunction
  endclass
  initial begin
    field_view subject,peer;
    uvm_mem_shared_access_seq chosen,replacement,exact_receiver,peer_initial;
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
