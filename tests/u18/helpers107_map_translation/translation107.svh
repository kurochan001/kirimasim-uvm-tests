// Original public-map fixture; no bus, HDL storage or implementation-derived oracle.
class block107 extends uvm_reg_block;
  function new(string name); super.new(name, UVM_NO_COVERAGE); endfunction
endclass
class reg107 extends uvm_reg;
  function new(string name); super.new(name, 32, UVM_NO_COVERAGE); endfunction
endclass

function automatic void populate107(input block107 owner, input uvm_reg_map mapping,
                                    input string name);
  automatic reg107 rg = new(name);
  automatic uvm_reg_field value = new("value");
  rg.configure(owner);
  value.configure(rg, 32, 0, "RW", 0, 0, 1, 0, 1);
  mapping.add_reg(rg, 'h80);
endfunction

function automatic void query107(input uvm_reg_map mapping, input string label,
                                input int unsigned n_bytes,
                                input uvm_reg_addr_t index,
                                ref uvm_reg_addr_t addresses[],
                                input bit check_transfer = 1);
  int transferred;
  transferred = mapping.get_physical_addresses('h20, index, n_bytes, addresses);
  if (check_transfer)
    $display("UT: %s transfer %0d count %0d", label, transferred, addresses.size());
  else begin
    $display("UT: %s count %0d", label, addresses.size());
    $display("DIAG107: partial transfer %0d", transferred);
  end
  foreach (addresses[i])
    $display("UT: %s address %0d %0h", label, i, addresses[i]);
endfunction

task automatic exercise107(input int unsigned local_width, input int unsigned root_width,
                           input uvm_endianness_e endian, input bit byte_addressing,
                           input bit hierarchical, input bit populated, input bit fifo,
                           input bit partial_probe);
  automatic block107 root = new("root");
  automatic block107 child = new("child");
  uvm_reg_map outer;
  uvm_reg_map mapping;
  uvm_reg_map expected_parent;
  uvm_reg_addr_t addresses[];
  uvm_reg_addr_t independent[];
  root.configure();
  outer = root.create_map("outer", 'h100, root_width, endian, byte_addressing);
  if (hierarchical) begin
    child.configure(root);
    mapping = child.create_map("inner", 'h900, local_width, endian, byte_addressing);
    outer.add_submap(mapping, 'h40);
    expected_parent = outer;
    if (populated) begin
      populate107(root, outer, "outer_control");
      populate107(child, mapping, "inner_control");
    end
  end else begin
    mapping = outer;
    if (populated) populate107(root, outer, "control");
  end
  root.lock_model();
  $display("UT: setup root %0d parent %0d base %0h local_width %0d effective_width %0d unit %0d",
           mapping.get_root_map() == outer,
           mapping.get_parent_map() == expected_parent,
           mapping.get_base_addr(), mapping.get_n_bytes(UVM_NO_HIER),
           mapping.get_n_bytes(), mapping.get_addr_unit_bytes());
  addresses = new[3];
  addresses[0] = 'hdead; addresses[1] = 'hbeef; addresses[2] = 'hcafe;
  independent = new[2]; independent[0] = 'h55; independent[1] = 'haa;
  query107(mapping, "wide_first", 2 * local_width, 0, addresses);
  if (fifo) begin
    query107(mapping, "single", local_width, 0, addresses);
    query107(mapping, "triple", 3 * local_width, 0, addresses);
  end else begin
    query107(mapping, "wide_next", 2 * local_width, 1, addresses);
    query107(mapping, "single_last", local_width, 3, addresses);
  end
  query107(mapping, "wide_restored", 2 * local_width, 0, addresses);
  if (partial_probe) query107(mapping, "partial", 6, 0, addresses, 0);
  $display("UT: independent count %0d values %0h %0h", independent.size(),
           independent[0], independent[1]);
endtask
