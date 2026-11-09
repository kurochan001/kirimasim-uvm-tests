/*
:name: test_register_prediction_endianness_and_coverage_symbols_preserve_independent_selection
:description: register prediction endianness and coverage symbols preserve independent selection (IEEE 1800.2-2020 Section 17.2.2.9)
:tags: u17 uvm
:type: simulation
:lrm: 1800.2-2020 17.2.2.9 17.2.2.8 17.2.2.4 17.2.1.6 1800-2023 6.21 6.19
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_register_prediction_endianness_and_coverage_symbols_preserve_independent_selection.expected
*/
// What it checks:
// 1. uvm_predict_e makes its documented named alternatives available.
// 2. uvm_endianness_e makes its documented named alternatives available.
// 3. uvm_coverage_model_e makes its documented named alternatives available.
// 4. Individual coverage models can be selected together using bitwise OR.
// 5. The selected individual coverage models remain distinguishable in a
//    combined set.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 17.2.2.8 (UVM-REG-GLOBAL-PREDICT-SYMBOLS) gives rule 1 above.
//    Setup: Each documented alternative is assigned in turn to a variable of
//    the public enum type. Expected: The assigned enum value identifies the
//    selected symbol by its standard SystemVerilog name query.
// 2. 1800.2-2020 17.2.2.4 (UVM-REG-GLOBAL-ENDIAN-SYMBOLS) gives rule 2 above.
//    Setup: Each documented alternative is assigned in turn to a variable of
//    the public enum type. Expected: The assigned enum value identifies the
//    selected symbol by its standard SystemVerilog name query.
// 3. 1800.2-2020 17.2.2.9 (UVM-REG-GLOBAL-COVERAGE-SYMBOLS) gives rule 3
//    above. Setup: Each documented alternative is assigned in turn to a
//    variable of the public enum type. Expected: The assigned enum value
//    identifies the selected symbol by its standard SystemVerilog name query.
// 4. 1800.2-2020 17.2.2.9 (UVM-REG-GLOBAL-COVERAGE-OR) gives rule 4 above.
//    Setup: Three distinct documented model identifiers are combined in
//    uvm_reg_cvr_t. Expected: The combined selection contains register bits,
//    address map and field values.
// 5. 1800.2-2020 17.2.2.9 (UVM-REG-GLOBAL-COVERAGE-INDEPENDENT-SELECTION)
//    gives rule 5 above. Setup: Three distinct documented model identifiers
//    are combined in uvm_reg_cvr_t. Expected: Clearing the address-map
//    selection retains the register-bit and field-value selections.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Symbol availability and composable coverage selections are observed without
// numeric encodings. No covergroup sampling, predictor side effects or
// physical
// byte transfer is inferred from enum names.
module test_register_prediction_endianness_and_coverage_symbols_preserve_independent_selection;
  import uvm_pkg::*;
  initial begin
    uvm_predict_e prediction;
    uvm_endianness_e order;
    uvm_coverage_model_e coverage_model;
    uvm_reg_cvr_t combined, selected;
    prediction = UVM_PREDICT_DIRECT; $display("UT: predict %s", prediction.name());
    prediction = UVM_PREDICT_READ; $display("UT: predict %s", prediction.name());
    prediction = UVM_PREDICT_WRITE; $display("UT: predict %s", prediction.name());
    order = UVM_NO_ENDIAN; $display("UT: endian %s", order.name());
    order = UVM_LITTLE_ENDIAN; $display("UT: endian %s", order.name());
    order = UVM_BIG_ENDIAN; $display("UT: endian %s", order.name());
    order = UVM_LITTLE_FIFO; $display("UT: endian %s", order.name());
    order = UVM_BIG_FIFO; $display("UT: endian %s", order.name());
    coverage_model = UVM_NO_COVERAGE; $display("UT: coverage %s", coverage_model.name());
    coverage_model = UVM_CVR_REG_BITS; $display("UT: coverage %s", coverage_model.name());
    coverage_model = UVM_CVR_ADDR_MAP; $display("UT: coverage %s", coverage_model.name());
    coverage_model = UVM_CVR_FIELD_VALS; $display("UT: coverage %s", coverage_model.name());
    coverage_model = UVM_CVR_ALL; $display("UT: coverage %s", coverage_model.name());
    combined = UVM_CVR_REG_BITS | UVM_CVR_ADDR_MAP | UVM_CVR_FIELD_VALS;
    selected = combined & ~uvm_reg_cvr_t'(UVM_CVR_ADDR_MAP);
    $display("UT: coverage_union bits %0d addr %0d fields %0d",
             (combined & UVM_CVR_REG_BITS) == UVM_CVR_REG_BITS,
             (combined & UVM_CVR_ADDR_MAP) == UVM_CVR_ADDR_MAP,
             (combined & UVM_CVR_FIELD_VALS) == UVM_CVR_FIELD_VALS);
    $display("UT: coverage_clear bits %0d addr %0d fields %0d",
             (selected & UVM_CVR_REG_BITS) == UVM_CVR_REG_BITS,
             (selected & UVM_CVR_ADDR_MAP) == UVM_NO_COVERAGE,
             (selected & UVM_CVR_FIELD_VALS) == UVM_CVR_FIELD_VALS);
    $finish;
  end
endmodule
