/*
:name: test_reg_field_zero_selected_write_read_side_effects_keep_complementary_slices_independent
:description: W0SRC and W0CRS prediction composes zero-selected writes and opposite read effects (IEEE 1800.2-2020 Section 18.5.5.17)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.5.17 18.5.4.6 18.5.3.2 18.5.5.1 18.5.5.3 18.5.5.4 18.4.4.3 18.4.2.1 18.4.2.2 18.1.2.1 18.1.2.2 17.2.2.8 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_field_zero_selected_write_read_side_effects_keep_complementary_slices_independent.expected
*/
// The two fields exercise complementary zero-selected write rules. Read-side
// clear/set takes effect after sampling; subsequent writes use that new state.
module test_reg_field_zero_selected_write_read_side_effects_keep_complementary_slices_independent;
  import uvm_pkg::*;
  class model_block extends uvm_reg_block;
    function new(); super.new("blk", UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(); super.new("r", 16, UVM_NO_COVERAGE); endfunction
  endclass
  initial begin
    automatic model_block blk = new();
    automatic model_reg rg = new();
    automatic uvm_reg_field clear_after_read = new("clear_after_read");
    automatic uvm_reg_field set_after_read = new("set_after_read");
    bit first_ok;
    bit second_ok;
    blk.configure(); rg.configure(blk);
    clear_after_read.configure(rg, 8, 0, "W0SRC", 0, 'ha5, 1, 0, 1);
    set_after_read.configure(rg, 8, 8, "W0CRS", 0, 'ha5, 1, 0, 1);
    rg.reset();
    first_ok = clear_after_read.predict('hf, -1, UVM_PREDICT_WRITE);
    second_ok = set_after_read.predict('hf, -1, UVM_PREDICT_WRITE);
    $display("UT: 1 w ok %0d clear %0h/%0h set %0h/%0h assembled %0h", first_ok && second_ok,
             clear_after_read.get(), clear_after_read.get_mirrored_value(),
             set_after_read.get(), set_after_read.get_mirrored_value(), rg.get_mirrored_value());
    first_ok = clear_after_read.predict('hf0, -1, UVM_PREDICT_WRITE);
    second_ok = set_after_read.predict('hf0, -1, UVM_PREDICT_WRITE);
    $display("UT: 2 w ok %0d clear %0h/%0h set %0h/%0h assembled %0h", first_ok && second_ok,
             clear_after_read.get(), clear_after_read.get_mirrored_value(),
             set_after_read.get(), set_after_read.get_mirrored_value(), rg.get_mirrored_value());
    first_ok = clear_after_read.predict('hff, -1, UVM_PREDICT_READ);
    second_ok = set_after_read.predict('h0, -1, UVM_PREDICT_READ);
    $display("UT: 3 r ok %0d clear %0h/%0h set %0h/%0h assembled %0h", first_ok && second_ok,
             clear_after_read.get(), clear_after_read.get_mirrored_value(),
             set_after_read.get(), set_after_read.get_mirrored_value(), rg.get_mirrored_value());
    first_ok = clear_after_read.predict('hff, -1, UVM_PREDICT_WRITE);
    second_ok = set_after_read.predict('hff, -1, UVM_PREDICT_WRITE);
    $display("UT: 4 w ok %0d clear %0h/%0h set %0h/%0h assembled %0h", first_ok && second_ok,
             clear_after_read.get(), clear_after_read.get_mirrored_value(),
             set_after_read.get(), set_after_read.get_mirrored_value(), rg.get_mirrored_value());
    first_ok = clear_after_read.predict('h7e, -1, UVM_PREDICT_WRITE);
    second_ok = set_after_read.predict('h7e, -1, UVM_PREDICT_WRITE);
    $display("UT: 5 w ok %0d clear %0h/%0h set %0h/%0h assembled %0h", first_ok && second_ok,
             clear_after_read.get(), clear_after_read.get_mirrored_value(),
             set_after_read.get(), set_after_read.get_mirrored_value(), rg.get_mirrored_value());
    first_ok = clear_after_read.predict('h81, -1, UVM_PREDICT_READ);
    second_ok = set_after_read.predict('h7e, -1, UVM_PREDICT_READ);
    $display("UT: 6 r ok %0d clear %0h/%0h set %0h/%0h assembled %0h", first_ok && second_ok,
             clear_after_read.get(), clear_after_read.get_mirrored_value(),
             set_after_read.get(), set_after_read.get_mirrored_value(), rg.get_mirrored_value());
    $finish;
  end
endmodule
