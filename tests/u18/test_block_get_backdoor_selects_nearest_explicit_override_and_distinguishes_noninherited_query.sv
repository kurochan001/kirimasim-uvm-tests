/*
:name: test_block_get_backdoor_selects_nearest_explicit_override_and_distinguishes_noninherited_query
:description: block get backdoor selects nearest explicit override and distinguishes noninherited query
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.6.2 18.1.6.3 18.1.2.2 19.5.1 19.5.2.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_get_backdoor_selects_nearest_explicit_override_and_distinguishes_noninherited_query.expected
*/
module
  test_block_get_backdoor_selects_nearest_explicit_override_and_distinguishes_noninherited_query;
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
  automatic block_type sibling=new("sibling50");
  automatic block_type peer=new("peer50");
  automatic marker_backdoor ancestor=new("ancestor50");
  automatic marker_backdoor override_value=new("override50");
  root.configure(); child.configure(root); deep.configure(child);
  sibling.configure(root); peer.configure();
  $display("UT: backdoor initial root_null %0d child_null %0d",
    root.get_backdoor()==null,child.get_backdoor()==null);
  root.set_backdoor(ancestor); child.set_backdoor(override_value);
  $display("UT: backdoor explicit root %0d child %0d deep_local_null %0d sibling_local_null %0d",
    root.get_backdoor(0)==ancestor,child.get_backdoor(0)==override_value,
    deep.get_backdoor(0)==null,sibling.get_backdoor(0)==null);
  $display("UT: backdoor inherited deep %0d sibling %0d default_true %0d peer_null %0d",
    deep.get_backdoor(1)==override_value,sibling.get_backdoor(1)==ancestor,
    deep.get_backdoor()==override_value,peer.get_backdoor()==null);
  $finish;
end
endmodule
