/*
:name: test_reg_registered_post_predict_callback_changes_the_predicted_field_value
:description: registered post-predict callback changes the predicted field value (IEEE 1800.2-2020 Section 18.11.2.6)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.11.2.6 18.5.5.17 18.4.4.15 D.4.5.7 18.4.2.1 18.4.2.2 18.5.3.2 18.1.2.1 18.1.2.2 1800-2023 6.21 8.19
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_registered_post_predict_callback_changes_the_predicted_field_value.expected
*/
// A registered field callback observes the previous mirror and READ prediction,
// then replaces the predicted value. No bus access is performed.

module test_reg_registered_post_predict_callback_changes_the_predicted_field_value;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class model_block extends uvm_reg_block;
    function new(); super.new("blk", UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(); super.new("r", 8, UVM_NO_COVERAGE); endfunction
  endclass

  class prediction_watch extends uvm_reg_cbs;
    int calls = 0;
    uvm_reg_field seen_field;
    uvm_reg_data_t seen_previous;
    bit seen_read;
    function new(); super.new("watch"); endfunction
    virtual function void post_predict(input uvm_reg_field fld,
        input uvm_reg_data_t previous, inout uvm_reg_data_t value,
        input uvm_predict_e kind, input uvm_door_e path, input uvm_reg_map map);
      calls++;
      seen_field = fld;
      seen_previous = previous;
      seen_read = kind == UVM_PREDICT_READ;
      value = 'h5c;
    endfunction
  endclass
  initial begin
    automatic model_block blk = new();
    automatic model_reg rg = new();
    automatic uvm_reg_field field = new("value");
    automatic prediction_watch cb = new();
    automatic bit ok;
    blk.configure();
    rg.configure(blk);
    field.configure(rg, 8, 0, "RW", 0, 'h11, 1, 0, 1);
    rg.reset();
    uvm_reg_field_cb::add(field, cb);
    ok = rg.predict('ha6, -1, UVM_PREDICT_READ, UVM_FRONTDOOR);
    $display("UT: ok %0d calls %0d field %0d previous %0h read %0d desired %0h mirror %0h",
             ok, cb.calls, cb.seen_field == field, cb.seen_previous, cb.seen_read,
             rg.get(), rg.get_mirrored_value());
    uvm_reg_field_cb::delete(field, cb);
    $finish;
  end
endmodule
