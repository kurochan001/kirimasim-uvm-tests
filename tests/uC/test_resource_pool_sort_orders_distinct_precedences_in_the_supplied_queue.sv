/*
:name: test_resource_pool_sort_orders_distinct_precedences_in_the_supplied_queue
:description: resource pool sort orders distinct precedences in the supplied queue
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.4.4.3 C.2.4.5.6 C.2.4.3.1 C.2.2.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_pool_sort_orders_distinct_precedences_in_the_supplied_queue.expected
*/
module test_resource_pool_sort_orders_distinct_precedences_in_the_supplied_queue;
  import uvm_pkg::*;
  initial begin
    uvm_resource_pool pool;
    uvm_resource#(int) low,middle,high;
    uvm_resource_types::rsrc_q_t values;
    pool=uvm_resource_pool::get(); low=new("low62"); middle=new("middle62");
    high=new("high62"); values=new();
    pool.set_scope(low,"scope62"); pool.set_scope(middle,"scope62");
    pool.set_scope(high,"scope62");
    pool.set_precedence(low,0); pool.set_precedence(middle,17);
    pool.set_precedence(high,93);
    values.push_back(middle); values.push_back(low); values.push_back(high);
    uvm_resource_pool::sort_by_precedence(values);
    $display("UT: sort_distinct count %0d descending %0d",
      values.size()==3,
      values.get(0)==high && values.get(1)==middle && values.get(2)==low);
    pool.set_precedence(low,101); uvm_resource_pool::sort_by_precedence(values);
    $display("UT: sort_changed current_values %0d",
      values.get(0)==low && values.get(1)==high && values.get(2)==middle);
    $finish;
  end
endmodule
