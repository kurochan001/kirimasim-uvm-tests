class block85 extends uvm_reg_block;
  function new();
    super.new("owner85",UVM_NO_COVERAGE);
  endfunction
endclass

// Original user backdoor storage; this class does not access HDL.
class storage85 extends uvm_reg_backdoor;
  uvm_reg_data_t words[32];
  bit bad_address;
  uvm_reg_data_t word_mask;
  function new(int unsigned n_bits);
    super.new("storage85");
    word_mask=~uvm_reg_data_t'(0) >> ($bits(uvm_reg_data_t)-n_bits);
  endfunction
  virtual task write(uvm_reg_item rw);
    #1;
    if (rw.get_offset()>=32) begin
      bad_address=1;
      rw.set_status(UVM_NOT_OK);
      return;
    end
    words[rw.get_offset()]=rw.get_value(0) & word_mask;
    rw.set_status(UVM_IS_OK);
  endtask
  virtual task read(uvm_reg_item rw);
    #1;
    if (rw.get_offset()>=32) begin
      bad_address=1;
      rw.set_status(UVM_NOT_OK);
      return;
    end
    rw.set_value(words[rw.get_offset()] & word_mask);
    rw.set_status(UVM_IS_OK);
  endtask
endclass
