/*
:name: test_resource_db_reads_update_success_inout_values_preserve_missing_wrong_type_values
:description: Resource DB successful reads replace inout values and missing scope/type reads preserve their sentinels
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.3.2.3.6 C.3.2.3.7 C.3.2.3.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_db_reads_update_success_inout_values_preserve_missing_wrong_type_values.expected
*/
module
  test_resource_db_reads_update_success_inout_values_preserve_missing_wrong_type_values;
  import uvm_pkg::*;
  class accessor_type extends uvm_object;
    function new(string name); super.new(name); endfunction
  endclass
  initial begin
    automatic accessor_type accessor=new("accessor58");
    int value;
    string text;
    bit ok;
    uvm_resource_db#(int)::set("scope58","slot58",58,accessor);
    value=-1; ok=uvm_resource_db#(int)::read_by_name("scope58","slot58",value);
    $display("UT: db_read_name success %0d value %0d",ok,value==58);
    value=-2; ok=uvm_resource_db#(int)::read_by_type("scope58",value,accessor);
    $display("UT: db_read_type success %0d value %0d",ok,value==58);
    value=-3; ok=uvm_resource_db#(int)::read_by_name("other58","slot58",value,accessor);
    $display("UT: db_missing_name failed %0d unchanged %0d",!ok,value==-3);
    value=-4; ok=uvm_resource_db#(int)::read_by_type("other58",value);
    $display("UT: db_missing_type failed %0d unchanged %0d",!ok,value==-4);
    text="sentinel58";
    ok=uvm_resource_db#(string)::read_by_name("scope58","slot58",text);
    $display("UT: db_wrong_type failed %0d unchanged %0d",!ok,text=="sentinel58");
    $finish;
  end
endmodule
