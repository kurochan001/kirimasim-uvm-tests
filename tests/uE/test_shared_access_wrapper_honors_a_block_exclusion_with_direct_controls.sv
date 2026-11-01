/*
:name: test_shared_access_wrapper_honors_a_block_exclusion_with_direct_controls
:description: shared access wrapper honors a block exclusion with direct controls (IEEE 1800.2-2020 Section E.4.3)
:tags: uE uvm
:type: simulation
:lrm: 1800.2-2020 E.4.3 E.4.1 E.4.2 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.1.5.3 18.2.3.3 18.2.3.4 18.2.3.5 18.2.3.6 18.2.5.2 18.4.2.1 18.4.2.2 18.4.4.9 18.4.4.10 18.4.4.14 18.4.6.2 18.5.3.2 18.6.3.1 18.6.3.2 18.6.5.1 18.6.5.2 18.6.5.5 18.6.5.6 18.6.7.2 19.4.1.2 19.4.1.3.1 19.4.2.1 19.4.2.2.1 19.4.2.2.2 19.4.2.3 19.1.1.2.1 19.1.1.2.2 19.1.1.2.3 19.1.1.2.4 19.1.1.2.6 19.1.1.2.8 19.1.1.2.9 19.5.1 19.5.2.1 19.5.2.2 19.5.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 C.3.2.3.1 6.6.3.2 6.6.5 D.4.4 15.5.2.5 1800-2023 6.21 8.19
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_shared_access_wrapper_honors_a_block_exclusion_with_direct_controls.expected
*/
// Positive-delay handlers share testbench storage. Data and access coverage
// are normalized instead of printing seed-dependent random payloads.

