// Original environment package for the 120th user-package profiles. The
// environment creates two agents through type_id. The two other classes are
// registered only through their utility macros: no profile names them in
// code, so the factory can reach them only by their type names.
`include "uvm_macros.svh"

package env_pkg120;
  import uvm_pkg::*;
  import agent_pkg120::*;

  class env120 extends uvm_env;
    `uvm_component_utils(env120)
    agent120 a0;
    agent120 a1;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      a0 = agent120::type_id::create("a0", this);
      a1 = agent120::type_id::create("a1", this);
    endfunction

    function void show120();
      $display("UT: %s %s", get_full_name(), get_type_name());
      a0.show120();
      a1.show120();
    endfunction
  endclass

  class named_env120 extends uvm_env;
    `uvm_component_utils(named_env120)

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass

  class named_cfg120 extends uvm_object;
    `uvm_object_utils(named_cfg120)

    function new(string name = "named_cfg120");
      super.new(name);
    endfunction
  endclass
endpackage
