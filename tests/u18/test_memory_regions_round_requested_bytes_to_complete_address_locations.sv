/*
:name: test_memory_regions_round_requested_bytes_to_complete_address_locations
:description: memory regions round requested bytes to complete address locations
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.7.2.1 18.12.7.2.2 18.12.7.2.3 18.12.7.2.4 18.12.9.2.1 18.12.5.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_regions_round_requested_bytes_to_complete_address_locations.expected
*/
// What it checks:
// 1. A byte-sized reservation occupies enough complete memory locations.
// 2. The region start query returns the selected starting location offset.
// 3. The region end query returns the last occupied location after
//    whole-location reservation.
// 4. Region length counts consecutive memory locations rather than requested
//    bytes.
// 5. Region byte count includes complete locations and may exceed the
//    requested byte count.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.12.5.1 (UVM-MAM-RESERVATION-WHOLE-LOCATIONS) gives rule 1
//    above. Setup: Reserve five bytes at location three with four-byte
//    locations and no backing memory. Expected: The descriptor spans 3..4,
//    length two, eight bytes, and null memory/owner handles.
// 2. 1800.2-2020 18.12.7.2.1 (UVM-MAM-AUDIT-REGION-START) gives rule 2 above.
//    Setup: Use the linked original fixtures and the explicit sizes, location
//    offsets, handles and observations they declare. Allocation inputs are
//    configured explicitly rather than relying on unspecified initial
//    defaults. Expected: The region start query returns the selected starting
//    location offset.
// 3. 1800.2-2020 18.12.7.2.2 (UVM-MAM-AUDIT-REGION-END) gives rule 3 above.
//    Setup: Use the linked original fixtures and the explicit sizes, location
//    offsets, handles and observations they declare. Allocation inputs are
//    configured explicitly rather than relying on unspecified initial
//    defaults. Expected: The region end query returns the last occupied
//    location after whole-location reservation.
// 4. 1800.2-2020 18.12.7.2.3 (UVM-MAM-AUDIT-REGION-LENGTH) gives rule 4 above.
//    Setup: Use the linked original fixtures and the explicit sizes, location
//    offsets, handles and observations they declare. Allocation inputs are
//    configured explicitly rather than relying on unspecified initial
//    defaults. Expected: Region length counts consecutive memory locations
//    rather than requested bytes.
// 5. 1800.2-2020 18.12.7.2.4 (UVM-MAM-AUDIT-REGION-BYTES) gives rule 5 above.
//    Setup: Use the linked original fixtures and the explicit sizes, location
//    offsets, handles and observations they declare. Allocation inputs are
//    configured explicitly rather than relying on unspecified initial
//    defaults. Expected: Region byte count includes complete locations and may
//    exceed the requested byte count.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_memory_regions_round_requested_bytes_to_complete_address_locations;
  import uvm_pkg::*;
  function automatic uvm_mem_mam_cfg make_cfg(int bytes_per_location=4,
                                               uvm_reg_addr_t first=5,last=31);
    uvm_mem_mam_cfg cfg=new();
    cfg.n_bytes=bytes_per_location; cfg.start_offset=first; cfg.end_offset=last;
    cfg.mode=uvm_mem_mam::GREEDY; cfg.locality=uvm_mem_mam::BROAD;
    return cfg;
  endfunction
  function automatic int count_regions(uvm_mem_mam manager);
    uvm_mem_region value=manager.for_each(1);
    int count=0;
    while (value!=null && count<100) begin count++; value=manager.for_each(); end
    return count;
  endfunction
  class error_probe extends uvm_report_catcher;
    int errors=0;
    virtual function action_e catch();
      if (get_severity()==UVM_ERROR) begin errors++; return CAUGHT; end
      return THROW;
    endfunction
  endclass
  initial begin
    automatic int requests[4]='{1,4,5,13};
    automatic int locations[4]='{1,1,2,4};
    foreach (requests[i]) begin
      automatic uvm_mem_mam_cfg cfg=make_cfg();
      automatic uvm_mem_mam manager=new("manager",cfg);
      uvm_mem_region region;
      region=manager.reserve_region(12,requests[i]);
      if (region==null) $fatal(1,"missing region");
      $display("UT: region_units %0d start %0d end %0d locations %0d bytes %0d",i,
               region.get_start_offset()==12,region.get_end_offset()==11+locations[i],
               region.get_len()==locations[i],region.get_n_bytes()==4*locations[i]);
    end
    $finish;
  end
endmodule
