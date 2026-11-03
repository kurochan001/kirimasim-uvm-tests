/*
:name: test_bidirectional_export_constructors_preserve_default_bounds_roles_names_and_parents
:description: all nine bidirectional export constructors retain default bounds and component identity (12.2.6.2)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.6.2 5.5.2.2 5.5.2.4 5.5.2.6 5.5.2.7 5.5.2.11 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_bidirectional_export_constructors_preserve_default_bounds_roles_names_and_parents.expected
*/
module test_bidirectional_export_constructors_preserve_default_bounds_roles_names_and_parents;
  import uvm_pkg::*;
  class owner extends uvm_component;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
  initial begin
    automatic owner parent = new("parent", null);
    automatic uvm_blocking_transport_export#(int, string) e0 = new("e0", parent);
    automatic uvm_nonblocking_transport_export#(int, string) e1 = new("e1", parent);
    automatic uvm_transport_export#(int, string) e2 = new("e2", parent);
    automatic uvm_blocking_master_export#(int, string) e3 = new("e3", parent);
    automatic uvm_nonblocking_master_export#(int, string) e4 = new("e4", parent);
    automatic uvm_master_export#(int, string) e5 = new("e5", parent);
    automatic uvm_blocking_slave_export#(int, string) e6 = new("e6", parent);
    automatic uvm_nonblocking_slave_export#(int, string) e7 = new("e7", parent);
    automatic uvm_slave_export#(int, string) e8 = new("e8", parent);
    bit bounds, roles, parents, names;
    int count;
    bounds = 1;
    roles = 1;
    parents = 1;
    names = 1;
    count = 0;
    bounds &= e0.min_size() == 1 && e0.max_size() == 1;
    roles &= e0.is_export() && !e0.is_port() && !e0.is_imp();
    parents &= e0.get_parent() == parent;
    names &= e0.get_name() == "e0";
    count++;
    bounds &= e1.min_size() == 1 && e1.max_size() == 1;
    roles &= e1.is_export() && !e1.is_port() && !e1.is_imp();
    parents &= e1.get_parent() == parent;
    names &= e1.get_name() == "e1";
    count++;
    bounds &= e2.min_size() == 1 && e2.max_size() == 1;
    roles &= e2.is_export() && !e2.is_port() && !e2.is_imp();
    parents &= e2.get_parent() == parent;
    names &= e2.get_name() == "e2";
    count++;
    bounds &= e3.min_size() == 1 && e3.max_size() == 1;
    roles &= e3.is_export() && !e3.is_port() && !e3.is_imp();
    parents &= e3.get_parent() == parent;
    names &= e3.get_name() == "e3";
    count++;
    bounds &= e4.min_size() == 1 && e4.max_size() == 1;
    roles &= e4.is_export() && !e4.is_port() && !e4.is_imp();
    parents &= e4.get_parent() == parent;
    names &= e4.get_name() == "e4";
    count++;
    bounds &= e5.min_size() == 1 && e5.max_size() == 1;
    roles &= e5.is_export() && !e5.is_port() && !e5.is_imp();
    parents &= e5.get_parent() == parent;
    names &= e5.get_name() == "e5";
    count++;
    bounds &= e6.min_size() == 1 && e6.max_size() == 1;
    roles &= e6.is_export() && !e6.is_port() && !e6.is_imp();
    parents &= e6.get_parent() == parent;
    names &= e6.get_name() == "e6";
    count++;
    bounds &= e7.min_size() == 1 && e7.max_size() == 1;
    roles &= e7.is_export() && !e7.is_port() && !e7.is_imp();
    parents &= e7.get_parent() == parent;
    names &= e7.get_name() == "e7";
    count++;
    bounds &= e8.min_size() == 1 && e8.max_size() == 1;
    roles &= e8.is_export() && !e8.is_port() && !e8.is_imp();
    parents &= e8.get_parent() == parent;
    names &= e8.get_name() == "e8";
    count++;
    $display("UT: exports %0d bounds %0d roles %0d parents %0d names %0d",
             count, bounds, roles, parents, names);
    $finish;
  end
endmodule
