/*
:name: test_tlm_unidirectional_port_defaults_preserve_integer_interface_and_constructor_metadata
:description: tlm unidirectional port defaults preserve integer interface and constructor metadata (IEEE 1800.2-2020 Section 12.2.2.3)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.2.3 12.2.5.1 12.2.5.2 12.2.4.1 5.5.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_unidirectional_port_defaults_preserve_integer_interface_and_constructor_metadata.expected
*/
// What it checks:
// 1. The selected unidirectional port families default T to int.
// 2. The regular unidirectional port minimum defaults to one.
// 3. The regular unidirectional port maximum defaults to one.
// 4. Regular unidirectional port construction retains its selected name and
//    parent.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.2.2.3 (UVM-TLM1-REVIEW-UNIDIRECTIONAL-PORT-DEFAULT-T)
//    gives rule 1 above. Setup: Construct twelve regular put/get/peek
//    combinations without a type argument. Expected: Each is compatible with
//    the exact integer interface base.
// 2. 1800.2-2020 12.2.5.1 (UVM-TLM1-REVIEW-UNIDIRECTIONAL-PORT-DEFAULT-MIN)
//    gives rule 2 above. Setup: Inspect twelve selected regular port
//    constructors before binding. Expected: Each minimum is one.
// 3. 1800.2-2020 12.2.5.1 (UVM-TLM1-REVIEW-UNIDIRECTIONAL-PORT-DEFAULT-MAX)
//    gives rule 3 above. Setup: Inspect twelve selected regular port
//    constructors before binding. Expected: Each maximum is one.
// 4. 1800.2-2020 12.2.5.1 (UVM-TLM1-REVIEW-UNIDIRECTIONAL-PORT-NAME-PARENT)
//    gives rule 4 above. Setup: Supply unique names under an actual component
//    owner. Expected: All selected names, parents and port roles match.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Constructor/type inspection before binding resolution. Selected regular
// port families use their declared default types and 1/1 bounds; analysis
// ports
// have a separate constructor contract. The printed tlm_if_base alias and
// complete imp parameter list in the summary are not certified. No successful
// end-of-elaboration binding or transport execution is inferred from this
// probe.
module test_tlm_unidirectional_port_defaults_preserve_integer_interface_and_constructor_metadata;
  import uvm_pkg::*;
  class owner extends uvm_component;
    function new(); super.new("owner",null); endfunction
  endclass
  function automatic bit inspect(uvm_port_base#(uvm_tlm_if_base#(int,int)) selected,
                                 uvm_component parent_value,string name);
    return selected != null && selected.is_port() && selected.get_parent() == parent_value &&
           selected.get_name() == name && selected.min_size() == 1 && selected.max_size() == 1;
  endfunction
  initial begin
    automatic owner parent_value = new();
    automatic bit ok = 1;
    automatic uvm_blocking_put_port#() p0 = new("p0",parent_value);
    automatic uvm_nonblocking_put_port#() p1 = new("p1",parent_value);
    automatic uvm_put_port#() p2 = new("p2",parent_value);
    automatic uvm_blocking_get_port#() p3 = new("p3",parent_value);
    automatic uvm_nonblocking_get_port#() p4 = new("p4",parent_value);
    automatic uvm_get_port#() p5 = new("p5",parent_value);
    automatic uvm_blocking_peek_port#() p6 = new("p6",parent_value);
    automatic uvm_nonblocking_peek_port#() p7 = new("p7",parent_value);
    automatic uvm_peek_port#() p8 = new("p8",parent_value);
    automatic uvm_blocking_get_peek_port#() p9 = new("p9",parent_value);
    automatic uvm_nonblocking_get_peek_port#() p10 = new("p10",parent_value);
    automatic uvm_get_peek_port#() p11 = new("p11",parent_value);
    ok &= inspect(p0,parent_value,"p0");
    ok &= inspect(p1,parent_value,"p1");
    ok &= inspect(p2,parent_value,"p2");
    ok &= inspect(p3,parent_value,"p3");
    ok &= inspect(p4,parent_value,"p4");
    ok &= inspect(p5,parent_value,"p5");
    ok &= inspect(p6,parent_value,"p6");
    ok &= inspect(p7,parent_value,"p7");
    ok &= inspect(p8,parent_value,"p8");
    ok &= inspect(p9,parent_value,"p9");
    ok &= inspect(p10,parent_value,"p10");
    ok &= inspect(p11,parent_value,"p11");
    $display("UT: port_declarations count 12 defaults_and_metadata %0d",ok);
    $finish;
  end
endmodule
