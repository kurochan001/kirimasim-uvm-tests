/*
:name: test_reg_field_volatility_updates_do_not_modify_desired_or_mirrored_values
:description: volatility updates remain local and preserve desired and mirrored state (IEEE 1800.2-2020 Section 18.5.4.9)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.4.9 18.5.4.10 18.5.5.1 18.5.5.3 18.5.3.1 18.5.3.2 18.1.2.1 18.1.2.2 18.4.2.1 18.4.2.2 18.5.5.4 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_field_volatility_updates_do_not_modify_desired_or_mirrored_values.expected
*/
// What it checks:
// 1. Volatility updates affect only the selected field setting.
// 2. Volatility queries preserve independent neighbor and peer settings.
// 3. get returns the field desired model value without a bus read.
// 4. get_mirrored_value returns the field mirrored model value without a bus
//    read.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.5.4.9 (UVM-FIELD-VOLATILITY-LOCAL-CONTROL) gives rule 1
//    above. Setup: Enable, disable and move the volatile setting between two
//    fields. Expected: Settings stay local and desired/mirrored data remain
//    11.
// 2. 1800.2-2020 18.5.4.10 (UVM-FIELD-INTROSPECTION-VOLATILITY-PEER-ISOLATION)
//    gives rule 2 above. Setup: One field and a peer are switched
//    independently. Expected: Queries identify each selected field while the
//    neighbor remains nonvolatile.
// 3. 1800.2-2020 18.5.5.1 (UVM-FIELD-INTROSPECTION-DESIRED-QUERY) gives rule 3
//    above. Setup: Volatility changes do not change the prepared desired value
//    0x11. Expected: The desired getter still returns 0x11.
// 4. 1800.2-2020 18.5.5.3 (UVM-FIELD-INTROSPECTION-MIRRORED-QUERY) gives rule
//    4 above. Setup: Volatility changes do not change the prepared mirror
//    0x11. Expected: The mirrored getter still returns 0x11.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Model-only field metadata and desired/mirrored state. No bus, RTL or DPI
// is accessed, and policy controls do not establish physical side effects.
module test_reg_field_volatility_updates_do_not_modify_desired_or_mirrored_values;
  import uvm_pkg::*;

  class model_block extends uvm_reg_block;
    function new(string name="blk"); super.new(name, UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(string name="r", int unsigned width=16);
      super.new(name, width, UVM_NO_COVERAGE);
    endfunction
  endclass
  model_block blk;
  model_reg first_reg, second_reg;
  uvm_reg_field first_field, neighbor, peer;
  function automatic void build_model(bit first_has_reset=1);
    blk = new("blk"); blk.configure();
    first_reg = new("first"); first_reg.configure(blk);
    second_reg = new("second"); second_reg.configure(blk);
    first_field = new("first_field"); neighbor = new("neighbor"); peer = new("peer");
    first_field.configure(first_reg, 8, 0, "RW", 0, 8'h11, first_has_reset, 0, 1);
    neighbor.configure(first_reg, 8, 8, "RW", 0, 8'h22, 1, 0, 1);
    peer.configure(second_reg, 8, 0, "RW", 0, 8'h33, 1, 0, 1);
    first_field.reset(); neighbor.reset(); peer.reset();
  endfunction

  initial begin

    build_model();

    first_field.set_volatility(1);
    $display("UT: volatile first %0d neighbor %0d peer %0d", first_field.is_volatile(),
    neighbor.is_volatile(), peer.is_volatile());
    first_field.set_volatility(0); peer.set_volatility(1);
    $display("UT: switched first %0d peer %0d desired %0h mirror %0h", first_field.is_volatile(),
    peer.is_volatile(), first_field.get(), first_field.get_mirrored_value());
    $finish;
  end

endmodule
