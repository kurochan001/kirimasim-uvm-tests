/*
:name: test_reg_tlm_adapter_nonuniform_payload_arrays_remain_independent_across_conversions
:description: converted payload arrays retain their values after source reuse and peer mutation (IEEE 1800.2-2020 Section 19.2.2.2.1)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.2.2.2.1 19.2.1.2.5 19.1.2.3 19.1.2.5 12.3.4.2.15 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_tlm_adapter_nonuniform_payload_arrays_remain_independent_across_conversions.expected
*/
// What it checks:
// 1. An earlier payload retains its data/enable arrays after the source struct
//    is reused.
// 2. Public array mutation on one converted payload leaves the other payload
//    unchanged.
// 3. Successive conversions return distinct payload objects with their own
//    addresses.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 19.2.2.2.1 (UVM-TLM-ROUNDTRIP-EARLIER-ARRAY-SNAPSHOT) gives
//    rule 1 above. Setup: A second nonuniform conversion uses changed scalar
//    data, address and mask. Expected: Earlier arrays equal their entry
//    snapshots.
// 2. 1800.2-2020 19.2.2.2.1 (UVM-TLM-ROUNDTRIP-PEER-ARRAY-ISOLATION) gives
//    rule 2 above. Setup: After two conversions, first data and enable arrays
//    are replaced. Expected: Second data and enable arrays retain their
//    snapshots.
// 3. 1800.2-2020 19.2.1.2.5 (UVM-TLM-ROUNDTRIP-FRESH-ARRAY-OWNERS) gives rule
//    3 above. Setup: One adapter converts two nonuniform source structs with
//    different addresses. Expected: Handles differ and addresses remain 0x120
//    and 0x240.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Snapshots compare opaque byte-array sequences without numeric byte
// ordering.
// Source-struct reuse and later public mutation must not alter a peer
// payload.
// The arrays stay valid only under the original converter contracts.
module test_reg_tlm_adapter_nonuniform_payload_arrays_remain_independent_across_conversions;
  import uvm_pkg::*;
  initial begin
    automatic uvm_reg_tlm_adapter adapter = new("adapter");
    uvm_reg_bus_op source;
    uvm_sequence_item item;
    uvm_tlm_gp first, second;
    byte unsigned first_data[], first_enables[], second_data[], second_enables[];
    byte unsigned data_now[], enables_now[], changed_data[], changed_enables[];
    bit first_stable, second_stable;
    source.kind = UVM_WRITE; source.addr = 'h120; source.data = 'h12ab56cd;
    source.n_bits = 32; source.byte_en = 'h3; source.status = UVM_IS_OK;
    item = adapter.reg2bus(source);
    if (!$cast(first, item) || first == null) $fatal(1, "wrong payload type");
    first.get_data(first_data); first.get_byte_enable(first_enables);
    source.addr = 'h240; source.data = 'hcd56ab12; source.byte_en = 'hC;
    item = adapter.reg2bus(source);
    if (!$cast(second, item) || second == null) $fatal(1, "wrong payload type");
    first.get_data(data_now); first.get_byte_enable(enables_now);
    first_stable = first_data.size() == data_now.size() &&
                   first_enables.size() == enables_now.size();
    foreach (first_data[i]) first_stable &= first_data[i] == data_now[i];
    foreach (first_enables[i]) first_stable &= first_enables[i] == enables_now[i];
    $display("UT: first_stable %0d distinct %0d addresses %0d", first_stable,
             first != second, first.get_address() == 'h120 && second.get_address() == 'h240);
    second.get_data(second_data); second.get_byte_enable(second_enables);
    changed_data = new[first_data.size()]; changed_enables = new[first_enables.size()];
    foreach (changed_data[i]) changed_data[i] = 'hff;
    foreach (changed_enables[i]) changed_enables[i] = 0;
    first.set_data(changed_data); first.set_byte_enable(changed_enables);
    second.get_data(data_now); second.get_byte_enable(enables_now);
    second_stable = second_data.size() == data_now.size() &&
                    second_enables.size() == enables_now.size();
    foreach (second_data[i]) second_stable &= second_data[i] == data_now[i];
    foreach (second_enables[i]) second_stable &= second_enables[i] == enables_now[i];
    $display("UT: second_stable %0d", second_stable);
    $finish;
  end
endmodule
