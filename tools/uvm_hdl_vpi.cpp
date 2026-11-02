// Original fixture backend for the check/read/deposit subset of UVM HDL DPI.
// Uses standard VPI handles and actual HDL storage, never a path/value mock.
// Supports packed variables up to 64 bits. This is not a general UVM overlay:
// force/release and other HDL types deliberately return failure.
#include "svdpi.h"
#include "vpi_user.h"
#include <algorithm>
#include <iterator>
#include <string>

namespace {
int counts[4] = {};
constexpr int kUvmWords = 1024 / 32;

vpiHandle lookup(const char* path) {
    vpiHandle handle = vpi_handle_by_name(const_cast<PLI_BYTE8*>(path), nullptr);
    if (handle) return handle;
    // The generated model's VPI root is TOP, outside the HDL hierarchy.
    std::string rooted = std::string("TOP.") + path;
    return vpi_handle_by_name(const_cast<PLI_BYTE8*>(rooted.c_str()), nullptr);
}

bool supported(vpiHandle handle) {
    if (!handle) return false;
    const int width = vpi_get(vpiSize, handle);
    const int type = vpi_get(vpiType, handle);
    return width > 0 && width <= 64 && (type == vpiReg || type == vpiNet);
}
}

extern "C" void uvm_test_hdl_reset_counts() {
    std::fill(std::begin(counts), std::end(counts), 0);
}

extern "C" int uvm_test_hdl_count(int operation) {
    return operation >= 0 && operation < 4 ? counts[operation] : -1;
}

extern "C" int uvm_hdl_check_path(const char* path) {
    ++counts[0];
    vpiHandle handle = lookup(path);
    if (!handle) return 0;
    vpi_free_object(handle);
    return 1;
}

extern "C" int uvm_hdl_deposit(const char* path, const svLogicVecVal* data) {
    ++counts[2];
    vpiHandle handle = lookup(path);
    if (!supported(handle)) {
        if (handle) vpi_free_object(handle);
        return 0;
    }
    s_vpi_vecval words[2] = {};
    const int size = (vpi_get(vpiSize, handle) + 31) / 32;
    for (int i = 0; i < size; ++i) {
        words[i].aval = data[i].aval;
        words[i].bval = data[i].bval;
    }
    s_vpi_value value = {};
    value.format = vpiVectorVal;
    value.value.vector = words;
    vpi_chk_error(nullptr);
    vpi_put_value(handle, &value, nullptr, vpiNoDelay);
    const int ok = vpi_chk_error(nullptr) == 0;
    vpi_free_object(handle);
    return ok;
}

extern "C" int uvm_hdl_read(const char* path, svLogicVecVal* data) {
    ++counts[1];
    vpiHandle handle = lookup(path);
    if (!supported(handle)) {
        if (handle) vpi_free_object(handle);
        return 0;
    }
    s_vpi_value value = {};
    value.format = vpiVectorVal;
    vpi_chk_error(nullptr);
    vpi_get_value(handle, &value);
    const int ok = vpi_chk_error(nullptr) == 0 && value.value.vector != nullptr;
    if (ok) {
        std::fill(data, data + kUvmWords, svLogicVecVal{});
        const int size = (vpi_get(vpiSize, handle) + 31) / 32;
        for (int i = 0; i < size; ++i) {
            data[i].aval = value.value.vector[i].aval;
            data[i].bval = value.value.vector[i].bval;
        }
    }
    vpi_free_object(handle);
    return ok;
}

// These symbols may be referenced by compiled UVM virtual methods even when
// no selected fixture calls them. Failure never masquerades as an operation.
extern "C" int uvm_hdl_force(const char*, const svLogicVecVal*) {
    ++counts[3];
    return 0;
}
extern "C" int uvm_hdl_release(const char*) {
    ++counts[3];
    return 0;
}
extern "C" int uvm_hdl_release_and_read(const char*, svLogicVecVal*) {
    ++counts[3];
    return 0;
}
