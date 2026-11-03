/*
:name: test_block_inherited_backdoor_queries_follow_later_ancestor_replacement_without_local_assignment
:description: block inherited backdoor queries follow later ancestor replacement without local assignment
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.6.2 18.1.6.3 18.1.2.2 19.5.1 19.5.2.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_inherited_backdoor_queries_follow_later_ancestor_replacement_without_local_assignment.expected
*/
// No local backdoor is assigned to child/deep; queries alone do not override.
module
  test_block_inherited_backdoor_queries_follow_later_ancestor_replacement_without_local_assignment;
  import uvm_pkg::*;
class block_type extends uvm_reg_block;
  function new(string name="",int available=UVM_NO_COVERAGE);
    super.new(name,available);
  endfunction
endclass

class marker_backdoor extends uvm_reg_backdoor;
  function new(string name); super.new(name); endfunction
endclass

initial begin
  automatic block_type root=new("root50");
  automatic block_type child=new("child50");
  automatic block_type deep=new("deep50");
  automatic block_type peer=new("peer50");
  automatic marker_backdoor first=new("first50");
  automatic marker_backdoor second=new("second50");
  automatic marker_backdoor own=new("own50");
  root.configure(); child.configure(root); deep.configure(child); peer.configure();
  root.set_backdoor(first); peer.set_backdoor(own);
  $display("UT: backdoor_replace first_child %0d first_deep %0d",
    child.get_backdoor()==first,deep.get_backdoor()==first);
  root.set_backdoor(second,"changed50.sv",50);
  $display("UT: backdoor_replace root %0d child %0d deep %0d peer %0d",
    root.get_backdoor()==second,child.get_backdoor()==second,
    deep.get_backdoor()==second,peer.get_backdoor()==own);
  $display("UT: backdoor_replace query_not_assignment child_local_null %0d deep_local_null %0d",
    child.get_backdoor(0)==null,deep.get_backdoor(0)==null);
  $finish;
end
endmodule
