/*
:name: test_printer_radix_defaults_updates_and_instance_isolation_follow_defined_radices
:description: printer radix defaults updates and instance isolation follow defined radices
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.5.6 16.2.5.7 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_radix_defaults_updates_and_instance_isolation_follow_defined_radices.expected
*/
module test_printer_radix_defaults_updates_and_instance_isolation_follow_defined_radices;
  import uvm_pkg::*;
  initial begin
    automatic uvm_table_printer first=new();
    automatic uvm_table_printer peer=new();
    $display("UT: radix_defaults dec %0d bin %0d oct %0d unsigned %0d hex %0d default %0d",
             first.get_radix_string(UVM_DEC)=="'d",first.get_radix_string(UVM_BIN)=="'b",
             first.get_radix_string(UVM_OCT)=="'o",first.get_radix_string(UVM_UNSIGNED)=="'d",
             first.get_radix_string(UVM_HEX)=="'h",first.get_default_radix()==UVM_HEX);
    first.set_radix_string(UVM_HEX,"HEX42:"); first.set_radix_string(UVM_DEC,"DEC42:");
    first.set_default_radix(UVM_BIN);
    $display("UT: radix_updates hex %0d dec %0d bin %0d unsigned %0d default %0d",
             first.get_radix_string(UVM_HEX)=="HEX42:",first.get_radix_string(UVM_DEC)=="DEC42:",
             first.get_radix_string(UVM_BIN)=="'b",first.get_radix_string(UVM_UNSIGNED)=="'d",
             first.get_default_radix()==UVM_BIN);
    $display("UT: radix_peer hex %0d dec %0d default %0d",peer.get_radix_string(UVM_HEX)=="'h",
             peer.get_radix_string(UVM_DEC)=="'d",peer.get_default_radix()==UVM_HEX);
    $finish;
  end
endmodule
