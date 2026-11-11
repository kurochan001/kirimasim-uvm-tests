/*
:name: test_register_constructor_keeps_default_names_partial_bit_widths_and_available_coverage
:description: register constructor keeps default names partial bit widths and available coverage
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.2.1 18.4.1 18.4.3.8 18.4.3.9 18.4.7.4 5.3.4.2 18.5.3.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_register_constructor_keeps_default_names_partial_bit_widths_and_available_coverage.expected
*/
// What it checks:
// 1. The selected register is usable through an object base view and casts
//    back to the same register handle.
// 2. Register construction preserves the selected explicit instance name.
// 3. Omitting the base register constructor name uses the declared
//    empty-string default while supplying the required width and coverage
//    arguments.
// 4. The declared total register width is retained even when selected fields
//    implement only part of those bits.
// 5. The selected register constructor advertises all supplied coverage models
//    without adding an absent model or changing the separate no-coverage
//    instance.
// 6. Selected register bit widths remain exact across one-bit, byte-boundary
//    and partial-byte cases.
// 7. The selected register byte width rounds partial bytes up to the next
//    whole byte.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.4.1 (UVM-REGISTER-CONTRACT-OBJECT-BASE) gives rule 1
//    above. Setup: Use the selected original register/block/file models and
//    explicit public calls. Constructor-only observations do not require
//    mapped physical hardware. Membership is queried through the register view
//    after selected legal registrations/removals; output queues start empty.
//    Expected: The selected register is usable through an object base view and
//    casts back to the same register handle.
// 2. 1800.2-2020 18.4.2.1 (UVM-REGISTER-CONTRACT-NEW-NAME) gives rule 2 above.
//    Setup: Use the selected original register/block/file models and explicit
//    public calls. Constructor-only observations do not require mapped
//    physical hardware. Membership is queried through the register view after
//    selected legal registrations/removals; output queues start empty.
//    Expected: Register construction preserves the selected explicit instance
//    name.
// 3. 1800.2-2020 18.4.2.1 (UVM-REGISTER-CONTRACT-NEW-DEFAULT-NAME) gives rule
//    3 above. Setup: Use the selected original register/block/file models and
//    explicit public calls. Constructor-only observations do not require
//    mapped physical hardware. Membership is queried through the register view
//    after selected legal registrations/removals; output queues start empty.
//    Expected: Omitting the base register constructor name uses the declared
//    empty-string default while supplying the required width and coverage
//    arguments.
// 4. 1800.2-2020 18.4.2.1 (UVM-REGISTER-CONTRACT-NEW-PARTIAL-WIDTH) gives rule
//    4 above. Setup: Use the selected original register/block/file models and
//    explicit public calls. Constructor-only observations do not require
//    mapped physical hardware. Membership is queried through the register view
//    after selected legal registrations/removals; output queues start empty.
//    Expected: The declared total register width is retained even when
//    selected fields implement only part of those bits.
// 5. 1800.2-2020 18.4.2.1 (UVM-REGISTER-CONTRACT-NEW-COVERAGE-MASK) gives rule
//    5 above. Setup: Use the selected original register/block/file models and
//    explicit public calls. Constructor-only observations do not require
//    mapped physical hardware. Membership is queried through the register view
//    after selected legal registrations/removals; output queues start empty.
//    Expected: The selected register constructor advertises all
//    supplied coverage models without adding an absent model or changing the
//    separate no-coverage instance.
// 6. 1800.2-2020 18.4.3.8 (UVM-REGISTER-CONTRACT-WIDTH-BITS) gives rule 6
//    above. Setup: Use the selected original register/block/file models and
//    explicit public calls. Constructor-only observations do not require
//    mapped physical hardware. Membership is queried through the register view
//    after selected legal registrations/removals; output queues start empty.
//    Expected: Selected register bit widths remain exact across one-bit,
//    byte-boundary and partial-byte cases.
// 7. 1800.2-2020 18.4.3.9 (UVM-REGISTER-CONTRACT-WIDTH-CEILING-BYTES) gives
//    rule 7 above. Setup: Use the selected original register/block/file models
//    and explicit public calls. Constructor-only observations do not require
//    mapped physical hardware. Membership is queried through the register view
//    after selected legal registrations/removals; output queues start empty.
//    Expected: The selected register byte width rounds partial bytes up to the
//    next whole byte.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_register_constructor_keeps_default_names_partial_bit_widths_and_available_coverage;
  import uvm_pkg::*;
  class block_type extends uvm_reg_block;
    function new(string name);super.new(name,UVM_NO_COVERAGE);endfunction
  endclass
  class register_type extends uvm_reg;
    function new(string name,int unsigned width=16,int coverage_models=UVM_NO_COVERAGE);
      super.new(name,width,coverage_models);
    endfunction
  endclass

  class unnamed_register extends uvm_reg;
    function new();super.new(.n_bits(13),.has_coverage(UVM_NO_COVERAGE));endfunction
  endclass
  initial begin
    automatic unnamed_register unnamed=new();
    automatic register_type selected=new("chosen52",13,UVM_CVR_REG_BITS|UVM_CVR_FIELD_VALS);
    automatic block_type owner=new("owner52");
    automatic uvm_reg_field bits_value=uvm_reg_field::type_id::create("bits52");
    uvm_object object_view;
    uvm_reg back;
    automatic int widths[5]='{1,8,9,16,17};
    owner.configure();selected.configure(owner);
    bits_value.configure(selected,8,0,"RW",0,0,1,0,0);
    object_view=selected;
    $display("UT: register_new default_name %0d selected_name %0d object_view %0d partial %0d",
      unnamed.get_name()=="",selected.get_name()=="chosen52",
      $cast(back,object_view) && back==selected,selected.get_n_bits()==13);
    $display("UT: register_new coverage_all %0d coverage_missing %0d independent_none %0d",
      selected.has_coverage(UVM_CVR_REG_BITS|UVM_CVR_FIELD_VALS),
      !selected.has_coverage(UVM_CVR_ADDR_MAP),!unnamed.has_coverage(UVM_CVR_REG_BITS));
    foreach (widths[i]) begin
      automatic register_type value=new($sformatf("width52_%0d",i),widths[i]);
      $display("UT: register_width bits %0d bytes %0d",value.get_n_bits(),value.get_n_bytes());
    end
    $finish;
  end
endmodule
