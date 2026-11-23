/*
:name: test_factory_override_of_package_parameter_class_leaves_other_width_untouched
:description: Type overrides across packages distinguish specializations and survive interleaved creations (IEEE 1800.2-2020 Section 8.3.1.4.2)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.3.1.4.2 8.3.1.5 8.2.4.2.4 8.2.4.2.5 B.2.1.1 1800-2023 8.25 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_factory_override_of_package_parameter_class_leaves_other_width_untouched.expected
*/
// A consumer package registers a type override for only the 8-bit
// specialization of a package-defined packet. Interleave narrow, wide and
// narrow creations. Check the exact factory wrapper, full-width payload,
// handle identity and a second independent overridden instance. No type-name
// spelling is assumed.

package packet_types;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class packet #(int WIDTH=8) extends uvm_sequence_item;
    `uvm_object_param_utils(packet #(WIDTH))
    bit [WIDTH-1:0] payload;
    function new(string name="packet");
      super.new(name);
    endfunction
  endclass
endpackage

package packet_policy;
  import uvm_pkg::*;
  typedef packet_types::packet #(8) narrow;
  class tagged_narrow extends narrow;
    `uvm_object_utils(tagged_narrow)
    function new(string name="tagged");
      super.new(name);
    endfunction
  endclass
endpackage

module test_factory_override_of_package_parameter_class_leaves_other_width_untouched;
  import uvm_pkg::*;
  import packet_policy::*;
  typedef packet_types::packet #(16) wide;

  initial begin
    narrow a, c;
    wide b;
    automatic uvm_object_wrapper narrow_proxy = narrow::get_type();
    automatic uvm_object_wrapper wide_proxy = wide::get_type();
    narrow::type_id::set_type_override(tagged_narrow::get_type());
    a = narrow::type_id::create("a");
    b = wide::type_id::create("b");
    c = narrow::type_id::create("c");
    if (a == null || b == null || c == null) $fatal(1, "missing factory product");
    a.payload = 'ha5;
    b.payload = 'hb6c1;
    $display("UT: distinct proxies %0d", narrow_proxy != wide_proxy);
    $display("UT: first %0d wide %0d second %0d",
             a.get_object_type() == tagged_narrow::get_type(),
             b.get_object_type() == wide_proxy,
             c.get_object_type() == tagged_narrow::get_type());
    $display("UT: separate %0d payloads %0h %0h %0h names %s %s %s",
             a != c, a.payload, b.payload, c.payload, a.get_name(), b.get_name(), c.get_name());
    $finish;
  end
endmodule
