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
