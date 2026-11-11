/*
:name: test_package_integral_type_is_signed_sixty_four_bits_and_sign_extends
:description: The integral type retains its signed 64-bit declaration when shifted and widened
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.1.4 1800-2023 6.21 8.20 8.21 11.8.1 11.8.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_package_integral_type_is_signed_sixty_four_bits_and_sign_extends.expected
*/
// What it checks:
// uvm_integral_t is a signed 64-bit type.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.2.1.4 (UVM-PACKAGE-AUDIT-INTEGRAL-TYPE) gives the rule above.
// Setup: A selected top-bit-set pattern is shifted into a typed receiver and
// assigned to a wider signed 96-bit receiver. Expected: Width, negative
// comparison, arithmetic shift and upper-word sign extension all retain the
// declared signed type.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// No four-state preservation claim is made by this two-state probe.
module test_package_integral_type_is_signed_sixty_four_bits_and_sign_extends;
  import uvm_pkg::*;
  initial begin
    automatic uvm_integral_t value=64'h8000000000000001;
    automatic uvm_integral_t shifted=value >>> 1;
    automatic logic signed [95:0] extended=value;
    $display("UT: integral width %0d negative %0d arithmetic_shift %0d sign_extended %0d",
      $bits(value)==64,value<0,shifted==64'hc000000000000000,
      extended[95:64]==32'hffffffff && extended[63:0]==64'h8000000000000001);
    $finish;
  end
endmodule
