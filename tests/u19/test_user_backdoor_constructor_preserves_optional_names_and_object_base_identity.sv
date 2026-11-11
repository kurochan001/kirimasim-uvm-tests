/*
:name: test_user_backdoor_constructor_preserves_optional_names_and_object_base_identity
:description: user backdoor constructor preserves optional names and object base identity (IEEE 1800.2-2020 Section 19.5.2.1)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.5.2.1 19.5.1 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_user_backdoor_constructor_preserves_optional_names_and_object_base_identity.expected
*/
// What it checks:
// 1. A concrete user backdoor derives from the object base.
// 2. The user-backdoor constructor accepts the declared optional name.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 19.5.1 (UVM-REG-INTERACTION-BACKDOOR-BASE) gives rule 1
//    above. Setup: Upcast an original user backdoor to an object handle.
//    Expected: The base view denotes the same backdoor.
// 2. 1800.2-2020 19.5.2.1 (UVM-REG-INTERACTION-BACKDOOR-NAMES) gives rule 2
//    above. Setup: An implicit subtype constructor and explicit forwarding
//    constructors select omitted, named and empty cases. Expected: Names are
//    empty, selected and empty.
// It also supports, as a control, the setup or conditions of
// UVM-ABSTRACT-REG-BACKDOOR-DIRECT-CONSTRUCTION.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original concrete subtypes expose the base constructor defaults and explicit
// forwarding. No default data, backend availability or physical HDL is
// inferred.
module test_user_backdoor_constructor_preserves_optional_names_and_object_base_identity;
  import uvm_pkg::*;
  class omitted_backdoor extends uvm_reg_backdoor;
    virtual function void read_func(uvm_reg_item rw);
      rw.set_value(0); rw.set_status(UVM_IS_OK);
    endfunction
  endclass
  class named_backdoor extends uvm_reg_backdoor;
    function new(string name); super.new(name); endfunction
    virtual function void read_func(uvm_reg_item rw);
      rw.set_value(0); rw.set_status(UVM_IS_OK);
    endfunction
  endclass
  initial begin
    automatic omitted_backdoor omitted = new();
    automatic named_backdoor named = new("selected");
    automatic named_backdoor empty = new("");
    automatic uvm_object base_view = named;
    $display("UT: backdoor_names omitted %0d named %0d empty %0d",
             omitted.get_name() == "", named.get_name() == "selected", empty.get_name() == "");
    $display("UT: backdoor_base %0d", base_view == named);
    $finish;
  end
endmodule
