/*
:name: test_analysis_imp_default_integer_type_binds_parent_and_forwards_each_write_without_time
:description: analysis imp default integer type binds parent and forwards each write without time (IEEE 1800.2-2020 Section 12.2.10.2.2)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.10.2.2 12.2.10.2.1 12.2.10.2 5.5.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_analysis_imp_default_integer_type_binds_parent_and_forwards_each_write_without_time.expected
*/
// What it checks:
// 1. The analysis imp defaults T to int with an explicitly selected
//    implementation type.
// 2. The analysis imp constructor binds its supplied implementation as parent
//    with the selected name.
// 3. The analysis imp uses implementation role and one-to-one bounds.
// 4. An analysis imp invokes write in its supplied subscriber implementation.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.2.10.2.1 (UVM-TLM-DECL-ANALYSIS-IMP-DEFAULT-T) gives rule
//    1 above. Setup: Select an actual receiver IMP, omit T, construct two imps
//    and call their real write methods with read-only receivers. Expected: The
//    exact integer interface port-base view retains imp identity.
// 2. 1800.2-2020 12.2.10.2.2 (UVM-TLM-DECL-ANALYSIS-IMP-CTOR-IDENTITY) gives
//    rule 2 above. Setup: Select an actual receiver IMP, omit T, construct two
//    imps and call their real write methods with read-only receivers.
//    Expected: The selected name and implementation parent match.
// 3. 1800.2-2020 12.2.10.2.2 (UVM-TLM-DECL-ANALYSIS-IMP-ROLE-BOUNDS) gives
//    rule 3 above. Setup: Select an actual receiver IMP, omit T, construct two
//    imps and call their real write methods with read-only receivers.
//    Expected: The actual imp reports implementation role and one/one bounds.
// 4. 1800.2-2020 12.2.10.2 (UVM-TLM-DECL-ANALYSIS-IMP-WRITE-DELEGATION) gives
//    rule 4 above. Setup: Select an actual receiver IMP, omit T, construct two
//    imps and call their real write methods with read-only receivers.
//    Expected: Thirteen and twenty-seven reach only the selected receiver,
//    forty-one its peer, without time advance.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Omit only T and explicitly select the actual implementation component type.
// Read-only original subscribers record actual imp forwarding and isolation.
// The nominal IMP=int default is not instantiated or certified here.
module test_analysis_imp_default_integer_type_binds_parent_and_forwards_each_write_without_time;
  import uvm_pkg::*;
  class receiver extends uvm_component;
    uvm_analysis_imp#(.IMP(receiver)) sink;
    int history[$];
    function new(string name); super.new(name,null); sink = new("sink",this); endfunction
    function void write(int value); history.push_back(value); endfunction
  endclass
  initial begin
    automatic receiver selected = new("selected");
    automatic receiver peer = new("peer");
    automatic uvm_port_base#(uvm_tlm_if_base#(int,int)) exact = selected.sink;
    automatic time before_time = $time;
    selected.sink.write(13); selected.sink.write(27); peer.sink.write(41);
    $display("UT: analysis_imp default_type %0d name %0d parent %0d role %0d bounds %0d/%0d",
             exact == selected.sink,selected.sink.get_name() == "sink",
             selected.sink.get_parent() == selected,selected.sink.is_imp(),
             selected.sink.min_size(),selected.sink.max_size());
    $display("UT: analysis_imp_delivery count %0d values %0d/%0d peer %0d/%0d immediate %0d",
             selected.history.size(),selected.history[0],selected.history[1],
             peer.history.size(),peer.history[0],$time == before_time);
    $finish;
  end
endmodule
