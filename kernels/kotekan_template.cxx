/**
 * @file
 * @brief CUDA {{{kernel_name}}} kernel
 *
 * This file has been generated automatically.
 * Do not modify this C++ file, your changes will be lost.
 */

#include "cudaCommand.hpp"
#include "cudaDeviceInterface.hpp"

#include <bufferContainer.hpp>

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
    virtual ~cuda{{{kernel_name}}}();
    
    // int wait_on_precondition(int gpu_frame_id) override;
    cudaEvent_t execute(int gpu_frame_id, const std::vector<cudaEvent_t>& pre_events, bool* quit) override;
    void finalize_frame(int gpu_frame_id) override;

private:

    // Julia's `CuDevArray` type
    template<typename T, std::int64_t N>
    struct CuDeviceArray {
        T* ptr;
        std::int64_t maxsize; // bytes
        std::int64_t dims[N]; // elements
        std::int64_t len;     // elements
        CuDeviceArray(void* const ptr, const std::size_t bytes) :
            ptr(static_cast<T*>(ptr)),
            maxsize(bytes),
            dims{std::int64_t(maxsize / sizeof(T))},
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
    const char* const kernel_symbol = "{{kernel_symbol}}";

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

    // Host-side buffer arrays
    {{#memnames}}
    {{^hasbuffer}}
    std::vector<std::vector<std::int32_t>> host_{{{name}}};
    {{/hasbuffer}}
    {{/memnames}}
};

REGISTER_CUDA_COMMAND(cuda{{{kernel_name}}});

cuda{{{kernel_name}}}::cuda{{{kernel_name}}}(Config& config,
                                             const std::string& unique_name,
                                             bufferContainer& host_buffers,
                                             cudaDeviceInterface& device) :
    cudaCommand(config, unique_name, host_buffers, device, "{{{kernel_name}}}", "{{{kernel_name}}}.ptx")
    {{#memnames}}
    {{#hasbuffer}}
    , {{{name}}}_memname(config.get<std::string>(unique_name, "{{kotekan_name}}"))
    {{/hasbuffer}}
    {{^hasbuffer}}
    , {{{name}}}_memname(unique_name + "/info")
    {{/hasbuffer}}
    {{/memnames}}
{
    // // Add Graphviz entries for the GPU buffers used by this kernel.
    // {{#memnames}}
    // {{#hasbuffer}}
    // gpu_buffers_used.push_back(std::make_tuple({{{name}}}_memname, true, true, false));
    // {{/hasbuffer}}
    // {{^hasbuffer}}
    // gpu_buffers_used.push_back(std::make_tuple(get_name() + "_info", false, true, true));
    // {{/hasbuffer}}
    // {{/memnames}}

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

    // {{#memnames}}
    // const std::string {{{name}}}_buffer_name = "host_" + {{{name}}}_memname;
    // Buffer* const {{{name}}}_buffer = host_buffers.get_buffer({{{name}}}_buffer_name.c_str());
    // assert({{{name}}}_buffer);
    // {{^isoutput}}
    // register_consumer({{{name}}}_buffer, unique_name.c_str());
    // {{/isoutput}}
    // {{#isoutput}}
    // register_producer({{{name}}}_buffer, unique_name.c_str());
    // {{/isoutput}}
    // {{/memnames}}
}

cuda{{{kernel_name}}}::~cuda{{{kernel_name}}}() {}

// int cuda{{{kernel_name}}}::wait_on_precondition(const int gpu_frame_id) {
//     {{#memnames}}
//     {{^isoutput}}
//     const std::string {{{name}}}_buffer_name = "host_" + {{{name}}}_memname;
//     Buffer* const {{{name}}}_buffer = host_buffers.get_buffer({{{name}}}_buffer_name.c_str());
//     assert({{{name}}}_buffer);
//     uint8_t* const {{{name}}}_frame = wait_for_full_frame({{{name}}}_buffer, unique_name.c_str(), gpu_frame_id);
//     if (!{{{name}}}_frame)
//         return -1;
//     {{/isoutput}}
//     {{/memnames}}
// 
//     return 0;
// }

cudaEvent_t cuda{{{kernel_name}}}::execute(const int gpu_frame_id,
                                           const std::vector<cudaEvent_t>& /*pre_events*/,
                                           bool* const /*quit*/) {
    pre_execute(gpu_frame_id);

    {{#memnames}}
    {{#hasbuffer}}
    void* const {{{name}}}_memory = device.get_gpu_memory_array({{{name}}}_memname, gpu_frame_id, {{{name}}}_length);
    {{/hasbuffer}}
    {{^hasbuffer}}
    std::int32_t* const {{{name}}}_memory =
        static_cast<std::int32_t*>(device.get_gpu_memory({{{name}}}_memname, {{{name}}}_length));
    host_{{{name}}}.resize(_gpu_buffer_depth);
    for (int i = 0; i < _gpu_buffer_depth; ++i)
        host_info[i].resize({{{name}}}_length / sizeof(std::int32_t));
    {{/hasbuffer}}
    {{/memnames}}

    record_start_event(gpu_frame_id);

    // Initialize host-side buffer arrays
    {{#memnames}}
    {{^hasbuffer}}
    CHECK_CUDA_ERROR(cudaMemsetAsync({{{name}}}_memory, 0xff, {{{name}}}_length, device.getStream(cuda_stream_id)));
    {{/hasbuffer}}
    {{/memnames}}

    const char* exc_arg = "exception";
    {{#kernel_arguments}}
    kernel_arg {{{name}}}_arg({{{name}}}_memory, {{{name}}}_length);
    {{/kernel_arguments}}
    void* args[] = {
        &exc_arg,
        {{#kernel_arguments}}
        &{{{name}}}_arg,
        {{/kernel_arguments}}
    };

    DEBUG("kernel_symbol: {}", kernel_symbol);
    DEBUG("runtime_kernels[kernel_symbol]: {}", static_cast<void*>(runtime_kernels[kernel_symbol]));
    CHECK_CU_ERROR(cuFuncSetAttribute(runtime_kernels[kernel_symbol],
                                      CU_FUNC_ATTRIBUTE_MAX_DYNAMIC_SHARED_SIZE_BYTES,
                                      shmem_bytes));

    DEBUG("Running CUDA {{{kernel_name}}} on GPU frame {:d}", gpu_frame_id);
    const CUresult err =
        cuLaunchKernel(runtime_kernels[kernel_symbol], blocks, 1, 1, threads_x, threads_y, 1,
                       shmem_bytes, device.getStream(cuda_stream_id), args, NULL);

    if (err != CUDA_SUCCESS) {
        const char* errStr;
        cuGetErrorString(err, &errStr);
        INFO("Error number: {}", err);
        ERROR("cuLaunchKernel: {}", errStr);
    }

    // Copy results back to host memory
    {{#memnames}}
    {{^hasbuffer}}
    CHECK_CUDA_ERROR(cudaMemcpyAsync(host_{{{name}}}[gpu_frame_id].data(),
                                     {{{name}}}_memory, {{{name}}}_length, cudaMemcpyDeviceToHost,
                                     device.getStream(cuda_stream_id)));
    {{/hasbuffer}}
    {{/memnames}}

   return record_end_event(gpu_frame_id);
}

void cuda{{{kernel_name}}}::finalize_frame(const int gpu_frame_id) {
    cudaCommand::finalize_frame(gpu_frame_id);

    {{#memnames}}
    // {{#isoutput}}
    // const std::string {{{name}}}_buffer_name = "host_" + {{{name}}}_memname;
    // Buffer* const {{{name}}}_buffer = host_buffers.get_buffer({{{name}}}_buffer_name.c_str());
    // assert({{{name}}}_buffer);
    // mark_frame_full({{{name}}}_buffer, unique_name.c_str(), gpu_frame_id);
    // {{/isoutput}}
    {{^hasbuffer}}
    for (std::size_t i = 0; i < host_{{{name}}}[gpu_frame_id].size(); ++i)
        if (host_{{{name}}}[gpu_frame_id][i] != 0)
            ERROR("cuda{{{kernel_name}}} returned '{{{name}}}' value {:d} at index {:d} (zero indicates noerror)",
                  host_{{{name}}}[gpu_frame_id][i], int(i));
    {{/hasbuffer}}
    {{/memnames}}
}
