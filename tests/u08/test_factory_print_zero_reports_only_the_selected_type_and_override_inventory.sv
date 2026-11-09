/*
:name: test_factory_print_zero_reports_only_the_selected_type_and_override_inventory
:description: factory print zero reports only the selected type and override inventory
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.3.1.7.5 8.3.1.3 8.3.1.4.1 8.3.1.4.2 8.2.4.2.3 1800-2023 6.21 8.20 8.21 13.4 21.3.1
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_factory_print_zero_reports_only_the_selected_type_and_override_inventory.expected
:expected_stderr_regex: (?s)\A(?=.*?FACTORY_CAPTURE_BEGIN55(?:(?!FACTORY_CAPTURE_END55).)*\btype_base55\b)(?=.*?FACTORY_CAPTURE_BEGIN55(?:(?!FACTORY_CAPTURE_END55).)*\btype_alt55\b)(?=.*?FACTORY_CAPTURE_BEGIN55(?:(?!FACTORY_CAPTURE_END55).)*\binst_base55\b)(?=.*?FACTORY_CAPTURE_BEGIN55(?:(?!FACTORY_CAPTURE_END55).)*\binst_alt55\b)(?!.*?FACTORY_CAPTURE_BEGIN55(?:(?!FACTORY_CAPTURE_END55).)*\blisted_only55\b)(?!.*?FACTORY_CAPTURE_BEGIN55(?:(?!FACTORY_CAPTURE_END55).)*\buvm_sequence_item\b).*FACTORY_CAPTURE_END55
*/
// What it checks:
// 1. print includes the selected type-override state.
// 2. print includes the selected instance-override state.
// 3. With all_types zero, unrelated registered-type inventory is omitted.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 8.3.1.7.5 (UVM-FACTORY-AUDIT-PRINT-TYPE-OVERRIDES) gives rule
//    1 above. Setup: A fresh factory has two independent override pairs, one
//    named user type without an override and a standard uvm_sequence_item
//    proxy; print is framed separately on stdout and stderr. Expected: The
//    type_base55 and type_alt55 names occur in framed output.
// 2. 1800.2-2020 8.3.1.7.5 (UVM-FACTORY-AUDIT-PRINT-INSTANCE-OVERRIDES) gives
//    rule 2 above. Setup: A fresh factory has two independent override pairs,
//    one named user type without an override and a standard uvm_sequence_item
//    proxy; print is framed separately on stdout and stderr. Expected: The
//    inst_base55 and inst_alt55 names occur in framed output.
// 3. 1800.2-2020 8.3.1.7.5 (UVM-FACTORY-AUDIT-PRINT-ZERO-NO-REGISTERED-LIST)
//    gives rule 3 above. Setup: A fresh factory has two independent override
//    pairs, one named user type without an override and a standard
//    uvm_sequence_item proxy; print is framed separately on stdout and stderr.
//    Expected: Neither listed_only55 nor uvm_sequence_item appears in either
//    framed stream.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_factory_print_zero_reports_only_the_selected_type_and_override_inventory;
  import uvm_pkg::*;
  class type_base55 extends uvm_object;
    function new(string name="");super.new(name);endfunction
  endclass
  class type_alt55 extends type_base55;
    function new(string name="");super.new(name);endfunction
  endclass
  class inst_base55 extends uvm_object;
    function new(string name="");super.new(name);endfunction
  endclass
  class inst_alt55 extends inst_base55;
    function new(string name="");super.new(name);endfunction
  endclass
  class listed_only55 extends uvm_object;
    function new(string name="");super.new(name);endfunction
  endclass
  typedef uvm_object_registry#(type_base55,"type_base55") type_base_proxy;
  typedef uvm_object_registry#(type_alt55,"type_alt55") type_alt_proxy;
  typedef uvm_object_registry#(inst_base55,"inst_base55") inst_base_proxy;
  typedef uvm_object_registry#(inst_alt55,"inst_alt55") inst_alt_proxy;
  typedef uvm_object_registry#(listed_only55,"listed_only55") listed_proxy;
  typedef uvm_object_registry#(uvm_sequence_item,"uvm_sequence_item") builtin_proxy;
  initial begin
    automatic uvm_default_factory factory=new();
    factory.register(type_base_proxy::get());factory.register(type_alt_proxy::get());
    factory.register(inst_base_proxy::get());factory.register(inst_alt_proxy::get());
    factory.register(listed_proxy::get());factory.register(builtin_proxy::get());
    factory.set_type_override_by_type(type_base_proxy::get(),type_alt_proxy::get());
    factory.set_inst_override_by_type(inst_base_proxy::get(),inst_alt_proxy::get(),"ctx55.slot55");
    // Frame each stream separately: the runner joins stdout and stderr.
    $display("FACTORY_CAPTURE_BEGIN55");
    $fdisplay(32'h8000_0002,"FACTORY_CAPTURE_BEGIN55");
    $display("UT: factory_print begin");
    factory.print(0);
    #1;
    $display("UT: factory_print end");
    $display("FACTORY_CAPTURE_END55");
    $fdisplay(32'h8000_0002,"FACTORY_CAPTURE_END55");
    $finish;
  end
endmodule
