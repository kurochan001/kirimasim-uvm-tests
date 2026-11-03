// Compile the pinned Apache-2.0 UVM regex implementation for its existing
// DPI interface. This wrapper is original; no library source is copied.
extern "C" {
#include "../../third_party/uvm/2020.3.1/src/dpi/uvm_regex.cc"
}
