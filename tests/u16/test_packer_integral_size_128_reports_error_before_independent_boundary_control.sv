/*
:name: test_packer_integral_size_128_reports_error_before_independent_boundary_control
:description: oversize integral packing emits ERROR without inspecting the invalid packed state (IEEE 1800.2-2020 Section 16.5.4.9)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.5.4.9 16.5.4.17 16.5.3.3 6.6.3.2 6.6.5 D.4.4
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_packer_integral_size_128_reports_error_before_independent_boundary_control.expected
*/
// What it checks:
// Integral packing reports an error for a requested size above 64 bits.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.5.4.9 (UVM-PACKER-INTEGRAL-OVERSIZE-ERROR) gives the rule
// above. Setup: Call pack_field_int with a size greater than 64. Expected: The
// invalid call emits an error without assuming a resulting packed
// representation.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A fresh valid packer round-trips 64 bits. No size, data or recovery
// behavior is assumed for the packer that received an oversize request.
module test_packer_integral_size_128_reports_error_before_independent_boundary_control;
  import uvm_pkg::*;

  class item extends uvm_object;
    int payload = 0;
    function new(string name="item"); super.new(name); endfunction
    virtual function void do_copy(uvm_object rhs);
      item source;
      if (!$cast(source, rhs)) $fatal(1, "unexpected copy fixture type");
      payload = source.payload;
    endfunction
  endclass
  class error_probe extends uvm_report_catcher;
    int errors = 0;
    function new(string name="error_probe"); super.new(name); endfunction
    virtual function action_e catch();
      if (get_severity() == UVM_ERROR) begin
        errors++;
        return CAUGHT;
      end
      return THROW;
    endfunction
  endclass

  initial begin
    uvm_packer invalid;
    uvm_packer control;
    error_probe probe;
    uvm_integral_t value;
    invalid = new();
    control = new();
    probe = new();
    uvm_report_cb::add(null, probe);
    invalid.pack_field_int(64'hfedcba9876543210, 128);
    $display("UT: oversize_error %0d", probe.errors > 0);
    uvm_report_cb::delete(null, probe);
    control.pack_field_int(64'hfedcba9876543210, 64);
    $display("UT: boundary_bits %0d", control.get_packed_size());
    value = control.unpack_field_int(64);
    $display("UT: boundary_value %0d remaining %0d", value == 64'hfedcba9876543210,
             control.get_packed_size());
    $finish;
  end
endmodule
