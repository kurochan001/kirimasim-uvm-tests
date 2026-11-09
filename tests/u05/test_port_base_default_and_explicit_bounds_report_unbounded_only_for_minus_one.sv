/*
:name: test_port_base_default_and_explicit_bounds_report_unbounded_only_for_minus_one
:description: port base constructor/query APIs preserve default and explicit binding bounds (5.5.2.1)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.5.2.1 5.5.2.6 5.5.2.7 5.5.2.8 12.2.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_port_base_default_and_explicit_bounds_report_unbounded_only_for_minus_one.expected
*/
// What it checks:
// 1. Omitted base constructor bounds default to zero minimum and one maximum.
// 2. Minimum-bound queries preserve the configured lower limits.
// 3. Maximum-bound queries preserve finite, zero and unbounded settings.
// 4. Only a maximum of minus one makes the configured port unbounded.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.5.2.1 (UVM-PORT-CONSTRUCTOR-DEFAULT-BOUNDS) gives rule 1
//    above. Setup: Query a default constructor that omits base bounds and
//    explicit 2/3, 0/-1 and 0/0 configurations before resolution. Expected:
//    The default probe reports minimum zero and maximum one.
// 2. 1800.2-2020 5.5.2.6 (UVM-PORT-MINIMUM-BOUND-QUERY) gives rule 2 above.
//    Setup: Query a default constructor that omits base bounds and explicit
//    2/3, 0/-1 and 0/0 configurations before resolution. Expected: The
//    default/bounded/unlimited/closed minima are 0/2/0/0.
// 3. 1800.2-2020 5.5.2.7 (UVM-PORT-MAXIMUM-BOUND-QUERY) gives rule 3 above.
//    Setup: Query a default constructor that omits base bounds and explicit
//    2/3, 0/-1 and 0/0 configurations before resolution. Expected: The maxima
//    are 1/3/-1/0 for the four probes.
// 4. 1800.2-2020 5.5.2.8 (UVM-PORT-UNBOUNDED-MINUS-ONE) gives rule 4 above.
//    Setup: Query a default constructor that omits base bounds and explicit
//    2/3, 0/-1 and 0/0 configurations before resolution. Expected: Only the
//    minus-one probe reports unbounded; zero and positive limits do not.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_port_base_default_and_explicit_bounds_report_unbounded_only_for_minus_one;
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
  // Omit the base bounds here so its defaults, rather than local defaults,
  // are the values observed by the queries below.
  class default_probe extends uvm_port_base#(uvm_tlm_if_base#(int, int));
    function new(string name, uvm_component parent);
      super.new(name, parent, UVM_PORT);
    endfunction
  endclass
  initial begin
    automatic holder owner = new("owner", null);
    automatic default_probe normal = new("normal", owner);
    automatic probe_port bounded = new("bounded", owner, UVM_PORT, 2, 3);
    automatic probe_port unlimited = new("unlimited", owner, UVM_PORT, 0, -1);
    automatic probe_port closed = new("closed", owner, UVM_PORT, 0, 0);
    $display("UT: default min %0d max %0d bounded %0d",
             normal.min_size(), normal.max_size(), !normal.is_unbounded());
    $display("UT: explicit min %0d max %0d bounded %0d",
             bounded.min_size(), bounded.max_size(), !bounded.is_unbounded());
    $display("UT: unlimited min %0d max %0d unbounded %0d",
             unlimited.min_size(), unlimited.max_size(), unlimited.is_unbounded());
    $display("UT: closed min %0d max %0d bounded %0d",
             closed.min_size(), closed.max_size(), !closed.is_unbounded());
    $finish;
  end
endmodule
