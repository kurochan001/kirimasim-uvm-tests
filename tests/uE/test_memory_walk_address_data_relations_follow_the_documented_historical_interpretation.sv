/*
:name: test_memory_walk_address_data_relations_follow_the_documented_historical_interpretation
:description: memory-walk address/data and per-location ordering are checked under an explicit historical interpretation of E.6.1
:tags: uE uvm
:type: simulation
:lrm: 1800.2-2020 E.6.1 E.6.1.3.2 18.6.3.1 18.6.3.2 18.2.3.4 19.4.2.2.1 19.4.2.3 19.1.1.2.1 19.1.1.2.2 19.1.1.2.3 19.1.1.2.4 19.1.1.2.6 18.1.2.1 18.1.2.2 18.1.2.6 6.6.3.2 D.4.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_walk_address_data_relations_follow_the_documented_historical_interpretation.expected
*/
// What it checks:
// 1. The selected memory is tested with the walking-ones algorithm.
// 2. The memory-walk body applies the qualified algorithm interpretation
//    independently to every defined map.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 E.6.1 (UVM-MEMORY-WALK-ALGORITHM) gives rule 1 above. Setup:
//    Observe enough memory data/address relationships to distinguish walking
//    ones from arbitrary traffic. Expected: The algorithm-specific
//    relationships hold, beyond simply visiting every location.
// 2. 1800.2-2020 E.6.1.3.2 (UVM-MEMORY-WALK-BODY-EACH-MAP-RELATIONSHIPS) gives
//    rule 2 above. Setup: Observe both frontdoors of one shared memory using
//    independent access histories. Expected: Both maps satisfy the checker
//    data/address relations and per-location ordering.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// E.6.1 names the algorithm without detailing it. This AI interpretation uses
// the official UVM 1.2 LRM section 27.7 (printed page 730), not library output.
// Historical detail is not an approved amendment to IEEE 1800.2-2020.
// The independent observer checks relations; it does not implement the walk.
module test_memory_walk_address_data_relations_follow_the_documented_historical_interpretation;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class model_block extends uvm_reg_block;
    function new(); super.new("blk", UVM_NO_COVERAGE); endfunction
  endclass
  class storage extends uvm_object;
    uvm_reg_data_t data[4];
    function new();
      super.new("storage");
      foreach (data[i]) data[i] = 'h3c;
    endfunction
  endclass
  class observer extends uvm_reg_frontdoor;
    storage bank;
    int writes[4], reads[4];
    int first_at[4], read_at[4], retired_at[4];
    int serial;
    uvm_reg_data_t first_data[4], read_data[4], retired_data[4];
    function new(string name);
      super.new(name);
      serial = 0;
      foreach (writes[i]) begin
        writes[i] = 0;
        reads[i] = 0;
        first_at[i] = 0;
        read_at[i] = 0;
        retired_at[i] = 0;
        first_data[i] = 0;
        read_data[i] = 0;
        retired_data[i] = 0;
      end
    endfunction
    virtual task body();
      uvm_reg_addr_t location;
      uvm_reg_data_t value;
      location = rw_info.get_offset();
      if (location >= 4 || bank == null) $fatal(1, "invalid observer access");
      #1;
      serial++;
      if (rw_info.get_kind() == UVM_WRITE) begin
        value = rw_info.get_value(0) & 'hff;
        if (writes[location] == 0) begin
          first_at[location] = serial;
          first_data[location] = value;
        end else begin
          retired_at[location] = serial;
          retired_data[location] = value;
        end
        writes[location]++;
        bank.data[location] = value;
      end else if (rw_info.get_kind() == UVM_READ) begin
        reads[location]++;
        read_at[location] = serial;
        read_data[location] = bank.data[location];
        rw_info.set_value(bank.data[location]);
      end else $fatal(1, "unsupported observer access kind");
      rw_info.set_status(UVM_IS_OK);
    endtask
    function bit first_patterns();
      foreach (writes[i])
        if (writes[i] == 0 || first_data[i] != ((~uvm_reg_data_t'(i)) & 'hff)) return 0;
      return 1;
    endfunction
    function bit read_patterns();
      foreach (reads[i])
        if (reads[i] != 1 || read_data[i] != ((~uvm_reg_data_t'(i)) & 'hff)) return 0;
      return 1;
    endfunction
    function bit retired_patterns();
      for (int i = 0; i < 3; i++)
        if (writes[i] != 2 || retired_data[i] != uvm_reg_data_t'(i)) return 0;
      return writes[3] == 1;
    endfunction
    function bit local_order();
      foreach (reads[i]) if (first_at[i] >= read_at[i]) return 0;
      for (int i = 0; i < 3; i++) begin
        if (first_at[i] >= first_at[i + 1]) return 0;
        if (first_at[i + 1] >= read_at[i] || read_at[i] >= retired_at[i]) return 0;
        if (i < 2 && retired_at[i] >= first_at[i + 2]) return 0;
      end
      return retired_at[2] < read_at[3];
    endfunction
  endclass
  class error_probe extends uvm_report_catcher;
    int errors = 0;
    function new(); super.new("probe"); endfunction
    virtual function action_e catch();
      if (get_severity() == UVM_ERROR) errors++;
      return THROW;
    endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    model_block blk;
    uvm_mem mem;
    storage bank;
    observer first, second;
    uvm_sequencer#(uvm_sequence_item) sequencer;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      uvm_reg_map map_one, map_two;
      super.build_phase(phase);
      blk = new();
      blk.configure();
      bank = new();
      first = new("first");
      second = new("second");
      first.bank = bank;
      second.bank = bank;
      sequencer = new("sequencer", this);
      map_one = blk.create_map("one", 0, 1, UVM_LITTLE_ENDIAN);
      map_two = blk.create_map("two", 'h100, 1, UVM_LITTLE_ENDIAN);
      map_one.set_sequencer(sequencer);
      map_two.set_sequencer(sequencer);
      mem = new("mem", 4, 8, "RW", UVM_NO_COVERAGE);
      mem.configure(blk);
      map_one.add_mem(mem, 'h20, "RW", 0, first);
      map_two.add_mem(mem, 'h40, "RW", 0, second);
      blk.lock_model();
    endfunction
    task run_phase(uvm_phase phase);
      uvm_mem_single_walk_seq seq = new("walk");
      error_probe probe = new();
      phase.raise_objection(this);
      uvm_report_cb::add(null, probe);
      seq.mem = mem;
      seq.start(null);
      $display("UT: map_one first %0d reads %0d retired %0d order %0d",
               first.first_patterns(), first.read_patterns(),
               first.retired_patterns(), first.local_order());
      $display("UT: map_two first %0d reads %0d retired %0d order %0d",
               second.first_patterns(), second.read_patterns(),
               second.retired_patterns(), second.local_order());
      $display("UT: no_errors %0d final_state %0d", probe.errors == 0,
               bank.data[0] == 0 && bank.data[1] == 1 && bank.data[2] == 2 &&
               bank.data[3] == 'hfc);
      uvm_report_cb::delete(null, probe);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #500; $fatal(1, "memory-walk interpretation watchdog expired"); end
endmodule
