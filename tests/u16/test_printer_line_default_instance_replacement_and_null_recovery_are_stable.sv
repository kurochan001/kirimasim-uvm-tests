/*
:name: test_printer_line_default_instance_replacement_and_null_recovery_are_stable
:description: printer line default instance replacement and null recovery are stable
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.12.2.3 16.2.12.2.4 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_line_default_instance_replacement_and_null_recovery_are_stable.expected
*/
module test_printer_line_default_instance_replacement_and_null_recovery_are_stable;
  import uvm_pkg::*;
  initial begin
    automatic uvm_line_printer saved=uvm_line_printer::get_default();
    automatic uvm_line_printer first=new("first");
    automatic uvm_line_printer second=new("second");
    uvm_line_printer recovered;
    $display("UT: kind_default_initial nonnull %0d stable %0d type %0d",saved!=null,
             uvm_line_printer::get_default()==saved,
             saved.get_type_name()=="uvm_line_printer");
    uvm_line_printer::set_default(first);
    $display("UT: kind_default_first exact %0d stable %0d",
             uvm_line_printer::get_default()==first,uvm_line_printer::get_default()==first);
    uvm_line_printer::set_default(second);
    $display("UT: kind_default_second exact %0d",uvm_line_printer::get_default()==second);
    uvm_line_printer::set_default(null); recovered=uvm_line_printer::get_default();
    $display("UT: kind_default_recovered nonnull %0d new %0d stable %0d type %0d",recovered!=null,
             recovered!=first && recovered!=second && recovered!=saved,
             uvm_line_printer::get_default()==recovered,
             recovered.get_type_name()=="uvm_line_printer");
    uvm_line_printer::set_default(saved);
    $display("UT: kind_default_restored %0d",uvm_line_printer::get_default()==saved);
    $finish;
  end
endmodule
