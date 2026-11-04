/*
:name: test_void_containers_hold_direct_extensions_and_object_extensions_with_live_identity
:description: Generic void containers preserve selected direct/object extension identities
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.2 5.3.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_void_containers_hold_direct_extensions_and_object_extensions_with_live_identity.expected
*/
module test_void_containers_hold_direct_extensions_and_object_extensions_with_live_identity;
  import uvm_pkg::*;
  class original_object extends uvm_object;
    function new(string name=""); super.new(name); endfunction
    virtual function string get_type_name(); return "original_object61"; endfunction
    virtual function uvm_object create(string name="");
      original_object result;
      result=new(name); return result;
    endfunction
  endclass
  class plain_extension extends uvm_void;
    int value=61;
  endclass
  initial begin
    plain_extension plain,plain_view;
    original_object object_value,object_view;
    uvm_object impossible;
    uvm_void entries[$];
    plain=new(); object_value=new("object61");
    entries.push_back(plain); entries.push_back(object_value);
    $display("UT: void_container two_entries %0d plain %0d object %0d",
      entries.size()==2,$cast(plain_view,entries[0]),$cast(object_view,entries[1]));
    plain_view.value=73;
    $display("UT: void_identity plain_live %0d object_same %0d no_object_ancestry %0d",
      plain.value==73,object_view==object_value,!$cast(impossible,entries[0]));
    $finish;
  end
  initial begin #100; $fatal(1,"base-class fixture watchdog expired"); end
endmodule
