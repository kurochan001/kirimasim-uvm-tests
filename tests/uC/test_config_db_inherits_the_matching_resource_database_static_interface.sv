/*
:name: test_config_db_inherits_the_matching_resource_database_static_interface
:description: config db inherits the matching resource database static interface
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.4.2.1 C.3.2 C.3.2.3.2 C.3.2.3.4 C.3.2.3.6 C.4.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_config_db_inherits_the_matching_resource_database_static_interface.expected
*/
// What it checks:
// 1. The config DB inherits the resource DB interface of its matching T.
// 2. The selected resource DB convenience functions are callable by class
//    scope.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 C.4.2.1 (UVM-RESOURCE-COLLECTION-CONFIG-INHERITANCE) gives
//    rule 1 above. Setup: Use public class-qualified functions, selected
//    default/explicit specializations and fresh distinct scopes. Expected: An
//    original config extension inherits set_default, and explicit
//    config/resource views recover the same resource/value.
// 2. 1800.2-2020 C.3.2 (UVM-RESOURCE-COLLECTION-RESOURCE-DB-STATIC) gives rule
//    2 above. Setup: Use public class-qualified functions, selected
//    default/explicit specializations and fresh distinct scopes. Expected:
//    Static creation and retrieval retain the same typed resource handle and
//    stored value.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_config_db_inherits_the_matching_resource_database_static_interface;
  import uvm_pkg::*;
  class config_extension extends uvm_config_db#(int);
  endclass
  initial begin
    uvm_resource#(int) created,read_back;
    int value;
    bit found;
    created=config_extension::set_default("scope62","resource62");
    created.write(73);
    read_back=uvm_config_db#(int)::get_by_name("scope62","resource62",0);
    found=uvm_resource_db#(int)::read_by_name("scope62","resource62",value);
    $display("UT: config_inherited same_specialization %0d stored_value %0d",
      created==read_back,found && value==73);
    $finish;
  end
endmodule