module test_shared_access_wrapper_honors_a_block_exclusion_with_direct_controls;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  bit memory_started = 0;
  bit register_after_memory = 0;
  class model_block extends uvm_reg_block;
    function new(string name="blk"); super.new(name, UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(string name="r"); super.new(name, 8, UVM_NO_COVERAGE); endfunction
  endclass
  class storage_bank extends uvm_object;
    uvm_reg_data_t data[uvm_reg_addr_t];
    int last_writer[uvm_reg_addr_t];
    function new(string name="bank"); super.new(name); endfunction
  endclass
  class storage_frontdoor extends uvm_reg_frontdoor;
    storage_bank bank;
    int port_id = 0;
    uvm_reg_data_t read_xor = 0;
    int reads = 0;
    int writes = 0;
    bit [3:0] read_locations = 0;
    bit [3:0] written_locations = 0;
    bit [3:0] from_locations[3];
    function new(string name="fd"); super.new(name); endfunction
    function void clear_observations();
      reads = 0;
      writes = 0;
      read_locations = 0;
      written_locations = 0;
      foreach (from_locations[i]) from_locations[i] = 0;
    endfunction
    function bit idle(); return reads == 0 && writes == 0; endfunction
    function bit locations_complete();
      return read_locations == 'hf && written_locations == 'hf;
    endfunction
    virtual task body();
      uvm_reg_addr_t location;
      int writer;
      if (rw_info == null || bank == null) $fatal(1, "incomplete frontdoor fixture");
      if (rw_info.get_element_kind() == UVM_MEM) memory_started = 1;
      else if (memory_started) register_after_memory = 1;
      location = rw_info.get_element_kind() == UVM_MEM ? rw_info.get_offset() : 0;
      #1;
      if (rw_info.get_kind() == UVM_WRITE) begin
        writes++;
        written_locations[location] = 1;
        bank.data[location] = rw_info.get_value(0) & 'hff;
        bank.last_writer[location] = port_id;
      end else begin
        reads++;
        read_locations[location] = 1;
        if (bank.last_writer.exists(location)) begin
          writer = bank.last_writer[location];
          if (writer >= 0 && writer < 3 && writer != port_id)
            from_locations[writer][location] = 1;
        end
        rw_info.set_value((bank.data.exists(location) ? bank.data[location] : 0) ^ read_xor);
      end
      rw_info.set_status(UVM_IS_OK);
    endtask
  endclass
  class storage_backdoor extends uvm_reg_backdoor;
    storage_bank bank;
    uvm_reg_data_t read_xor = 0;
    int reads = 0;
    int writes = 0;
    bit [3:0] read_locations = 0;
    bit [3:0] written_locations = 0;
    function new(string name="bd"); super.new(name); endfunction
    function void clear_observations();
      reads = 0;
      writes = 0;
      read_locations = 0;
      written_locations = 0;
    endfunction
    function bit idle(); return reads == 0 && writes == 0; endfunction
    function bit locations_complete();
      return read_locations == 'hf && written_locations == 'hf;
    endfunction
    virtual task read(uvm_reg_item rw);
      uvm_reg_addr_t location;
      do_pre_read(rw);
      location = rw.get_element_kind() == UVM_MEM ? rw.get_offset() : 0;
      #1;
      reads++;
      read_locations[location] = 1;
      rw.set_value((bank.data.exists(location) ? bank.data[location] : 0) ^ read_xor);
      rw.set_status(UVM_IS_OK);
      do_post_read(rw);
    endtask
    virtual task write(uvm_reg_item rw);
      uvm_reg_addr_t location;
      do_pre_write(rw);
      location = rw.get_element_kind() == UVM_MEM ? rw.get_offset() : 0;
      #1;
      writes++;
      written_locations[location] = 1;
      bank.data[location] = rw.get_value(0) & 'hff;
      bank.last_writer[location] = -1;
      rw.set_status(UVM_IS_OK);
      do_post_write(rw);
    endtask
  endclass
  class report_probe extends uvm_report_catcher;
    int errors = 0;
    int issues = 0;
    function new(); super.new("probe"); endfunction
    virtual function action_e catch();
      if (get_severity() == UVM_WARNING || get_severity() == UVM_ERROR) begin
        issues++;
        if (get_severity() == UVM_ERROR) errors++;
        return CAUGHT;
      end
      return THROW;
    endfunction
  endclass
  class selected_tests extends uvm_reg_mem_built_in_seq;
    function new(string name="selected_tests"); super.new(name); endfunction
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    model_block blk;
    model_block child;
    model_reg rg;
    model_reg peer_rg;
    uvm_reg_field field;
    uvm_reg_field peer_field;
    uvm_mem mem;
    uvm_mem peer_mem;
    uvm_reg_map maps[3];
    uvm_reg_map child_maps[3];
    storage_bank reg_bank;
    storage_bank peer_reg_bank;
    storage_bank mem_bank;
    storage_bank peer_mem_bank;
    storage_frontdoor reg_fd[3];
    storage_frontdoor peer_reg_fd[3];
    storage_frontdoor mem_fd[3];
    storage_frontdoor peer_mem_fd[3];
    storage_backdoor reg_bd;
    storage_backdoor peer_reg_bd;
    storage_backdoor mem_bd;
    storage_backdoor peer_mem_bd;
    uvm_sequencer#(uvm_sequence_item) sequencer;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      blk = new();
      blk.configure();
      reg_bank = new("reg_bank");
      peer_reg_bank = new("peer_reg_bank");
      mem_bank = new("mem_bank");
      peer_mem_bank = new("peer_mem_bank");
      reg_bank.data[0] = 'h3c;
      peer_reg_bank.data[0] = 'ha5;
      for (int i = 0; i < 4; i++) begin
        mem_bank.data[i] = 'h30 + i;
        peer_mem_bank.data[i] = 'h60 + i;
      end
      rg = new();
      rg.configure(blk);
      field = new("value");
      field.configure(rg, 8, 0, "RW", 0, 'h3c, 1, 0, 1);
      peer_rg = new("peer");
      peer_rg.configure(blk);
      peer_field = new("value");
      peer_field.configure(peer_rg, 8, 0, "RW", 0, 'ha5, 1, 0, 1);
      mem = new("mem", 4, 8, "RW", UVM_NO_COVERAGE);
      mem.configure(blk);
      peer_mem = new("peer_mem", 4, 8, "RW", UVM_NO_COVERAGE);
      peer_mem.configure(blk);
      reg_bd = new("reg_bd");
      peer_reg_bd = new("peer_reg_bd");
      mem_bd = new("mem_bd");
      peer_mem_bd = new("peer_mem_bd");
      reg_bd.bank = reg_bank;
      peer_reg_bd.bank = peer_reg_bank;
      mem_bd.bank = mem_bank;
      peer_mem_bd.bank = peer_mem_bank;
      sequencer = new("sequencer", this);
      for (int i = 0; i < 2; i++) begin
        maps[i] = blk.create_map($sformatf("bus%0d", i), i * 'h200, 1, UVM_LITTLE_ENDIAN);
        maps[i].set_sequencer(sequencer);
        maps[i].set_auto_predict(1);
        reg_fd[i] = new($sformatf("reg_fd%0d", i));
        peer_reg_fd[i] = new($sformatf("peer_reg_fd%0d", i));
        mem_fd[i] = new($sformatf("mem_fd%0d", i));
        peer_mem_fd[i] = new($sformatf("peer_mem_fd%0d", i));
        reg_fd[i].bank = reg_bank;
        peer_reg_fd[i].bank = peer_reg_bank;
        mem_fd[i].bank = mem_bank;
        peer_mem_fd[i].bank = peer_mem_bank;
        reg_fd[i].port_id = i;
        peer_reg_fd[i].port_id = i;
        mem_fd[i].port_id = i;
        peer_mem_fd[i].port_id = i;
        maps[i].add_reg(rg, 'h20, "RW", 0, reg_fd[i]);
        maps[i].add_mem(mem, 'h40, "RW", 0, mem_fd[i]);
        maps[i].add_reg(peer_rg, 'h60, "RW", 0, peer_reg_fd[i]);
        maps[i].add_mem(peer_mem, 'h80, "RW", 0, peer_mem_fd[i]);
      end
      blk.lock_model();
      blk.reset();
    endfunction
    function void clear_observations();
      for (int i = 0; i < 2; i++) begin
        reg_fd[i].clear_observations();
        peer_reg_fd[i].clear_observations();
        mem_fd[i].clear_observations();
        peer_mem_fd[i].clear_observations();
      end
      reg_bd.clear_observations();
      peer_reg_bd.clear_observations();
      mem_bd.clear_observations();
      peer_mem_bd.clear_observations();
      reg_bank.last_writer.delete();
      peer_reg_bank.last_writer.delete();
      mem_bank.last_writer.delete();
      peer_mem_bank.last_writer.delete();
      memory_started = 0;
      register_after_memory = 0;
    endfunction
    function bit registers_idle();
      for (int i = 0; i < 2; i++)
        if (!reg_fd[i].idle() || !peer_reg_fd[i].idle()) return 0;
      return reg_bd.idle() && peer_reg_bd.idle();
    endfunction
    function bit memories_idle();
      for (int i = 0; i < 2; i++)
        if (!mem_fd[i].idle() || !peer_mem_fd[i].idle()) return 0;
      return mem_bd.idle() && peer_mem_bd.idle();
    endfunction
    function bit all_idle(); return registers_idle() && memories_idle(); endfunction
    task run_phase(uvm_phase phase);
      uvm_reg_mem_shared_access_seq seq = new("sequence_under_test");
      uvm_mem_single_access_seq control_mem_access = new("control_mem_access");
      uvm_reg_shared_access_seq control_shared_reg = new("control_shared_reg");
      uvm_mem_shared_access_seq control_shared_mem = new("control_shared_mem");
      report_probe probe = new();
      bit baseline_clean;
      bit was_skipped;
      bit register_control;
      int earlier;
      phase.raise_objection(this);
      uvm_report_cb::add(null, probe);
      uvm_resource_db#(bit)::set({"REG::", blk.get_full_name()}, "NO_MEM_SHARED_ACCESS_TEST", 1);
      seq.model = blk;
      seq.start(null);
      was_skipped = all_idle();
      clear_observations();
      control_shared_reg.rg = rg;
      control_shared_reg.start(null);
      register_control = reg_fd[0].from_locations[1] == 1 && reg_fd[1].from_locations[0] == 1;
      clear_observations();
      control_shared_mem.mem = mem;
      control_shared_mem.start(null);
      $display("UT: clean %0d skipped %0d register_control %0d memory_control %0d",
               probe.errors == 0, was_skipped, register_control,
               mem_fd[0].from_locations[1] == 'hf && mem_fd[1].from_locations[0] == 'hf);
      uvm_report_cb::delete(null, probe);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #4000; $fatal(1, "annex E access/selection watchdog expired"); end
endmodule
