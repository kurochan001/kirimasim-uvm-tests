// Original command-line DPI bridge using only the standard VPI interface.
// This backend supplies process arguments and public tool information; it
// implements neither UVM matching/parsing nor a regex or HDL-access oracle.
#include <vpi_user.h>

#include <cstddef>
#include <string>
#include <vector>

namespace {
std::vector<std::string> arguments;
std::size_t next_argument = 0;
std::string tool_name;
std::string tool_version;

void load_arguments() {
    s_vpi_vlog_info info{};
    arguments.clear();
    next_argument = 0;
    tool_name.clear();
    tool_version.clear();
    if (!vpi_get_vlog_info(&info)) return;
    for (int index = 0; index < info.argc; ++index) {
        arguments.emplace_back(info.argv[index] ? info.argv[index] : "");
    }
    if (info.product) tool_name = info.product;
    if (info.version) tool_version = info.version;
}
}  // namespace

extern "C" const char* uvm_dpi_get_next_arg_c(int initialize) {
    if (initialize) load_arguments();
    if (next_argument >= arguments.size()) return "";
    return arguments[next_argument++].c_str();
}

extern "C" const char* uvm_dpi_get_tool_name_c() {
    return tool_name.c_str();
}

extern "C" const char* uvm_dpi_get_tool_version_c() {
    return tool_version.c_str();
}
