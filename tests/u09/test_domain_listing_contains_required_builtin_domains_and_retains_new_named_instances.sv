/*
:name: test_domain_listing_contains_required_builtin_domains_and_retains_new_named_instances
:description: domain listing contains required builtin domains and retains new named instances
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.4.2.2 9.4.2.1 9.3.1.3.2 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_domain_listing_contains_required_builtin_domains_and_retains_new_named_instances.expected
*/
// Require built-in entries without assuming that only two domains exist.
module test_domain_listing_contains_required_builtin_domains_and_retains_new_named_instances;
  import uvm_pkg::*;
  initial begin
    uvm_domain prior_domains[string],updated_domains[string];
    uvm_domain custom;
    bit retained;
    uvm_domain::get_domains(prior_domains);
    $display("UT: domain_list required_common %0d required_runtime %0d",
      prior_domains.exists("common") && prior_domains["common"]!=null,
      prior_domains.exists("uvm") && prior_domains["uvm"]!=null);
    custom=new("listed_domain53");uvm_domain::get_domains(updated_domains);retained=1;
    foreach (prior_domains[key])
      retained &= updated_domains.exists(key) &&
                  updated_domains[key]==prior_domains[key];
    $display("UT: domain_list custom %0d prior_entries %0d type %0d",
      updated_domains.exists("listed_domain53") &&
      updated_domains["listed_domain53"]==custom,retained,
      custom.get_phase_type()==UVM_PHASE_DOMAIN);
    $finish;
  end
endmodule
