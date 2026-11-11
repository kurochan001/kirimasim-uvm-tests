/*
:name: test_packer_wide_oversize_reports_error_before_an_independent_maximum_width_control
:description: packer wide oversize reports error before an independent maximum width control
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.5.4.8 16.5.4.16 16.5.3.3 B.6.2 6.6.5 D.4.4 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_packer_wide_oversize_reports_error_before_an_independent_maximum_width_control.expected
*/
// What it checks:
// pack_field reports an error for a size above UVM_MAX_STREAMBITS.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.5.4.8 (UVM-POLICY-AUDIT-PACKER-WIDE-OVERSIZE) gives the rule
// above. Setup: Use the selected original fixtures, explicit arguments and
// stage observations in the linked anchors; each fresh policy and peer is
// independently constructed. Expected: pack_field reports an error for a size
// above UVM_MAX_STREAMBITS.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_packer_wide_oversize_reports_error_before_an_independent_maximum_width_control;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class error_probe extends uvm_report_catcher;
    int errors=0;
    virtual function action_e catch();
      if (get_severity()==UVM_ERROR) begin errors++; return CAUGHT; end
      return THROW;
    endfunction
  endclass
  initial begin
    automatic uvm_packer invalid=new();
    automatic uvm_packer control=new();
    automatic error_probe probe=new();
    automatic uvm_bitstream_t payload='0;
    uvm_bitstream_t restored;
    payload[`UVM_MAX_STREAMBITS-1]=1; payload[0]=1;
    uvm_report_cb::add(null,probe);
    invalid.pack_field(payload,`UVM_MAX_STREAMBITS+1);
    $display("UT: wide_size_error %0d",probe.errors>0);
    uvm_report_cb::delete(null,probe);
    // Never inspect or reuse the invalid packer after the rejected request.
    control.pack_field(payload,`UVM_MAX_STREAMBITS);
    restored=control.unpack_field(`UVM_MAX_STREAMBITS);
    $display("UT: wide_size_control value %0d empty %0d",restored==payload,
             control.get_packed_size()==0);
    $finish;
  end
endmodule
