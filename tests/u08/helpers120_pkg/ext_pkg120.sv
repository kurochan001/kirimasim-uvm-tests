// Original extension package for the 120th user-package profiles. Each class
// extends a class of the agent or sequence package; those packages do not
// import this one, so they reach these types only through factory overrides.
`include "uvm_macros.svh"

package ext_pkg120;
  import uvm_pkg::*;
  import agent_pkg120::*;
  import seq_pkg120::*;

  class ext_item120 extends item120;
    `uvm_object_utils(ext_item120)

    function new(string name = "ext_item120");
      super.new(name);
    endfunction
  endclass

  class ext_driver120 extends driver120;
    `uvm_component_utils(ext_driver120)

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass

  class ext_agent120 extends agent120;
    `uvm_component_utils(ext_agent120)

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass

  class ext_seq120 extends seq120;
    `uvm_object_utils(ext_seq120)

    function new(string name = "ext_seq120");
      super.new(name);
      base = 20;
    endfunction
  endclass
endpackage
