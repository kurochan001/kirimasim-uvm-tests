/*
:name: test_port_base_preserves_names_parents_and_each_interface_role
:description: port base exposes configured hierarchy and role without binding resolution (5.5.2.2)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.5.2.2 5.5.2.3 5.5.2.4 5.5.2.5 5.5.2.11 5.5.2.1 12.2.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_port_base_preserves_names_parents_and_each_interface_role.expected
*/
// What it checks:
// 1. A port base returns its configured leaf name for each role.
// 2. Port full names include their parent hierarchy and leaf names.
// 3. A port base exposes the exact configured parent component.
// 4. Role predicates identify port, export and implementation kinds
//    exclusively.
// 5. A subtype without a type-name override receives the prescribed generic
//    role name.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.5.2.2 (UVM-PORT-LEAF-NAMES) gives rule 1 above. Setup:
//    Create three concrete base subclasses with distinct roles and no query
//    overrides under owner. Expected: Names are p/e/i for the three configured
//    handles.
// 2. 1800.2-2020 5.5.2.3 (UVM-PORT-FULL-HIERARCHICAL-NAMES) gives rule 2
//    above. Setup: Create three concrete base subclasses with distinct roles
//    and no query overrides under owner. Expected: Full names are
//    owner.p/owner.e/owner.i.
// 3. 1800.2-2020 5.5.2.4 (UVM-PORT-EXACT-PARENT-HANDLES) gives rule 3 above.
//    Setup: Create three concrete base subclasses with distinct roles and no
//    query overrides under owner. Expected: All three parent queries return
//    the same exact owner handle.
// 4. 1800.2-2020 5.5.2.11 (UVM-PORT-ROLE-PREDICATES) gives rule 4 above.
//    Setup: Create three concrete base subclasses with distinct roles and no
//    query overrides under owner. Expected: Only the matching predicate is
//    true for each of the three roles.
// 5. 1800.2-2020 5.5.2.5 (UVM-PORT-GENERIC-TYPE-NAMES) gives rule 5 above.
//    Setup: Create three concrete base subclasses with distinct roles and no
//    query overrides under owner. Expected: Generic names are uvm_port,
//    uvm_export and uvm_implementation.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_port_base_preserves_names_parents_and_each_interface_role;
  import uvm_pkg::*;
  class holder extends uvm_component;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
  class probe_port extends uvm_port_base#(uvm_tlm_if_base#(int, int));
    function new(string name, uvm_component parent, uvm_port_type_e kind = UVM_PORT,
                 int minimum = 0, int maximum = 1);
      super.new(name, parent, kind, minimum, maximum);
    endfunction
  endclass
  initial begin
    automatic holder owner = new("owner", null);
    automatic probe_port p = new("p", owner, UVM_PORT);
    automatic probe_port e = new("e", owner, UVM_EXPORT);
    automatic probe_port i = new("i", owner, UVM_IMPLEMENTATION);
    $display("UT: names %0d fullnames %0d parents %0d",
             p.get_name() == "p" && e.get_name() == "e" && i.get_name() == "i",
             p.get_full_name() == "owner.p" && e.get_full_name() == "owner.e" &&
             i.get_full_name() == "owner.i",
             p.get_parent() == owner && e.get_parent() == owner && i.get_parent() == owner);
    $display("UT: roles port %0d export %0d imp %0d",
             p.is_port() && !p.is_export() && !p.is_imp(),
             e.is_export() && !e.is_port() && !e.is_imp(),
             i.is_imp() && !i.is_port() && !i.is_export());
    $display("UT: generic_types port %0d export %0d imp %0d",
             p.get_type_name() == "uvm_port", e.get_type_name() == "uvm_export",
             i.get_type_name() == "uvm_implementation");
    $finish;
  end
endmodule
