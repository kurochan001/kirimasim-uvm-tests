/*
:name: test_command_fresh_processors_populate_independent_argument_snapshots_at_construction
:description: command fresh processors populate independent argument snapshots at construction (IEEE 1800.2-2020 Section G.1)
:tags: uG uvm
:type: simulation
:lrm: 1800.2-2020 G.1 G.1.1 G.1.2 G.1.3.4 1800-2023 6.21
:uvm: 2020.3.1
:uvm_dpi: yes
:uvm_cmdline_backend: vpi
:uvm_cmdline_oracle: verilator@5.052
:uvm_defines: UVM_HDL_NO_DPI
:dpi_c: @../../tools/cmdline_backend/uvm_cmdline_vpi.cpp
:files: ../../tools/cmdline_backend/uvm_cmdline_regex.cpp ../../tools/cmdline_backend/malloc.h
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:args: +kr_construct=one +kr_construct=two
:expected_stdout: @test_command_fresh_processors_populate_independent_argument_snapshots_at_construction.expected
*/
// What it checks:
// 1. Construction populates a command-line processor from the invocation
//    arguments.
// 2. Constructing another processor does not erase the earlier processor
//    argument snapshot.
// 3. The command-line processor is usable through its report-object base type.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 G.1 (UVM-CMDLINE-CONSTRUCTION-ARGUMENT-SNAPSHOT) gives rule 1
//    above. Setup: Two fresh processors and the singleton inspect the same
//    supplied repeated prefix. Expected: Each newly constructed processor and
//    the singleton find both supplied arguments.
// 2. 1800.2-2020 G.1 (UVM-CMDLINE-CONSTRUCTION-PRESERVES-EARLIER-SNAPSHOT)
//    gives rule 2 above. Setup: Sequential construction reinitializes argument
//    retrieval, then all instances are queried. Expected: Both fresh instances
//    and the preexisting singleton retain two matches.
// 3. 1800.2-2020 G.1.1 (UVM-CMDLINE-REPORT-OBJECT-INHERITANCE) gives rule 3
//    above. Setup: A fresh processor is assigned to a uvm_report_object
//    handle. Expected: The base handle is nonnull and denotes the same
//    processor.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Construct multiple public processor objects from the same actual command
// line. Reinitializing the bridge stream must not erase earlier UVM queues.
// No mutable process argv or exact executable path is assumed.
module test_command_fresh_processors_populate_independent_argument_snapshots_at_construction;
  import uvm_pkg::*;
  initial begin
    automatic uvm_cmdline_processor singleton = uvm_cmdline_processor::get_inst();
    automatic uvm_cmdline_processor first = new("first");
    automatic uvm_cmdline_processor second = new("second");
    automatic uvm_report_object base_handle = first;
    string first_args[$], second_args[$], singleton_args[$];
    int first_count, second_count, singleton_count;
    $display("UT: report_object_base %0d", base_handle != null && base_handle == first);
    first_count = first.get_arg_matches("+kr_construct=", first_args);
    second_count = second.get_arg_matches("+kr_construct=", second_args);
    singleton_count = singleton.get_arg_matches("+kr_construct=", singleton_args);
    $display("UT: constructed distinct %0d first %0d second %0d singleton %0d",
             first != second && first != singleton && second != singleton,
             first_count, second_count, singleton_count);
    first_args.delete(); first_args.push_back("changed_returned_queue");
    second_count = second.get_arg_matches("+kr_construct=", second_args);
    $display("UT: snapshot second_count %0d second_size %0d singleton_stable %0d",
             second_count, second_args.size(), singleton == uvm_cmdline_processor::get_inst());
    $finish;
  end
endmodule
