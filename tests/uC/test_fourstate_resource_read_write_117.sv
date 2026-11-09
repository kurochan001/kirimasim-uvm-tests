/*
:name: test_fourstate_resource_read_write_117
:description: a typed resource returns four-state X and Z bits exactly as written and replaces them with a definitely different value (IEEE 1800.2-2020 Section C.2.5.4.1)
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.5.4.1 C.2.5.4.2 C.2.5.2 1800-2023 5.7.1 6.3.1 6.11 11.4.5 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_fourstate_resource_read_write_117.expected
*/
// What it checks:
// A typed resource read returns the written four-state value with its X and Z
// bits unchanged.
//
// How the expected output follows from the standard:
// 1800.2-2020 C.2.5.4.1 (UVM-FOURSTATE-RESOURCE-PRESERVES-XZ) gives the rule
// above. Setup: Write an 8-bit logic value with X and Z bits, read it, then
// write a value that differs in known bits and read again. Expected: Each read
// returns the bits most recently written.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The second value differs from the first in known bits, so the write cannot be
// skipped as an equal value under any reading of equality. Each read must
// return the written bits, compared with case equality. The expectation comes
// from the cited clauses; a two-state simulator cannot represent X or Z, so
// this case is spec-only. Only the lines that begin with "UT: " are compared.
module test_fourstate_resource_read_write_117;
  import uvm_pkg::*;


  initial begin
    automatic uvm_resource #(logic [7:0]) resource = new("fourstate117");
    automatic logic [7:0] first = 8'b1x0z_1010;
    automatic logic [7:0] second = 8'b0z1x_0101;
    resource.write(first);
    $display("UT: first same %0d", resource.read() === 8'b1x0z_1010);
    resource.write(second);
    $display("UT: second same %0d", resource.read() === 8'b0z1x_0101);
    $finish;
  end
endmodule
