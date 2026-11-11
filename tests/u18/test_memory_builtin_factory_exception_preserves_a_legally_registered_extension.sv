/*
:name: test_memory_builtin_factory_exception_preserves_a_legally_registered_extension
:description: memory builtin factory exception preserves a legally registered extension
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6 18.6.1 18.6.3.1 8.3.1.7.2 B.2.1.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_builtin_factory_exception_preserves_a_legally_registered_extension.expected
*/
// What it checks:
// 1. The builtin memory type is not factory registered, while an original
//    legal extension may be registered.
// 2. A factory-created original memory extension retains its object base view.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.6 (UVM-MEM-FIFO-AUDIT-MEMORY-FACTORY-EXCEPTION) gives rule
//    1 above. Setup: In a fresh process, query the builtin wrapper name and
//    create an original utils-registered extension whose simple name
//    constructor supplies the required base arguments. Expected: The builtin
//    wrapper is absent and the distinct legal extension is created with its
//    selected name/dimensions.
// 2. 1800.2-2020 18.6.1 (UVM-MEM-FIFO-AUDIT-MEM-FACTORY-OBJECT-VIEW) gives
//    rule 2 above. Setup: The registered extension calls the complex memory
//    constructor through its own simple constructor. Expected: Implicit object
//    assignment preserves the created extension identity.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_memory_builtin_factory_exception_preserves_a_legally_registered_extension;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class quiet_lookup extends uvm_report_catcher;
    virtual function action_e catch();
      if (get_severity()==UVM_WARNING) return CAUGHT;
      return THROW;
    endfunction
  endclass

  class original_extension extends uvm_mem;
    `uvm_object_utils(original_extension)
    function new(string name=""); super.new(name,4,8); endfunction
  endclass
  initial begin
    uvm_factory factory;
    uvm_object_wrapper builtin;
    original_extension created;
    uvm_object base_view;
    quiet_lookup probe;
    probe=new(); uvm_report_cb::add(null,probe); factory=uvm_factory::get();
    builtin=factory.find_wrapper_by_name("uvm_mem");
    created=original_extension::type_id::create("created63"); base_view=created;
    $display("UT: factory_exception builtin_absent %0d extension %0d base_view %0d",
      builtin==null,created!=null && created.get_name()=="created63" &&
      created.get_size()==4,base_view==created);
    $finish;
  end
endmodule
