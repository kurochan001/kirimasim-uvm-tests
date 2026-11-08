/*
:name: test_fourstate_config_db_values_117
:description: configuration-database lookups return four-state X and Z bits exactly as they were set (IEEE 1800.2-2020 Section C.4.2.2.2)
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.4.2.2.2 C.4.2.2.1 C.4.2.3.1 F.2.1.3 1800-2023 5.7.1 6.3.1 6.11 11.4.5 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_fourstate_config_db_values_117.expected
*/
// A typed logic setting and a uvm_config_int setting carry X and Z bits. Each
// lookup must find its setting and return the same bits, compared with case
// equality. The expectation comes from the cited clauses; a two-state simulator
// cannot represent X or Z, so this case is spec-only. Only the lines that begin
// with "UT: " are compared.
module test_fourstate_config_db_values_117;
  import uvm_pkg::*;


  initial begin
    automatic logic [7:0] narrow = 8'b1x0z_10xz;
    automatic uvm_bitstream_t wide = 'b1x0z;
    automatic logic [7:0] narrow_got = 8'h00;
    automatic uvm_bitstream_t wide_got = 0;
    bit narrow_found;
    bit wide_found;
    uvm_config_db #(logic [7:0])::set(null, "*", "narrow117", narrow);
    narrow_found = uvm_config_db #(logic [7:0])::get(null, "probe117", "narrow117", narrow_got);
    uvm_config_int::set(null, "*", "wide117", wide);
    wide_found = uvm_config_int::get(null, "probe117", "wide117", wide_got);
    $display("UT: narrow found %0d same %0d", narrow_found, narrow_got === 8'b1x0z_10xz);
    $display("UT: wide found %0d same %0d", wide_found, wide_got === wide);
    $finish;
  end
endmodule
