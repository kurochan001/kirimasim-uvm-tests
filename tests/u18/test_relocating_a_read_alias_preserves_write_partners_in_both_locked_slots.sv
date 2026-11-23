/*
:name: test_relocating_a_read_alias_preserves_write_partners_in_both_locked_slots
:description: Moving a readable alias between occupied write slots preserves both write partners and its other map (IEEE 1800.2-2020 Section 18.4.2.3)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.2.3 18.2.4.17 18.4.3.14 18.2.3.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_relocating_a_read_alias_preserves_write_partners_in_both_locked_slots.expected
*/
// Two write-only registers occupy different byte addresses. A read-only
// register initially shares the first and also has an independent address in
// another map. Move the readable register to the second slot, then restore
// it. Query each write partner in its legal direction after each move,
// including the slot vacated by the reader.

module test_relocating_a_read_alias_preserves_write_partners_in_both_locked_slots;
  import uvm_pkg::*;

  class block_model extends uvm_reg_block;
    function new(); super.new("model", UVM_NO_COVERAGE); endfunction
  endclass
  class byte_reg extends uvm_reg;
    function new(string name, block_model model, string access);
      uvm_reg_field data_field;
      super.new(name, 8, UVM_NO_COVERAGE);
      configure(model);
      data_field = new("data_field");
      data_field.configure(this, 8, 0, access, 0, 0, 1, 0, 1);
    endfunction
  endclass

  block_model model;
  byte_reg reader, first_writer, second_writer;
  uvm_reg_map main_map, peer_map;

  function automatic void snapshot(string label_text, uvm_reg_addr_t read_at);
    $display("UT: %s address %0h reader %0d writes %0d %0d peer %0d", label_text,
             reader.get_address(main_map), main_map.get_reg_by_offset(read_at, 1) == reader,
             main_map.get_reg_by_offset('h10, 0) == first_writer,
             main_map.get_reg_by_offset('h20, 0) == second_writer,
             peer_map.get_reg_by_offset('h50, 1) == reader && reader.get_address(peer_map) == 'h50);
  endfunction

  initial begin
    model = new();
    model.configure();
    reader = new("reader", model, "RO");
    first_writer = new("first_writer", model, "WO");
    second_writer = new("second_writer", model, "WO");
    main_map = model.create_map("main", 0, 1, UVM_LITTLE_ENDIAN);
    peer_map = model.create_map("peer", 0, 1, UVM_LITTLE_ENDIAN);
    main_map.add_reg(first_writer, 'h10, "WO");
    main_map.add_reg(second_writer, 'h20, "WO");
    main_map.add_reg(reader, 'h10, "RO");
    peer_map.add_reg(reader, 'h50, "RO");
    model.lock_model();
    snapshot("initial", 'h10);
    reader.set_offset(main_map, 'h20);
    snapshot("moved", 'h20);
    reader.set_offset(main_map, 'h10);
    snapshot("restored", 'h10);
    $finish;
  end
endmodule
