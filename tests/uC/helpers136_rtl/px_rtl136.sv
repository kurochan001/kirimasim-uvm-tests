// Original parameterized bus and design for the 136th RTL integration test.
// One request is presented per clock; a read returns its data on the next clock.

interface px_if136 #(parameter int W = 8) (input logic clk);
  logic rst_n = 1'b0;
  logic sel = 1'b0;
  logic write = 1'b0;
  logic [W-1:0] wdata = '0;
  logic [W-1:0] rdata;

  // Inputs are sampled one step before each edge and outputs are driven with
  // zero skew in the Re-NBA region of the clocking event (1800-2023 14.4,
  // 14.13 and 14.16), so a drive reaches the design at the next edge.
  clocking drv_cb @(posedge clk);
    default input #1step output #0;
    output sel, write, wdata;
    input rdata, rst_n;
  endclocking

  clocking mon_cb @(posedge clk);
    default input #1step;
    input sel, write, wdata, rdata, rst_n;
  endclocking
endinterface

// One register of W bits: a write stores wdata, and a read returns the stored
// value on the next clock. Reset clears the register. The port is a generic
// interface, which may be connected to an interface instance of any type
// (1800-2023 23.3.3.4), so both specializations of px_if136 connect to it.
module px_dut136 #(parameter int W = 8) (interface bus);
  logic [W-1:0] value;

  always_ff @(posedge bus.clk) begin
    if (!bus.rst_n) begin
      value <= '0;
      bus.rdata <= '0;
    end else if (bus.sel && bus.write) begin
      value <= bus.wdata;
    end else if (bus.sel) begin
      bus.rdata <= value;
    end
  end
endmodule
