/*
:name: test_register_byte_enables_consume_each_fields_write_once_permission_independently
:description: Disabling a byte lane preserves the first write for the corresponding field (IEEE 1800.2-2020 Section 18.4.4.15)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.4.15 18.5.5.17 18.5.4.6 18.5.5.4 18.5.5.7 19.1.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_register_byte_enables_consume_each_fields_write_once_permission_independently.expected
*/
// Configure independent, byte-aligned W1 fields in a 16-bit register. Enable
// low, both, then high lanes. The first enabled write per lane sticks. Set
// distinct SOFT reset values, then attempt to write both lanes. A HARD reset
// rearms both, and reversing the enable order must reverse which lane accepts
// the next write. Check both desired and mirrored values at every step.

module test_register_byte_enables_consume_each_fields_write_once_permission_independently;
  import uvm_pkg::*;

  class block_model extends uvm_reg_block;
    function new(); super.new("model", UVM_NO_COVERAGE); endfunction
  endclass
  class word_reg extends uvm_reg;
    function new(); super.new("word_reg", 16, UVM_NO_COVERAGE); endfunction
  endclass

  word_reg word_value;
  uvm_reg_map mapping;

  function automatic void write_lanes(string label_text, uvm_reg_data_t data,
                                     uvm_reg_byte_en_t enabled);
    if (!word_value.predict(data, enabled, UVM_PREDICT_WRITE, UVM_FRONTDOOR, mapping))
      $fatal(1, "register prediction rejected");
    $display("UT: %s desired %0h mirror %0h", label_text,
             word_value.get(), word_value.get_mirrored_value());
  endfunction
  initial begin
    automatic block_model model = new();
    automatic uvm_reg_field low_field = new("low_field");
    automatic uvm_reg_field high_field = new("high_field");
    model.configure();
    word_value = new();
    word_value.configure(model);
    low_field.configure(word_value, 8, 0, "W1", 0, 'h34, 1, 0, 1);
    high_field.configure(word_value, 8, 8, "W1", 0, 'h12, 1, 0, 1);
    low_field.set_reset('h55, "SOFT");
    high_field.set_reset('haa, "SOFT");
    mapping = model.create_map("bus", 0, 2, UVM_LITTLE_ENDIAN);
    mapping.add_reg(word_value, 0);
    model.lock_model();
    model.reset();
    write_lanes("low", 'h2211, 1);
    write_lanes("both", 'h4433, 3);
    write_lanes("high", 'h6655, 2);
    model.reset("SOFT");
    write_lanes("soft", 'h8877, 3);
    model.reset();
    write_lanes("high first", 'h9cab, 2);
    write_lanes("low last", 'hcdef, 3);
    $finish;
  end
endmodule
