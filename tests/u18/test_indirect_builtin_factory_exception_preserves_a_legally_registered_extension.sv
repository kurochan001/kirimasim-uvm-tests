/*
:name: test_indirect_builtin_factory_exception_preserves_a_legally_registered_extension
:description: indirect builtin factory exception preserves a legally registered extension
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.7 18.7.1 18.7.2.1 8.3.1.7.2 B.2.1.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_indirect_builtin_factory_exception_preserves_a_legally_registered_extension.expected
*/
// What it checks:
// The builtin indirect type is not factory registered, while an original legal
// extension may be registered.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.7 (UVM-MEM-FIFO-AUDIT-INDIRECT-FACTORY-EXCEPTION) gives the
// rule above. Setup: In a fresh process, query the builtin wrapper name and
// create an original utils-registered extension whose simple name constructor
// supplies the required base arguments. Expected: The builtin wrapper is
// absent and the distinct legal extension is created with its selected
// name/dimensions.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_indirect_builtin_factory_exception_preserves_a_legally_registered_extension;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class quiet_lookup extends uvm_report_catcher;
    virtual function action_e catch();
      if (get_severity()==UVM_WARNING) return CAUGHT;
      return THROW;
    endfunction
  endclass

  class original_extension extends uvm_reg_indirect_data;
    `uvm_object_utils(original_extension)
    function new(string name=""); super.new(name,8,UVM_NO_COVERAGE); endfunction
  endclass
  initial begin
    uvm_factory factory;
    uvm_object_wrapper builtin;
    original_extension created;
    uvm_reg base_view;
    quiet_lookup probe;
    probe=new(); uvm_report_cb::add(null,probe); factory=uvm_factory::get();
    builtin=factory.find_wrapper_by_name("uvm_reg_indirect_data");
    created=original_extension::type_id::create("created63"); base_view=created;
    $display("UT: factory_exception builtin_absent %0d extension %0d base_view %0d",
      builtin==null,created!=null && created.get_name()=="created63" &&
      created.get_n_bits()==8,base_view==created);
    $finish;
  end
endmodule
