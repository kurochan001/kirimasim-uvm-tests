/*
:name: test_block_constructor_preserves_names_object_identity_and_available_coverage_defaults
:description: block constructor preserves names object identity and available coverage defaults
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.2.1 18.1.1 18.1.4.3 5.3.4.2 17.2.2.9 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_constructor_preserves_names_object_identity_and_available_coverage_defaults.expected
*/
// What it checks:
// 1. A block instance is usable through an object base view and casts back to
//    the same block handle.
// 2. Block construction preserves the selected instance name and produces a
//    distinct instance.
// 3. Omitting the selected block name uses the declared empty-string default.
// 4. Omitting has_coverage supplies no available coverage models.
// 5. The selected constructor mask advertises all supplied symbolic coverage
//    models without adding the absent address model.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.1.1 (UVM-BLOCK-CONFIG-OBJECT-BASE) gives rule 1 above.
//    Setup: Use the selected original block subclasses and public calls.
//    Protected coverage construction is exposed only by a selected original
//    subtype; add_coverage is called only in its constructor. Ignore
//    set_coverage return values, whose independent previous-mask oracle
//    remains unchanged. Expected: A block instance is usable through an object
//    base view and casts back to the same block handle.
// 2. 1800.2-2020 18.1.2.1 (UVM-BLOCK-CONFIG-NEW-NAME) gives rule 2 above.
//    Setup: Use the selected original block subclasses and public calls.
//    Protected coverage construction is exposed only by a selected original
//    subtype; add_coverage is called only in its constructor. Ignore
//    set_coverage return values, whose independent previous-mask oracle
//    remains unchanged. Expected: Block construction preserves the selected
//    instance name and produces a distinct instance.
// 3. 1800.2-2020 18.1.2.1 (UVM-BLOCK-CONFIG-NEW-DEFAULT-NAME) gives rule 3
//    above. Setup: Use the selected original block subclasses and public
//    calls. Protected coverage construction is exposed only by a selected
//    original subtype; add_coverage is called only in its constructor. Ignore
//    set_coverage return values, whose independent previous-mask oracle
//    remains unchanged. Expected: Omitting the selected block name uses the
//    declared empty-string default.
// 4. 1800.2-2020 18.1.2.1 (UVM-BLOCK-CONFIG-NEW-DEFAULT-COVERAGE) gives rule 4
//    above. Setup: Use the selected original block subclasses and public
//    calls. Protected coverage construction is exposed only by a selected
//    original subtype; add_coverage is called only in its constructor. Ignore
//    set_coverage return values, whose independent previous-mask oracle
//    remains unchanged. Expected: Omitting has_coverage supplies no
//    available coverage models.
// 5. 1800.2-2020 18.1.2.1 (UVM-BLOCK-CONFIG-NEW-MULTIPLE-COVERAGE) gives rule
//    5 above. Setup: Use the selected original block subclasses and public
//    calls. Protected coverage construction is exposed only by a selected
//    original subtype; add_coverage is called only in its constructor. Ignore
//    set_coverage return values, whose independent previous-mask oracle
//    remains unchanged. Expected: The selected constructor mask advertises all
//    supplied symbolic coverage models without adding the absent address
//    model.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_block_constructor_preserves_names_object_identity_and_available_coverage_defaults;
  import uvm_pkg::*;
class block_type extends uvm_reg_block;
  function new(string name="",int available=UVM_NO_COVERAGE);
    super.new(name,available);
  endfunction
endclass

initial begin
  automatic block_type unnamed=new();
  automatic block_type named=new("chosen50",UVM_CVR_REG_BITS|UVM_CVR_FIELD_VALS);
  automatic block_type peer=new("peer50");
  uvm_object object_view;
  uvm_reg_block block_view;
  object_view=named;
  $display("UT: constructor unnamed %0d named %0d distinct %0d",
    unnamed.get_name()=="",named.get_name()=="chosen50",named!=peer);
  $display("UT: constructor object_view %0d roundtrip %0d",
    object_view==named,$cast(block_view,object_view) && block_view==named);
  $display("UT: constructor default_none %0d peer_none %0d combined %0d missing %0d",
    !unnamed.has_coverage(UVM_CVR_REG_BITS),!peer.has_coverage(UVM_CVR_FIELD_VALS),
    named.has_coverage(UVM_CVR_REG_BITS|UVM_CVR_FIELD_VALS),
    !named.has_coverage(UVM_CVR_ADDR_MAP));
  $finish;
end
endmodule
