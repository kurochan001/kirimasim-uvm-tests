/*
:name: test_tlm2_payload_base_handle_dispatches_virtual_data_and_byte_enable_accessors
:description: base-typed payload array accessors dispatch to overrides and retain array values (12.3.4.2.15)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.2.15 12.3.4.2.24 12.3.4.2.25 12.3.4.2.30 12.3.4.2.31 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_payload_base_handle_dispatches_virtual_data_and_byte_enable_accessors.expected
*/
// The derived methods forward to standard array accessors.
// Array lengths, packing and streaming transfers are separate obligations.
module test_tlm2_payload_base_handle_dispatches_virtual_data_and_byte_enable_accessors;
  import uvm_pkg::*;
  class payload extends uvm_tlm_generic_payload;
    int data_sets = 0, data_gets = 0, mask_sets = 0, mask_gets = 0;
    function new(); super.new("payload"); endfunction
    virtual function void set_data(ref byte unsigned p[]);
      data_sets++; super.set_data(p);
    endfunction
    virtual function void get_data(output byte unsigned p[]);
      data_gets++; super.get_data(p);
    endfunction
    virtual function void set_byte_enable(ref byte unsigned p[]);
      mask_sets++; super.set_byte_enable(p);
    endfunction
    virtual function void get_byte_enable(output byte unsigned p[]);
      mask_gets++; super.get_byte_enable(p);
    endfunction
  endclass
  initial begin
    automatic payload probe = new();
    automatic uvm_tlm_generic_payload base = probe;
    automatic byte unsigned data[] = '{8'h00, 8'h80, 8'hff};
    automatic byte unsigned mask[] = '{8'hff, 8'h00};
    byte unsigned read_data[], read_mask[];
    probe.data_sets = 0; probe.data_gets = 0; probe.mask_sets = 0; probe.mask_gets = 0;
    base.set_data(data); base.set_byte_enable(mask);
    data[0] = 8'h55; mask[0] = 8'h00;
    base.get_data(read_data); base.get_byte_enable(read_mask);
    if (read_data.size() != 3 || read_mask.size() != 2) $fatal(1, "array size mismatch");
    $display("UT: dispatch data %0d %0d mask %0d %0d", probe.data_sets, probe.data_gets,
             probe.mask_sets, probe.mask_gets);
    $display("UT: arrays data %0d %0h %0h %0h mask %0d %0h %0h", read_data.size(),
             read_data[0], read_data[1], read_data[2], read_mask.size(),
             read_mask[0], read_mask[1]);
    $finish;
  end
endmodule
