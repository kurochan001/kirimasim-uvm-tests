/*
:name: test_resource_base_print_interface_dispatches_to_the_selected_typed_extension
:description: resource base print interface dispatches to the selected typed extension
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.3 C.2.3.1 C.2.5.1 5.3.6.3 16.2.4.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_base_print_interface_dispatches_to_the_selected_typed_extension.expected
*/
module test_resource_base_print_interface_dispatches_to_the_selected_typed_extension;
  import uvm_pkg::*;
  // This original override checks the inherited virtual print interface.
  // It does not prescribe the builtin resource's text or fields.
  class policy extends uvm_printer;
    function new(string name); super.new(name); endfunction
    virtual function string emit(); return "unused"; endfunction
  endclass
  class original_resource extends uvm_resource#(int);
    int calls=0;
    uvm_printer seen;
    function new(string name); super.new(name); endfunction
    virtual function void do_print(uvm_printer printer); calls++; seen=printer; endfunction
  endclass
  initial begin
    original_resource concrete,peer;
    uvm_resource_base base;
    policy first,second;
    concrete=new("selected62"); peer=new("peer62"); base=concrete;
    first=new("first62"); second=new("second62");
    base.do_print(first); base.do_print(second);
    $display("UT: resource_print virtual_calls %0d current_policy %0d peer %0d",
      concrete.calls==2,concrete.seen==second,peer.calls==0);
    $finish;
  end
endmodule
