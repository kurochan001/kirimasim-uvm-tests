/*
:name: test_register_global_default_widths_match_public_type_declarations
:description: register global default widths match public type declarations (IEEE 1800.2-2020 Section 17.2.1.1)
:tags: u17 uvm
:type: simulation
:lrm: 1800.2-2020 17.2.1.1 17.2.1.2 17.2.1.3 17.2.1.4 17.2.1.5 17.2.1.6 B.6.4 B.6.5 B.6.6 B.6.7 1800-2023 6.21 6.19
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_register_global_default_widths_match_public_type_declarations.expected
*/
// What it checks:
// 1. uvm_reg_data_t has the width specified by UVM_REG_DATA_WIDTH.
// 2. uvm_reg_data_logic_t has the width specified by UVM_REG_DATA_WIDTH.
// 3. uvm_reg_addr_t has the width specified by UVM_REG_ADDR_WIDTH.
// 4. uvm_reg_addr_logic_t has the width specified by UVM_REG_ADDR_WIDTH.
// 5. uvm_reg_byte_en_t has the width specified by UVM_REG_BYTENABLE_WIDTH.
// 6. uvm_reg_cvr_t has the width specified by UVM_REG_CVR_WIDTH.
// 7. The default UVM_REG_ADDR_WIDTH setting supplies the documented type
//    extent.
// 8. The default UVM_REG_DATA_WIDTH setting supplies the documented type
//    extent.
// 9. The default UVM_REG_BYTENABLE_WIDTH setting supplies the documented type
//    extent.
// 10. The default UVM_REG_CVR_WIDTH setting supplies the documented type
//     extent.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 17.2.1.1 (UVM-REG-GLOBAL-DATA-WIDTH) gives rule 1 above.
//    Setup: The pinned library is compiled once with defaults and once with
//    selected independent macro settings. Expected: The declared type width
//    equals the corresponding active macro in both configurations.
// 2. 1800.2-2020 17.2.1.2 (UVM-REG-GLOBAL-LOGIC-DATA-WIDTH) gives rule 2
//    above. Setup: The pinned library is compiled once with defaults and once
//    with selected independent macro settings. Expected: The declared type
//    width equals the corresponding active macro in both configurations.
// 3. 1800.2-2020 17.2.1.3 (UVM-REG-GLOBAL-ADDRESS-WIDTH) gives rule 3 above.
//    Setup: The pinned library is compiled once with defaults and once with
//    selected independent macro settings. Expected: The declared type width
//    equals the corresponding active macro in both configurations.
// 4. 1800.2-2020 17.2.1.4 (UVM-REG-GLOBAL-LOGIC-ADDRESS-WIDTH) gives rule 4
//    above. Setup: The pinned library is compiled once with defaults and once
//    with selected independent macro settings. Expected: The declared type
//    width equals the corresponding active macro in both configurations.
// 5. 1800.2-2020 17.2.1.5 (UVM-REG-GLOBAL-BYTE-ENABLE-WIDTH) gives rule 5
//    above. Setup: The pinned library is compiled once with defaults and once
//    with selected independent macro settings. Expected: The declared type
//    width equals the corresponding active macro in both configurations.
// 6. 1800.2-2020 17.2.1.6 (UVM-REG-GLOBAL-COVERAGE-WIDTH) gives rule 6 above.
//    Setup: The pinned library is compiled once with defaults and once with
//    selected independent macro settings. Expected: The declared type width
//    equals the corresponding active macro in both configurations.
// 7. 1800.2-2020 B.6.4 (UVM-REG-GLOBAL-ADDRESS-DEFAULT-MACRO) gives rule 7
//    above. Setup: No width macros are supplied; the default data width is 64
//    bits. Expected: The associated declared width is 64 bits.
// 8. 1800.2-2020 B.6.5 (UVM-REG-GLOBAL-DATA-DEFAULT-MACRO) gives rule 8 above.
//    Setup: No width macros are supplied; the default data width is 64 bits.
//    Expected: The associated declared width is 64 bits.
// 9. 1800.2-2020 B.6.6 (UVM-REG-GLOBAL-BYTE-ENABLE-DEFAULT-MACRO) gives rule 9
//    above. Setup: No width macros are supplied; the default data width is 64
//    bits. Expected: The associated declared width is 8 bits.
// 10. 1800.2-2020 B.6.7 (UVM-REG-GLOBAL-COVERAGE-DEFAULT-MACRO) gives rule 10
//     above. Setup: No width macros are supplied; the default data width is 64
//     bits. Expected: The associated declared width is 32 bits.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Width and representable upper bits are declaration checks. Logic aliases are
// checked for width only; X/Z storage and four-state execution remain open.
module test_register_global_default_widths_match_public_type_declarations;
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
