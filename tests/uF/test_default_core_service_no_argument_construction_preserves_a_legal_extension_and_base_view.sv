/*
:name: test_default_core_service_no_argument_construction_preserves_a_legal_extension_and_base_view
:description: The default core service is concrete, has a no-argument constructor and can be extended
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.4.2.2 F.4.2.1 F.4.2 F.4.1.2 F.4.1.1 1800-2023 6.21 8.20 8.21 13.5.2 18.13.3 18.13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_default_core_service_no_argument_construction_preserves_a_legal_extension_and_base_view.expected
*/
module test_default_core_service_no_argument_construction_preserves_a_legal_extension_and_base_view;
  import uvm_pkg::*;
  class extended_service extends uvm_default_coreservice_t;
    int calls=0;
    function new(); super.new(); endfunction
    virtual function uvm_root get_root();
      calls++; return uvm_root::get();
    endfunction
  endclass
  initial begin
    automatic uvm_default_coreservice_t plain=new();
    automatic extended_service extension=new();
    automatic uvm_coreservice_t plain_base=plain, extended_base=extension;
    $display("UT: default_core concrete %0d distinct %0d ancestry %0d",
      plain!=null && extension!=null,plain!=extension,
      plain_base==plain && extended_base==extension);
    $display("UT: default_core extension_dispatch %0d calls %0d",
      extended_base.get_root()==uvm_root::get(),extension.calls);
    $finish;
  end
endmodule
