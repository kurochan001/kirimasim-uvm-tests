/*
:name: test_config_wrapper_alias_preserves_live_factory_proxy_handles_and_replacement
:description: config wrapper alias preserves live factory proxy handles and replacement
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.4.2.3.4 C.4.2.2.1 C.4.2.2.2 8.3.2.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_config_wrapper_alias_preserves_live_factory_proxy_handles_and_replacement.expected
*/
// What it checks:
// The wrapper config alias is the factory-wrapper specialization.
//
// How the expected output follows from the standard:
// 1800.2-2020 C.4.2.3.4 (UVM-RESOURCE-COLLECTION-CONFIG-WRAPPER-ALIAS) gives
// the rule above. Setup: Compare exact type identities and perform actual
// cross-spelling set/get operations using selected values and fresh scopes.
// Expected: Type names agree and live distinct factory proxy handles survive
// retrieval and replacement through both spellings.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_config_wrapper_alias_preserves_live_factory_proxy_handles_and_replacement;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class first_item extends uvm_object;
    `uvm_object_utils(first_item)
    function new(string name=""); super.new(name); endfunction
  endclass
  class second_item extends uvm_object;
    `uvm_object_utils(second_item)
    function new(string name=""); super.new(name); endfunction
  endclass
  initial begin
    uvm_object_wrapper first,second,read_first,read_second;
    bit found_first,found_second;
    first=first_item::get_type(); second=second_item::get_type();
    uvm_config_wrapper::set(null,"scope62","slot62",first);
    found_first=uvm_config_db#(uvm_object_wrapper)::get(null,"scope62","slot62",read_first);
    uvm_config_db#(uvm_object_wrapper)::set(null,"scope62","slot62",second);
    found_second=uvm_config_wrapper::get(null,"scope62","slot62",read_second);
    $display("UT: config_wrapper exact_type %0d handles %0d distinct %0d",
      $typename(uvm_config_wrapper)==$typename(uvm_config_db#(uvm_object_wrapper)),
      found_first && read_first==first && found_second && read_second==second,
      first!=null && second!=null && first!=second);
    $finish;
  end
endmodule
