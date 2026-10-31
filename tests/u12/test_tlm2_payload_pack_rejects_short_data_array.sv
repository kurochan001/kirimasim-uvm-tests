/*
:name: test_tlm2_payload_pack_rejects_short_data_array
:description: generic payload packing and unpacking preserve the prescribed fields and lengths (IEEE 1800.2-2020 Section 12.3.4.2.4)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.2.4 12.3.4.2.5 6.6.3.2 6.6.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_payload_pack_rejects_short_data_array.expected
*/
// Declare more active bytes than the supplied data array holds.
// Observe the required fatal severity and request finish in the catcher;
// no behavior after a suppressed fatal or implementation message is assumed.

module test_tlm2_payload_pack_rejects_short_data_array;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class fatal_probe extends uvm_report_catcher;
    bit caught = 0;
    function new(string name="fatal_probe"); super.new(name); endfunction
    function action_e catch();
      if (get_severity() == UVM_FATAL) begin
        caught = 1;
        $display("UT: fatal_for_short_array 1");
        $finish;
        return CAUGHT;
      end
      return THROW;
    endfunction
  endclass

  initial begin
    automatic uvm_tlm_generic_payload source = new("source");
    automatic uvm_tlm_generic_payload target = new("target");
    automatic uvm_packer packer = new;
    automatic fatal_probe probe = new;
    automatic byte unsigned bytes_value[] = '{8'h42};
    uvm_report_cb::add(null, probe);
    source.set_data(bytes_value);
    source.set_data_length(2);
    source.do_pack(packer);
    if (!probe.caught) $display("UT: missing_fatal");
    $finish;
  end
endmodule
