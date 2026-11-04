/*
:name: test_field_operation_constructor_names_and_object_ancestry_are_independent
:description: Field-operation construction, declared ancestry and selected descriptor fields
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.7.2.1 5.7.1 5.7 5.3.4.2 5.7.2.2 5.7.2.3 5.7.2.4 5.7.2.5 5.7.2.6 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_field_operation_constructor_names_and_object_ancestry_are_independent.expected
*/
module test_field_operation_constructor_names_and_object_ancestry_are_independent;
  import uvm_pkg::*;
  class original_object extends uvm_object;
    function new(string name=""); super.new(name); endfunction
    virtual function string get_type_name(); return "original_object61"; endfunction
    virtual function uvm_object create(string name="");
      original_object result;
      result=new(name); return result;
    endfunction
  endclass
  initial begin
    uvm_field_op omitted,named,empty_name;
    uvm_object base;
    original_object source;
    uvm_copier policy;
    omitted=new(); named=new("named61"); empty_name=new("");
    base=named; source=new("source61"); policy=new();
    $display("UT: field_op_names omitted %0d explicit %0d empty %0d ancestry %0d",
      omitted.get_name()=="",named.get_name()=="named61",empty_name.get_name()=="",base==named);
    named.set(UVM_COPY,policy,source);
    $display("UT: field_op_descriptor type %0d name %0d policy %0d rhs %0d",
      named.get_op_type()==UVM_COPY,named.get_op_name()=="copy",
      named.get_policy()==policy,named.get_rhs()==source);
    $finish;
  end
  initial begin #100; $fatal(1,"base-class fixture watchdog expired"); end
endmodule
