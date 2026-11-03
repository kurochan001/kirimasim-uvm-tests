/*
:name: test_command_factory_instance_override_precedes_the_type_override_for_its_target
:description: command factory instance override precedes the type override for its target (IEEE 1800.2-2020 Section G.2.7)
:tags: uG uvm
:type: simulation
:lrm: 1800.2-2020 G.2.7 8.2.3.2 B.2.1.2 B.2.1.3 1800-2023 6.21
:uvm: 2020.3.1
:uvm_dpi: yes
:uvm_cmdline_backend: vpi
:uvm_cmdline_oracle: verilator@5.052
:uvm_defines: UVM_HDL_NO_DPI
:dpi_c: @../../tools/cmdline_backend/uvm_cmdline_vpi.cpp
:files: ../../tools/cmdline_backend/uvm_cmdline_regex.cpp ../../tools/cmdline_backend/malloc.h
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:args: +uvm_set_type_override=base_packet,type_packet +uvm_set_inst_override=base_packet,instance_packet,uvm_test_top.target
:expected_stdout: @test_command_factory_instance_override_precedes_the_type_override_for_its_target.expected
*/
// Observe actual factory-created dynamic proxies. These literal paths do not
// test replacement-flag variants, wildcards or override loops.
module test_command_factory_instance_override_precedes_the_type_override_for_its_target;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class base_packet extends uvm_object;
    `uvm_object_utils(base_packet)
    function new(string name="base"); super.new(name); endfunction
  endclass
  class type_packet extends base_packet;
    `uvm_object_utils(type_packet)
    function new(string name="type"); super.new(name); endfunction
  endclass
  class instance_packet extends base_packet;
    `uvm_object_utils(instance_packet)
    function new(string name="instance"); super.new(name); endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
      automatic base_packet target = base_packet::type_id::create("target", this);
      automatic base_packet peer = base_packet::type_id::create("peer", this);
      $display("UT: factory target %0d peer %0d",
               target.get_object_type() == instance_packet::get_type(),
               peer.get_object_type() == type_packet::get_type());
    endtask
  endclass
  initial begin
    uvm_object_wrapper wrappers[3];
    wrappers[0] = base_packet::get_type(); wrappers[1] = type_packet::get_type();
    wrappers[2] = instance_packet::get_type(); run_test("t");
  end
endmodule
