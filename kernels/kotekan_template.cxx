/**
 * @file
 * @brief CUDA {{{kernel_name}}} kernel
 *
 * This file has been generated automatically.
 * Do not modify this C++ file, your changes will be lost.
 */

#include "cudaCommand.hpp"
#include "cudaDeviceInterface.hpp"

#include <fmt.hpp>

#include <array>
#include <stdexcept>
#include <string>
#include <vector>

using kotekan::bufferContainer;
using kotekan::Config;

/**
 * @class cuda{{{kernel_name}}}
 * @brief cudaCommand for {{{kernel_name}}}
 */
class cuda{{{kernel_name}}} : public cudaCommand {
public:
    cuda{{{kernel_name}}}(Config & config, const std::string& unique_name,
                          bufferContainer& host_buffers, cudaDeviceInterface& device);
    ~cuda{{{kernel_name}}}();
    cudaEvent_t execute(int gpu_frame_id, const std::vector<cudaEvent_t>& pre_events, bool* quit)
        override;

private:

    // Julia's `CuDevArray` type
    template<typename T, int64_t N>
    struct CuDeviceArray {
        T* ptr;
        int64_t maxsize; // bytes
        int64_t dims[N]; // elements
        int64_t len;     // elements
        CuDeviceArray(void* const ptr, const std::size_t bytes) :
            ptr(static_cast<T*>(ptr)), maxsize(bytes), dims{int64_t(maxsize / sizeof(T))},
            len(maxsize / sizeof(T)) {}
    };
    using kernel_arg = CuDeviceArray<int32_t, 1>;

    // Kernel design parameters:
    {{#kernel_design_parameters}}
    static constexpr {{{type}}} {{{name}}} = {{{value}}};
    {{/kernel_design_parameters}}

    // Kernel compile parameters:
    static constexpr int minthreads = {{{minthreads}}};
    static constexpr int blocks_per_sm = {{{num_blocks_per_sm}}};

    // Kernel call parameters:
    static constexpr int threads_x = {{{num_threads}}};
    static constexpr int threads_y = {{{num_warps}}};
    static constexpr int blocks = {{{num_blocks}}};
    static constexpr int shmem_bytes = {{{shmem_bytes}}};

    // Kernel name:
    const char* const kernel_symbol = "{{{kernel_symbol}}}";

    // Kernel arguments:
    {{#kernel_arguments}}
    static constexpr std::size_t {{{name}}}_length = {{{value}}};
    {{/kernel_arguments}}

    // Runtime parameters:
    {{#runtime_parameters}}
    {{{type}}} {{{name}}};
    {{/runtime_parameters}}

    // GPU memory:
    {{#memnames}}
    const std::string {{{name}}}_memname;
    {{/memnames}}
};

REGISTER_CUDA_COMMAND(cuda{{{kernel_name}}});

cuda{{{kernel_name}}}::cuda{{{kernel_name}}}(Config& config, const std::string& unique_name,
                                             bufferContainer& host_buffers,
                                             cudaDeviceInterface& device) :
    cudaCommand(config, unique_name, host_buffers, device, "{{{kernel_name}}}", "{{{kernel_name}}}.ptx")
    {{#memnames}}
    , {{{name}}}_memname(config.get<std::string>(unique_name, "{{{kotekan_name}}}"))
    {{/memnames}}
{
    {{#check_kotekan_parameters}}
    const int {{{name}}} = config.get<int>(unique_name, "{{{name}}}");
    if ({{{name}}} != ({{{value}}}))
      throw std::runtime_error(
        "The {{{name}}} config setting must be " + std::to_string({{{value}}}) + " for the CUDA Baseband Beamformer");
    {{/check_kotekan_parameters}}

    {{#runtime_parameters}}
    const {{{type}}} {{{name}}} = config.get<{{{type}}}>(unique_name, "{{{name}}}");
    std::vector<float16_t> freq_gains16(freq_gains.size());
    for (std::size_t i=0; i<freq_gains16.size(); i++)
      freq_gains16[i] = freq_gains[i];
    const void* const G_host = freq_gains16.data();
    void* const G_memory = device.get_gpu_memory(G_memname, G_length);
    CHECK_CUDA_ERROR(cudaMemcpy(G_memory, G_host, G_length, cudaMemcpyHostToDevice));
    {{/runtime_parameters}}

    set_command_type(gpuCommandType::KERNEL);
    const std::vector<std::string> opts = {
        "--gpu-name=sm_86",
        "--verbose",
    };
    build_ptx({kernel_symbol}, opts);
}

cuda{{{kernel_name}}}::~cuda{{{kernel_name}}}() {}

cudaEvent_t cuda{{{kernel_name}}}::execute(const int gpu_frame_id,
                                           const std::vector<cudaEvent_t>& /*pre_events*/,
                                           bool* const /*quit*/) {
    pre_execute(gpu_frame_id);

    {{#memnames}}
    void* const {{{name}}}_memory = device.get_gpu_memory_array({{{name}}}_memname, gpu_frame_id, {{{name}}}_length);
    {{/memnames}}

    record_start_event(gpu_frame_id);

    const char* exc_arg = "exception";
    {{#kernel_arguments}}
    kernel_arg {{{name}}}_arg({{{name}}}_memory, {{{name}}}_length);
    {{/kernel_arguments}}
    void* args[] = {&exc_arg
    {{#kernel_arguments}}
        , &{{{name}}}_arg
    {{/kernel_arguments}}
    };

    DEBUG("kernel_symbol: {}", kernel_symbol);
    DEBUG("runtime_kernels[kernel_symbol]: {}", static_cast<void*>(runtime_kernels[kernel_symbol]));
    CHECK_CU_ERROR(cuFuncSetAttribute(runtime_kernels[kernel_symbol],
                                      CU_FUNC_ATTRIBUTE_MAX_DYNAMIC_SHARED_SIZE_BYTES,
                                      shmem_bytes));

    DEBUG("Running CUDA {{{kernel_Name}}} on GPU frame {:d}", gpu_frame_id);
    const CUresult err =
        cuLaunchKernel(runtime_kernels[kernel_symbol], blocks, 1, 1, threads_x, threads_y, 1,
                       shmem_bytes, device.getStream(cuda_stream_id), args, NULL);

    if (err != CUDA_SUCCESS) {
        const char* errStr;
        cuGetErrorString(err, &errStr);
        INFO("Error number: {}", err);
        ERROR("cuLaunchKernel: {}", errStr);
    }

    return record_end_event(gpu_frame_id);
}
