/*
:name: test_resource_db_default_and_explicit_rsrc_aliases_represent_the_required_container_types
:description: Resource DB defaults to object and rsrc_t uses the exact resource specialization
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.3.2.1 C.3.2.2 C.2.5.4.1 C.2.5.4.2 1800-2023 6.21 8.20 8.21 8.26
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_db_default_and_explicit_rsrc_aliases_represent_the_required_container_types.expected
*/
// What it checks:
// 1. The resource DB defaults its type parameter to uvm_object.
// 2. The DB rsrc_t alias uses the same T as uvm_resource#(T).
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 C.3.2.1 (UVM-RESOURCE-AUDIT-DB-DEFAULT-TYPE) gives rule 1
//    above. Setup: Concrete resources are created through DB aliases, assigned
//    both directions without casts and written/read with original object/int
//    payloads. Expected: The default rsrc_t alias is statically identical to
//    uvm_resource#(uvm_object) and stores the original token handle.
// 2. 1800.2-2020 C.3.2.2 (UVM-RESOURCE-AUDIT-DB-RESOURCE-ALIAS) gives rule 2
//    above. Setup: Concrete resources are created through DB aliases, assigned
//    both directions without casts and written/read with original object/int
//    payloads. Expected: Default-object and explicit-int aliases pass
//    bidirectional exact receiver assignments and retain their selected
//    values.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_resource_db_default_and_explicit_rsrc_aliases_represent_the_required_container_types;
  import uvm_pkg::*;
  class token_type extends uvm_object;
    function new(); super.new("token58"); endfunction
  endclass
  initial begin
    automatic uvm_resource_db#()::rsrc_t default_alias=new("default58");
    automatic uvm_resource_db#(int)::rsrc_t int_alias=new("int58");
    automatic token_type token=new();
    uvm_resource#(uvm_object) required_default;
    uvm_resource#(int) required_int;
    required_default=default_alias; default_alias=required_default;
    required_int=int_alias; int_alias=required_int;
    default_alias.write(token); int_alias.write(-58);
    $display("UT: db_aliases default_identity %0d int_identity %0d values %0d",
      default_alias==required_default,int_alias==required_int,
      default_alias.read()==token && int_alias.read()==-58);
    $finish;
  end
endmodule
