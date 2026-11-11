/*
:name: test_register_max_size_tracks_larger_instances_without_assuming_an_initial_global_value
:description: register max size tracks larger instances without assuming an initial global value
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.3.10 18.4.2.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_register_max_size_tracks_larger_instances_without_assuming_an_initial_global_value.expected
*/
// What it checks:
// 1. The selected first register contributes its width to the maximum of the
//    captured preexisting register widths.
// 2. The selected larger register is included in the global register maximum
//    width.
// 3. Adding a smaller register and repeating the query preserve the selected
//    global maximum.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.4.3.10 (UVM-REGISTER-CONTRACT-MAX-SIZE-FIRST) gives rule 1
//    above. Setup: Use the selected original register/block/file models and
//    explicit public calls. Constructor-only observations do not require
//    mapped physical hardware. Membership is queried through the register view
//    after selected legal registrations/removals; output queues start empty.
//    Expected: The selected first register contributes its width to the
//    maximum of the captured preexisting register widths.
// 2. 1800.2-2020 18.4.3.10 (UVM-REGISTER-CONTRACT-MAX-SIZE-LARGER) gives rule
//    2 above. Setup: Use the selected original register/block/file models and
//    explicit public calls. Constructor-only observations do not require
//    mapped physical hardware. Membership is queried through the register view
//    after selected legal registrations/removals; output queues start empty.
//    Expected: The selected larger register is included in the global register
//    maximum width.
// 3. 1800.2-2020 18.4.3.10 (UVM-REGISTER-CONTRACT-MAX-SIZE-SMALLER) gives rule
//    3 above. Setup: Use the selected original register/block/file models and
//    explicit public calls. Constructor-only observations do not require
//    mapped physical hardware. Membership is queried through the register view
//    after selected legal registrations/removals; output queues start empty.
//    Expected: Adding a smaller register and repeating the query preserve the
//    selected global maximum.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_register_max_size_tracks_larger_instances_without_assuming_an_initial_global_value;
  import uvm_pkg::*;
  class block_type extends uvm_reg_block;
    function new(string name);super.new(name,UVM_NO_COVERAGE);endfunction
  endclass
  class register_type extends uvm_reg;
    function new(string name,int unsigned width=16,int coverage_models=UVM_NO_COVERAGE);
      super.new(name,width,coverage_models);
    endfunction
  endclass

  initial begin
    int baseline,want;
    register_type first,largest,smaller;
    baseline=uvm_reg::get_max_size();first=new("first52",13);
    want=baseline>13 ? baseline : 13;
    $display("UT: register_max first %0d",uvm_reg::get_max_size()==want);
    largest=new("largest52",53);if (want<53) want=53;
    $display("UT: register_max larger %0d",uvm_reg::get_max_size()==want);
    smaller=new("smaller52",17);
    $display("UT: register_max smaller_keeps %0d repeated_query %0d",
      uvm_reg::get_max_size()==want,uvm_reg::get_max_size()==want);
    $finish;
  end
endmodule
