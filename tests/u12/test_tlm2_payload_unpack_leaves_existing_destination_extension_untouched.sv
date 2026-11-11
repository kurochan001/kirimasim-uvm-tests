/*
:name: test_tlm2_payload_unpack_leaves_existing_destination_extension_untouched
:description: generic payload packing and unpacking preserve the prescribed fields and lengths (IEEE 1800.2-2020 Section 12.3.4.2.4)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.2.4 12.3.4.2.5 12.3.4.2.43 12.3.4.2.44 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_payload_unpack_leaves_existing_destination_extension_untouched.expected
*/
// What it checks:
// Default generic-payload unpacking leaves preinstalled destination extensions
// untouched.
//
// How the expected output follows from the standard:
// 1800.2-2020 12.3.4.2.5 (UVM-GP-DEFAULT-UNPACK-PRESERVES-EXTENSIONS) gives
// the rule above. Setup: Unpack ordinary payload fields into a target with an
// existing valued extension. In additional independent profiles, apply a
// hand-written typed packer stream to a plain or original observed payload,
// with empty/nonempty active arrays, retained extension value 63 and two
// rounds on the same target. Expected: Address updates while extension
// identity/value remain and its unpack hook is not called. After each added
// unpack, the original extension handle and value 63 remain and its unpack
// hook has not run, while ordinary scalar and active-prefix fields receive the
// incoming values.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Preinstall an extension at the destination and unpack an ordinary
// payload. The extension is outside the default serialized fields; its
// identity, value and unpack hook remain unchanged.

module test_tlm2_payload_unpack_leaves_existing_destination_extension_untouched;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class label_extension extends uvm_tlm_extension#(label_extension);
    `uvm_object_utils(label_extension)
    static int pack_calls = 0;
    static int unpack_calls = 0;
    int value = 0;
    function new(string name="label_extension"); super.new(name); endfunction
    function void do_pack(uvm_packer packer); pack_calls++; endfunction
    function void do_unpack(uvm_packer packer); unpack_calls++; endfunction
  endclass

  initial begin
    automatic uvm_tlm_generic_payload source = new("source");
    automatic uvm_tlm_generic_payload target = new("target");
    automatic uvm_packer packer = new;
    automatic label_extension label_value = new("label_value");
    uvm_tlm_extension_base previous;
    label_value.value = 63;
    previous = target.set_extension(label_value);
    source.set_address(91);
    source.do_pack(packer);
    target.do_unpack(packer);
    $display("UT: address %0d extension_same %0d value %0d unpack_calls %0d",
             target.get_address(), target.get_extension(label_extension::ID()) == label_value,
             label_value.value, label_extension::unpack_calls);
    $finish;
  end
endmodule
