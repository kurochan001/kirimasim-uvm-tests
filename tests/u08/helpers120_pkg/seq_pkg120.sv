// Original sequence package for the 120th user-package profiles. Its
// sequence creates two items through type_id and records, for each sequencer
// it runs on, its own type name, its name and its starting phase.
`include "uvm_macros.svh"

package seq_pkg120;
  import uvm_pkg::*;
  import agent_pkg120::*;

  // Keyed by the full name of the sequencer that ran the sequence.
  string started120[string];
  string phase120[string];

  class seq120 extends uvm_sequence #(item120);
    `uvm_object_utils(seq120)
    // Item data are base and base + 1; not random.
    int unsigned base = 10;

    function new(string name = "seq120");
      super.new(name);
    endfunction

    task body();
      item120 item;
      uvm_phase phase;
      string where;
      where = get_sequencer().get_full_name();
      phase = get_starting_phase();
      started120[where] = {get_type_name(), " ", get_name()};
      phase120[where] = phase == null ? "none" : phase.get_name();
      for (int unsigned i = 0; i < 2; i++) begin
        item = item120::type_id::create($sformatf("item%0d", i));
        start_item(item);
        item.data = base + i;
        finish_item(item);
      end
    endtask
  endclass

  // One line per sequencer, in ascending order of sequencer names (first
  // and next visit string indices in lexicographical order).
  function automatic void show_started120();
    string where;
    if (started120.first(where)) begin
      do begin
        $display("UT: started %s %s", where, started120[where]);
      end while (started120.next(where));
    end
  endfunction
endpackage
