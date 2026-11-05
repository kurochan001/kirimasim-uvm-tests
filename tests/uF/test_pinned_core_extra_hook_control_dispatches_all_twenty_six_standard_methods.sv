/*
:name: test_pinned_core_extra_hook_control_dispatches_all_twenty_six_standard_methods
:description: An explicit pinned-hook control dispatches the twenty-six standard methods
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.4.1.2 F.4.1.1 F.4 F.4.1.3 F.4.1.4.1 F.4.1.4.2 F.4.1.4.3 F.4.1.4.4 F.4.1.4.5 F.4.1.4.6 F.4.1.4.7 F.4.1.4.8 F.4.1.4.9 F.4.1.4.10 F.4.1.4.11 F.4.1.4.12 F.4.1.4.13 F.4.1.4.14 F.4.1.4.15 F.4.1.4.16 F.4.1.4.17 F.4.1.4.18 F.4.1.4.19 F.4.1.4.20 F.4.1.4.21 F.4.1.4.22 F.4.1.4.23 F.4.1.4.24 F.4.1.4.25 F.4.1.4.26 1800-2023 6.21 8.20 8.21 13.5.2 18.13.3 18.13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers64_decl_control/core_decl_control_bodies64.svh
:expected_exit: 0
:expected_stdout: @test_pinned_core_extra_hook_control_dispatches_all_twenty_six_standard_methods.expected
*/
// Control-only: the extra pinned hook permits the original methods to run.
// It does not pass the listed-only constructor or define any builtin algorithm.
module test_pinned_core_extra_hook_control_dispatches_all_twenty_six_standard_methods;
  import uvm_pkg::*;
  class complete_service extends uvm_coreservice_t;
    `include "core_decl_control_bodies64.svh"
  endclass
  class original_visitor extends uvm_visitor#(uvm_component);
    virtual function void visit(uvm_component node); endfunction
  endclass
  initial begin
    automatic complete_service original=new();
    automatic uvm_coreservice_t base=original;
    automatic uvm_coreservice_t selected=uvm_coreservice_t::get();
    automatic uvm_default_factory factory=new();
    automatic uvm_default_report_server server=new();
    automatic uvm_text_tr_database database=new("original64");
    automatic original_visitor visitor=new();
    automatic uvm_line_printer printer=new("original64");
    automatic uvm_packer packer=new("original64");
    automatic uvm_comparer comparer=new("original64");
    automatic uvm_copier copier=new("original64");
    automatic uvm_resource_pool pool=new();
    automatic bit exact=1, once=1;
    exact &= base.get_root()==uvm_root::get();
    base.set_factory(factory); exact &= base.get_factory()==factory;
    base.set_report_server(server); exact &= base.get_report_server()==server;
    base.set_default_tr_database(database);
    exact &= base.get_default_tr_database()==database;
    base.set_component_visitor(visitor); exact &= base.get_component_visitor()==visitor;
    base.set_phase_max_ready_to_end(17); exact &= base.get_phase_max_ready_to_end()==17;
    base.set_default_printer(printer); exact &= base.get_default_printer()==printer;
    base.set_default_packer(packer); exact &= base.get_default_packer()==packer;
    base.set_default_comparer(comparer); exact &= base.get_default_comparer()==comparer;
    base.set_default_copier(copier); exact &= base.get_default_copier()==copier;
    exact &= base.get_global_seed()==233;
    base.set_resource_pool(pool); exact &= base.get_resource_pool()==pool;
    base.set_resource_pool_default_precedence(317);
    exact &= base.get_resource_pool_default_precedence()==317;
    base.set_uvm_seeding(1); exact &= base.get_uvm_seeding();
    foreach (original.calls[i]) begin
      once &= original.calls[i]==1;
      $display("UT: core_dispatch slot %0d calls %0d",i+1,original.calls[i]);
    end
    $display("UT: core_dispatch exact %0d once %0d selected_unchanged %0d",exact,once,
      uvm_coreservice_t::get()==selected && base!=selected);
    $finish;
  end
endmodule
