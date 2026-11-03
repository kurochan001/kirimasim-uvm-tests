/*
:name: test_map_address_units_distinguish_bytes_and_the_printed_default_effective_word_width
:description: map address units distinguish bytes and the printed default effective word width
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.4.5 18.2.4.6 18.2.3.5 18.1.2.3 18.1.2.6 18.1.2.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_map_address_units_distinguish_bytes_and_the_printed_default_effective_word_width.expected
*/
// Empty-map effective width is independent of the qualified word-unit reading.
module test_map_address_units_distinguish_bytes_and_the_printed_default_effective_word_width;
  import uvm_pkg::*;
  class block_type extends uvm_reg_block;
    function new(string name); super.new(name,UVM_NO_COVERAGE); endfunction
  endclass

  initial begin
    automatic block_type root=new("root51");
    automatic block_type word_child=new("word51");
    automatic block_type byte_child=new("byte51");
    uvm_reg_map outer,words,bytes,flat;
    root.configure();word_child.configure(root);byte_child.configure(root);
    outer=root.create_map("outer51",0,2,UVM_LITTLE_ENDIAN,1);
    words=word_child.create_map("words51",0,8,UVM_LITTLE_ENDIAN,0);
    bytes=byte_child.create_map("bytes51",0,8,UVM_LITTLE_ENDIAN,1);
    flat=root.create_map("flat51",0,8,UVM_LITTLE_ENDIAN,0);
    outer.add_submap(words,'h40);outer.add_submap(bytes,'h80);root.lock_model();
    $display("UT: map_unit byte %0d flat_word %0d local_word_width %0d effective_width %0d",
      bytes.get_addr_unit_bytes(),flat.get_addr_unit_bytes(),
      words.get_n_bytes(UVM_NO_HIER),words.get_n_bytes());
    $display("UT: map_unit printed_get_n_bytes_relation %0d word_unit %0d",
      words.get_addr_unit_bytes()==words.get_n_bytes(),words.get_addr_unit_bytes());
    $finish;
  end
endmodule
