/*
:name: test_object_pack_ints_reuses_policy_without_appending
:description: reusing an object packer replaces the previous integer stream (IEEE 1800.2-2020 Section 5.3.10.1)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.10.1 5.3.10.2 5.3.11.1 5.3.11.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_pack_ints_reuses_policy_without_appending.expected
*/
// Each top-level pack starts a new operation. Reusing the policy and
// stream must expose the second payload without retaining the first one.

module test_object_pack_ints_reuses_policy_without_appending;
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

  initial begin
    packet source = new;
    packet target = new;
    uvm_packer packer = new;
    int unsigned stream[];
    int count;
    source.address = 'h11;
    source.payload = 'h22;
    count = source.pack_ints(stream, packer);
    count = target.unpack_ints(stream, packer);
    $display("UT: first %0h %0h", target.address, target.payload);
    source.address = 'h312;
    source.payload = 'h7e;
    count = source.pack_ints(stream, packer);
    count = target.unpack_ints(stream, packer);
    $display("UT: second %0h %0h", target.address, target.payload);
    $finish;
  end
endmodule
