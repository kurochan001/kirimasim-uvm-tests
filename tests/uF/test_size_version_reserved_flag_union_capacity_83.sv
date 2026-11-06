/*
:name: test_size_version_reserved_flag_union_capacity_83
:description: The implementation reserved region stores the combined radix recursion and field flag representations
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.1.1 F.2.1.2 F.2.1.5 F.2.1.6 F.2.1.8 F.2.1.9 B.6.1 1800-2023 6.21 6.20 6.16 7.4 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_size_version_reserved_flag_union_capacity_83.expected
*/
// Original observations derived from IEEE.
// No implementation-specific lower-bit layout or version text is assumed.
`include "uvm_macros.svh"
module test_size_version_reserved_flag_union_capacity_83;
  import uvm_pkg::*;
  localparam int RESERVED83=uvm_pkg::UVM_FIELD_FLAG_RESERVED_BITS;
  localparam int WIDE83=$bits(uvm_field_flag_t)+$bits(uvm_radix_enum)+
    $bits(uvm_recursion_policy_enum)+$bits(UVM_ALL_ON)+1;
  typedef bit [WIDE83-1:0] wide83;
  initial begin
    automatic wide83 combined='0;
    uvm_radix_enum radix;
    uvm_recursion_policy_enum recursion;
    uvm_field_flag_t stored;
    radix=radix.first();
    repeat (radix.num()) begin combined |= {radix}; radix=radix.next(); end
    recursion=recursion.first();
    repeat (recursion.num()) begin combined |= {recursion}; recursion=recursion.next(); end
    combined |= {UVM_COPY};
    combined |= {UVM_COMPARE};
    combined |= {UVM_PRINT};
    combined |= {UVM_RECORD};
    combined |= {UVM_PACK};
    combined |= {UVM_UNPACK};
    combined |= {UVM_SET};
    combined |= {UVM_ALL_ON};
    combined |= {UVM_NOCOPY};
    combined |= {UVM_NOCOMPARE};
    combined |= {UVM_NOPRINT};
    combined |= {UVM_NORECORD};
    combined |= {UVM_NOPACK};
    combined |= {UVM_NOSET};
    stored=uvm_field_flag_t'(combined);
    $display("UT: flag83 reserved positive %0d union_fits %0d type_preserves %0d",
      RESERVED83>0,(combined >> RESERVED83)==0,wide83'(stored)==combined);
    $finish;
  end
endmodule
