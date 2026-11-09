/*
:name: test_single_register_access_sequence_skips_a_readonly_register
:description: single register access sequence skips a readonly register (IEEE 1800.2-2020 Section E.3.1)
:tags: uE uvm
:type: simulation
:lrm: 1800.2-2020 E.3.1 E.3.2 18.4.4.9 18.4.4.10 18.4.4.14 19.5.2.2 19.5.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 18.4.6.2 19.4.1.2 19.4.1.3.1 19.4.2.1 19.4.2.2.1 19.4.2.2.2 19.4.2.3 19.1.1.2.1 19.1.1.2.2 19.1.1.2.3 19.1.1.2.4 19.1.1.2.6 19.1.1.2.8 19.1.1.2.9 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.1.5.3 18.2.3.3 18.2.3.5 18.2.3.6 18.2.5.2 18.4.2.1 18.4.2.2 18.5.3.2 C.3.2.3.1 6.6.3.2 6.6.5 D.4.4 15.5.2.5 1800-2023 6.21 8.19
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_single_register_access_sequence_skips_a_readonly_register.expected
*/
// What it checks:
// A register containing only read-only fields is not tested by the access
// sequence.
//
// How the expected output follows from the standard:
// 1800.2-2020 E.3.1 (UVM-REGISTER-ACCESS-READONLY) gives the rule above.
// Setup: Use a read-only register with otherwise available access paths.
// Expected: Both frontdoor and backdoor remain idle.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Only the absence of access is required. A skip diagnostic may be emitted
// without prescribing its severity, text or count.

module test_single_register_access_sequence_skips_a_readonly_register;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class model_block extends uvm_reg_block;
    function new(string name="blk"); super.new(name, UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(string name="r"); super.new(name, 8, UVM_NO_COVERAGE); endfunction
  endclass
  class storage_bank extends uvm_object;
    uvm_reg_data_t data[uvm_reg_addr_t];
    uvm_reg_data_t stuck_mask = 0;
    function new(); super.new("bank"); endfunction
  endclass
  class storage_frontdoor extends uvm_reg_frontdoor;
    storage_bank bank;
    int reads = 0;
    int writes = 0;
    uvm_reg_data_t ones = 0;
    uvm_reg_data_t zeros = 0;
    bit [3:0] read_locations = 0;
    bit [3:0] written_locations = 0;
    function new(string name="fd"); super.new(name); endfunction
    virtual task body();
      uvm_reg_addr_t location;
      uvm_reg_data_t value;
      if (rw_info == null || bank == null) $fatal(1, "incomplete frontdoor fixture");
      location = rw_info.get_element_kind() == UVM_MEM ? rw_info.get_offset() : 0;
      #1;
      if (rw_info.get_kind() == UVM_WRITE) begin
        value = rw_info.get_value(0) & 'hff;
        writes++;
        written_locations[location] = 1;
        ones |= value;
        zeros |= (~value) & 'hff;
        bank.data[location] = value & ~bank.stuck_mask;
      end else begin
        reads++;
        read_locations[location] = 1;
        rw_info.set_value(bank.data.exists(location) ? bank.data[location] : 0);
      end
      rw_info.set_status(UVM_IS_OK);
    endtask
  endclass
  class storage_backdoor extends uvm_reg_backdoor;
    storage_bank bank;
    uvm_reg_data_t read_xor = 0;
    int reads = 0;
    int writes = 0;
    function new(string name="bd"); super.new(name); endfunction
    virtual task read(uvm_reg_item rw);
      do_pre_read(rw);
      #1;
      reads++;
      rw.set_value((bank.data.exists(0) ? bank.data[0] : 0) ^ read_xor);
      rw.set_status(UVM_IS_OK);
      do_post_read(rw);
    endtask
    virtual task write(uvm_reg_item rw);
      do_pre_write(rw);
      #1;
      writes++;
      bank.data[0] = rw.get_value(0) & 'hff;
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

  class t extends uvm_test;
    `uvm_component_utils(t)
    model_block blk;
    model_block child;
    uvm_reg_map mapping;
    uvm_reg_map alternate_map;
    uvm_reg_map child_map;
    storage_bank bank;
    storage_bank other_bank;
    storage_frontdoor fd;
    storage_frontdoor other_fd;
    storage_frontdoor alternate_fd;
    storage_backdoor bkdr;
    storage_backdoor other_bkdr;
    uvm_sequencer#(uvm_sequence_item) sequencer;
    model_reg rg;
    model_reg other_rg;
    uvm_reg_field field;
    uvm_reg_field other_field;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      blk = new();
      blk.configure();
      bank = new();
      other_bank = new();
      bank.data[0] = 'h3c;
      other_bank.data[0] = 'ha5;
      fd = new();
      other_fd = new("other_fd");
      alternate_fd = new("alternate_fd");
      fd.bank = bank;
      other_fd.bank = other_bank;
      alternate_fd.bank = bank;
      bkdr = new();
      other_bkdr = new("other_bd");
      bkdr.bank = bank;
      other_bkdr.bank = other_bank;
      sequencer = new("sequencer", this);
      mapping = blk.create_map("bus", 0, 1, UVM_LITTLE_ENDIAN);
      mapping.set_sequencer(sequencer);
      mapping.set_auto_predict(1);
      rg = new();
      rg.configure(blk);
      field = new("value");
      field.configure(rg, 8, 0, "RO", 0, 'h3c, 1, 0, 1);
      other_rg = new("other");
      other_rg.configure(blk);
      other_field = new("value");
      other_field.configure(other_rg, 8, 0, "RW", 0, 'ha5, 1, 0, 1);
      mapping.add_reg(rg, 'h20, "RW", 0, fd);
      mapping.add_reg(other_rg, 'h40, "RW", 0, other_fd);
      rg.set_backdoor(bkdr);
      other_rg.set_backdoor(other_bkdr);
      blk.lock_model();
      blk.reset();
    endfunction
    task run_phase(uvm_phase phase);
      uvm_reg_single_access_seq seq = new("sequence_under_test");
      uvm_reg_single_bit_bash_seq control = new("control");
      report_probe probe = new();
      bit baseline_clean;
      bit was_skipped;
      int earlier;
      phase.raise_objection(this);
      uvm_report_cb::add(null, probe);
      seq.rg = rg;
      seq.start(null);
      $display("UT: frontdoor_idle %0d backdoor_idle %0d", fd.reads == 0 && fd.writes == 0,
               bkdr.reads == 0 && bkdr.writes == 0);
      uvm_report_cb::delete(null, probe);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #2000; $fatal(1, "annex E sequence watchdog expired"); end
endmodule
