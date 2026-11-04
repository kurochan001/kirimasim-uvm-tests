/*
:name: test_transaction_constructor_omission_names_and_initiator_defaults
:description: Original transaction extensions isolate omitted base construction and explicit arguments
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.4.2.1 5.4 5.1 5.4.2.15 5.3.4.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_transaction_constructor_omission_names_and_initiator_defaults.expected
*/
module test_transaction_constructor_omission_names_and_initiator_defaults;
  import uvm_pkg::*;
  class transaction_type extends uvm_transaction;
    function new(string name="",uvm_component initiator=null);
      super.new(name,initiator);
    endfunction
    virtual function string get_type_name(); return "transaction_type61"; endfunction
    virtual function uvm_object create(string name="");
      transaction_type result;
      result=new(name); return result;
    endfunction
  endclass
  class omitted_transaction extends uvm_transaction;
    function new(); super.new(); endfunction
    virtual function string get_type_name(); return "omitted_transaction61"; endfunction
    virtual function uvm_object create(string name="");
      omitted_transaction result;
      result=new(); result.set_name(name); return result;
    endfunction
  endclass
  class owner extends uvm_component;
    function new(string name); super.new(name,null); endfunction
  endclass
  initial begin
    transaction_type named,empty_name;
    omitted_transaction omitted;
    owner initiator;
    uvm_transaction view;
    uvm_object object_view;
    omitted=new(); initiator=new("owner61");
    named=new("named61",initiator); empty_name=new("",null);
    view=named; object_view=view;
    $display("UT: transaction_names omitted %0d explicit %0d empty %0d",
      omitted.get_name()=="",named.get_name()=="named61",empty_name.get_name()=="");
    $display("UT: transaction_constructor null_default %0d initiator %0d ancestry %0d",
      omitted.get_initiator()==null,named.get_initiator()==initiator,object_view==named);
    $finish;
  end
  initial begin #100; $fatal(1,"base-class fixture watchdog expired"); end
endmodule
