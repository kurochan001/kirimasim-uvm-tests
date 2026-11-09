/*
:name: test_config_object_alias_returns_shared_handles_replacements_and_present_null
:description: config object alias returns shared handles replacements and present null
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.4.2.3.3 C.4.2.2.1 C.4.2.2.2 C.4.2.2.3 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_config_object_alias_returns_shared_handles_replacements_and_present_null.expected
*/
// What it checks:
// The object config alias is the object-handle specialization.
//
// How the expected output follows from the standard:
// 1800.2-2020 C.4.2.3.3 (UVM-RESOURCE-COLLECTION-CONFIG-OBJECT-ALIAS) gives
// the rule above. Setup: Compare exact type identities and perform actual
// cross-spelling set/get operations using selected values and fresh scopes.
// Expected: Type names agree; exact handles/replacements and a present null
// pass between the two spellings without cloning.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_config_object_alias_returns_shared_handles_replacements_and_present_null;
  import uvm_pkg::*;
  class item extends uvm_object;
    int payload=0;
    function new(string name=""); super.new(name); endfunction
    virtual function string get_type_name(); return "item62"; endfunction
    virtual function uvm_object create(string name="");
      item result; result=new(name); return result;
    endfunction
  endclass

  initial begin
    item first,second;
    uvm_object first_view,second_view,null_view;
    bit found_first,found_second,found_null;
    first=new("first62"); second=new("second62"); first.payload=19; second.payload=31;
    uvm_config_object::set(null,"scope62","slot62",first);
    found_first=uvm_config_db#(uvm_object)::get(null,"scope62","slot62",first_view);
    uvm_config_db#(uvm_object)::set(null,"scope62","slot62",second);
    found_second=uvm_config_object::get(null,"scope62","slot62",second_view);
    uvm_config_object::set(null,"scope62","slot62",null);
    found_null=uvm_config_db#(uvm_object)::get(null,"scope62","slot62",null_view);
    $display("UT: config_object exact_type %0d handles %0d present_null %0d",
      $typename(uvm_config_object)==$typename(uvm_config_db#(uvm_object)),
      found_first && first_view==first && found_second && second_view==second && first.payload==19,
      found_null && null_view==null && uvm_config_object::exists(null,"scope62","slot62"));
    $finish;
  end
endmodule
