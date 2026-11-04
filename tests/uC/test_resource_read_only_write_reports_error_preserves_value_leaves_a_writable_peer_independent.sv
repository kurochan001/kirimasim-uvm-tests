/*
:name: test_resource_read_only_write_reports_error_preserves_value_leaves_a_writable_peer_independent
:description: Read-only resource writes report ERROR and preserve storage independently of a writable peer
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.3.3.1 C.2.3.3.2 C.2.5.4.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_read_only_write_reports_error_preserves_value_leaves_a_writable_peer_independent.expected
*/
module
  test_resource_read_only_write_reports_error_preserves_value_leaves_a_writable_peer_independent;
  import uvm_pkg::*;

  class report_probe extends uvm_report_catcher;
    bit gated=0;
    int messages=0,warnings=0,errors=0;
    virtual function action_e catch();
      if (!gated) return THROW;
      messages++; warnings+=get_severity()==UVM_WARNING; errors+=get_severity()==UVM_ERROR;
      return CAUGHT;
    endfunction
  endclass

  initial begin
    automatic uvm_resource#(int) resource=new("resource58");
    automatic uvm_resource#(int) peer=new("peer58");
    automatic report_probe reports=new();
    resource.write(11); peer.write(22); uvm_report_cb::add(null,reports);
    $display("UT: read_only_initial subject %0d peer %0d",
      !resource.is_read_only(),!peer.is_read_only());
    resource.set_read_only(); reports.gated=1; resource.write(99); reports.gated=0;
    peer.write(33);
    $display("UT: read_only_write state %0d error %0d unchanged %0d peer %0d",
      resource.is_read_only(),reports.errors>0,resource.read()==11,
      !peer.is_read_only() && peer.read()==33);
    $finish;
  end
endmodule
