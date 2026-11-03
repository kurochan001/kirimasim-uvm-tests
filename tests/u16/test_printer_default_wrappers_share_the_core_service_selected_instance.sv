/*
:name: test_printer_default_wrappers_share_the_core_service_selected_instance
:description: printer default wrappers share the core service selected instance
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.2.2 16.2.2.3 F.4.1.4.12 F.4.1.4.13 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_default_wrappers_share_the_core_service_selected_instance.expected
*/
module test_printer_default_wrappers_share_the_core_service_selected_instance;
  import uvm_pkg::*;
  initial begin
    automatic uvm_coreservice_t core=uvm_coreservice_t::get();
    automatic uvm_printer saved=core.get_default_printer();
    automatic uvm_table_printer first=new();
    automatic uvm_tree_printer second=new();
    uvm_printer::set_default(first);
    $display("UT: default_printer_selected wrapper %0d core %0d",
             uvm_printer::get_default()==first,core.get_default_printer()==first);
    core.set_default_printer(second);
    $display("UT: default_printer_reverse wrapper %0d core %0d",
             uvm_printer::get_default()==second,core.get_default_printer()==second);
    uvm_printer::set_default(saved);
    $display("UT: default_printer_restored %0d",core.get_default_printer()==saved);
    $finish;
  end
endmodule
