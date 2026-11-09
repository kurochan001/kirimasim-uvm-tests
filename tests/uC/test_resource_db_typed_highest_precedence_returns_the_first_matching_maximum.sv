/*
:name: test_resource_db_typed_highest_precedence_returns_the_first_matching_maximum
:description: resource db typed highest precedence returns the first matching maximum
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.3.2.3.10 C.2.4.5.6 C.2.2.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_db_typed_highest_precedence_returns_the_first_matching_maximum.expected
*/
// What it checks:
// Typed maximum selection returns the first matching maximum in the supplied
// queue.
//
// How the expected output follows from the standard:
// 1800.2-2020 C.3.2.3.10 (UVM-RESOURCE-COLLECTION-TYPED-FIRST-TIE) gives the
// rule above. Setup: Construct original resource queues with explicit
// global-pool precedences, mixed specializations and retained live handles.
// Expected: Reversing the two matching maximum handles reverses the selected
// handle despite a larger wrong-type entry.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_resource_db_typed_highest_precedence_returns_the_first_matching_maximum;
  import uvm_pkg::*;
  initial begin

    uvm_resource_pool pool;
    uvm_resource#(int) first_peak,later_peak,low;
    uvm_resource#(string) other_type;
    uvm_resource_types::rsrc_q_t values;
    pool=uvm_resource_pool::get(); first_peak=new("first62"); later_peak=new("later62");
    low=new("low62"); other_type=new("other62"); values=new();
    pool.set_scope(first_peak,"scope62"); pool.set_scope(later_peak,"scope62");
    pool.set_scope(low,"scope62"); pool.set_scope(other_type,"scope62");
    pool.set_precedence(first_peak,17); pool.set_precedence(later_peak,17);
    pool.set_precedence(low,3); pool.set_precedence(other_type,99);

    values.push_back(low); values.push_back(other_type);
    values.push_back(first_peak); values.push_back(later_peak);
    $display("UT: typed_tie first %0d",
      uvm_resource_db#(int)::get_highest_precedence(values)==first_peak);
    values.delete(); values.push_back(other_type); values.push_back(later_peak);
    values.push_back(first_peak);
    $display("UT: typed_tie reordered %0d",
      uvm_resource_db#(int)::get_highest_precedence(values)==later_peak);
    $finish;
  end
endmodule
