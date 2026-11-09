/*
:name: test_object_pack_longints_selects_default_policy
:description: object packing and unpacking select an installed default packer (IEEE 1800.2-2020 Section 5.3.10.1)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.10.1 5.3.10.2 5.3.11.1 5.3.11.2 16.5.2.4 16.5.2.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_pack_longints_selects_default_policy.expected
*/
// What it checks:
// 1. Object pack selects the default packer when its policy argument is
//    omitted.
// 2. Object unpack selects the default packer when its policy argument is
//    omitted.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.3.10.1 (UVM-OBJECT-PACK-DEFAULT) gives rule 1 above. Setup:
//    Install a counting default policy and use a longint stream. Expected:
//    Each default-policy hook runs once and the scalar payload is restored.
// 2. 1800.2-2020 5.3.11.1 (UVM-OBJECT-UNPACK-DEFAULT) gives rule 2 above.
//    Setup: Install a counting default policy and use a longint stream.
//    Expected: Each default-policy hook runs once and the scalar payload is
//    restored.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// An explicit default policy records the pack and unpack calls. Its
// custom counters are independent of the policy internal stream state.

module test_object_pack_longints_selects_default_policy;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_object;
    `uvm_object_utils(packet)
    int address = 0;
    int payload = 0;
    function new(string name="packet"); super.new(name); endfunction
    function void do_pack(uvm_packer packer);
      super.do_pack(packer);
      packer.pack_field_int(address, 12);
      packer.pack_field_int(payload, 8);
    endfunction
    function void do_unpack(uvm_packer packer);
      super.do_unpack(packer);
      address = int'(packer.unpack_field_int(12));
      payload = int'(packer.unpack_field_int(8));
    endfunction
  endclass

  class counting_packer extends uvm_packer;
    `uvm_object_utils(counting_packer)
    int packs = 0;
    int unpacks = 0;
    function new(string name="counting_packer"); super.new(name); endfunction
    function void pack_object(uvm_object value);
      packs++;
      super.pack_object(value);
    endfunction
    function void unpack_object(uvm_object value);
      unpacks++;
      super.unpack_object(value);
    endfunction
  endclass
  initial begin
    automatic packet source = new;
    automatic packet target = new;
    automatic counting_packer selected = new;
    automatic uvm_packer saved = uvm_packer::get_default();
    longint unsigned stream[];
    int count;
    uvm_packer::set_default(selected);
    source.address = 'h456;
    source.payload = 'h9a;
    count = source.pack_longints(stream);
    count = target.unpack_longints(stream);
    $display("UT: calls pack %0d unpack %0d", selected.packs, selected.unpacks);
    $display("UT: values %0h %0h", target.address, target.payload);
    uvm_packer::set_default(saved);
    $finish;
  end
endmodule
