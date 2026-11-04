/*
:name: test_resource_db_writes_update_shared_scope_matches_no_creating_missing_entries_or_changing
:description: Resource DB writes update the matched shared resource while misses return zero without creating entries
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.3.2.3.8 C.3.2.3.9 C.3.2.3.1 C.3.2.3.4 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_db_writes_update_shared_scope_matches_no_creating_missing_entries_or_changing.expected
*/
// No successful-write return value is invented; the prose specifies zero
// only for a missing lookup and specifies the actual write for a match.
// The type-write paragraph names name-based APIs; this fixture uses the
// selected local-method interpretation rather than treating it as approval.
module
  test_resource_db_writes_update_shared_scope_matches_no_creating_missing_entries_or_changing;
  import uvm_pkg::*;
  class accessor_type extends uvm_object;
    function new(string name); super.new(name); endfunction
  endclass
  initial begin
    automatic accessor_type accessor=new("accessor58");
    uvm_resource#(int) shared_value,peer;
    bit missing_name,missing_type;
    uvm_resource_db#(int)::set("shared58.*","slot58",11);
    uvm_resource_db#(int)::set("peer58","slot58",22);
    shared_value=uvm_resource_db#(int)::get_by_name("shared58.a","slot58",0);
    peer=uvm_resource_db#(int)::get_by_name("peer58","slot58",0);
    void'(uvm_resource_db#(int)::write_by_name("shared58.a","slot58",58,accessor));
    $display("UT: db_write_name shared %0d peer %0d",
      shared_value.read()==58 &&
      uvm_resource_db#(int)::get_by_name("shared58.b","slot58",0)==shared_value,peer.read()==22);
    void'(uvm_resource_db#(int)::write_by_type("shared58.b",59));
    $display("UT: db_write_type shared %0d peer %0d",shared_value.read()==59,peer.read()==22);
    missing_name=uvm_resource_db#(int)::write_by_name("missing58","slot58",99);
    missing_type=uvm_resource_db#(int)::write_by_type("missing58",99,accessor);
    $display("UT: db_missing_write name_zero %0d type_zero %0d not_created %0d",
      !missing_name,!missing_type,
      uvm_resource_db#(int)::get_by_name("missing58","slot58",0)==null);
    $finish;
  end
endmodule
