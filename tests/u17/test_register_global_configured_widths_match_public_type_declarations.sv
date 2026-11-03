/*
:name: test_register_global_configured_widths_match_public_type_declarations
:description: register global configured widths match public type declarations (IEEE 1800.2-2020 Section 17.2.1.3)
:tags: u17 uvm
:type: simulation
:lrm: 1800.2-2020 17.2.1.3 17.2.1.1 17.2.1.2 17.2.1.4 17.2.1.5 17.2.1.6 B.6.4 B.6.5 B.6.6 B.6.7 1800-2023 6.21 6.19
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_register_global_configured_widths_match_public_type_declarations.expected
:uvm_defines: UVM_REG_DATA_WIDTH=96 UVM_REG_ADDR_WIDTH=80 UVM_REG_BYTENABLE_WIDTH=16 UVM_REG_CVR_WIDTH=40
*/
// Width and representable upper bits are declaration checks. Logic aliases are
// checked for width only; X/Z storage and four-state execution remain open.
module test_register_global_configured_widths_match_public_type_declarations;
  import uvm_pkg::*;
  initial begin
    uvm_reg_data_t data;
    uvm_reg_data_logic_t logic_data;
    uvm_reg_addr_t addr;
    uvm_reg_addr_logic_t logic_addr;
    uvm_reg_byte_en_t lanes;
    uvm_reg_cvr_t models;
    $display("UT: declared data %0d logic_data %0d addr %0d logic_addr %0d lanes %0d models %0d",
             $bits(data), $bits(logic_data), $bits(addr), $bits(logic_addr),
             $bits(lanes), $bits(models));
    $display("UT: matches data %0d logic_data %0d addr %0d logic_addr %0d lanes %0d models %0d",
             $bits(data) == `UVM_REG_DATA_WIDTH, $bits(logic_data) == `UVM_REG_DATA_WIDTH,
             $bits(addr) == `UVM_REG_ADDR_WIDTH, $bits(logic_addr) == `UVM_REG_ADDR_WIDTH,
             $bits(lanes) == `UVM_REG_BYTENABLE_WIDTH, $bits(models) == `UVM_REG_CVR_WIDTH);
    data = '0; data[$bits(data)-1] = 1'b1;
    addr = '0; addr[$bits(addr)-1] = 1'b1;
    lanes = '0; lanes[$bits(lanes)-1] = 1'b1;
    models = '0; models[$bits(models)-1] = 1'b1;
    $display("UT: upper_bit data %0d addr %0d lanes %0d models %0d",
             data[$bits(data)-1], addr[$bits(addr)-1], lanes[$bits(lanes)-1],
             models[$bits(models)-1]);
    $finish;
  end
endmodule
