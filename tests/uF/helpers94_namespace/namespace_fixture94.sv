// Lexically separate packages exercise both standard access forms.
package qualified94;
  typedef uvm_pkg::uvm_bitstream_t word94;
  class packet94 extends uvm_pkg::uvm_object;
    function new(string name="qualified94");
      super.new(name);
    endfunction
  endclass
  function automatic uvm_pkg::uvm_object echo94(uvm_pkg::uvm_object value);
    return value;
  endfunction
  function automatic uvm_pkg::uvm_root root94();
    return uvm_pkg::uvm_root::get();
  endfunction
  function automatic uvm_pkg::uvm_report_object reporter94();
    return uvm_pkg::uvm_get_report_object();
  endfunction
  function automatic string radix94(uvm_pkg::uvm_radix_enum value);
    return value.name();
  endfunction
endpackage
package imported94;
  import uvm_pkg::*;
  typedef uvm_bitstream_t word94;
  class packet94 extends uvm_object;
    function new(string name="imported94");
      super.new(name);
    endfunction
  endclass
  function automatic uvm_object echo94(uvm_object value);
    return value;
  endfunction
  function automatic uvm_root root94();
    return uvm_root::get();
  endfunction
  function automatic uvm_report_object reporter94();
    return uvm_get_report_object();
  endfunction
  function automatic string radix94(uvm_radix_enum value);
    return value.name();
  endfunction
endpackage
