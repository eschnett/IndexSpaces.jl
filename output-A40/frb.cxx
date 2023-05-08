/**
 * @file
 * @brief CUDA  kernel
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
 * @class cuda
 * @brief cudaCommand for 
 */
class cuda : public cudaCommand {
public:
    cuda(Config & config, const std::string& unique_name,
                          bufferContainer& host_buffers, cudaDeviceInterface& device);
    ~cuda();
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
    static constexpr int cuda_beam_layout_M = 48;
    static constexpr int cuda_beam_layout_N = 48;
    static constexpr int cuda_dish_layout_M = 24;
    static constexpr int cuda_dish_layout_N = 24;
    static constexpr int cuda_downsampling_factor = 40;
    static constexpr int cuda_number_of_complex_components = 2;
    static constexpr int cuda_number_of_dishes = 512;
    static constexpr int cuda_number_of_frequencies = 256;
    static constexpr int cuda_number_of_polarizations = 2;
    static constexpr int cuda_number_of_timesamples = 2064;

    // Kernel compile parameters:
    static constexpr int minthreads = 768;
    static constexpr int blocks_per_sm = 1;

    // Kernel call parameters:
    static constexpr int threads_x = 32;
    static constexpr int threads_y = 24;
    static constexpr int blocks = 256;
    static constexpr int shmem_bytes = 76896;

    // Kernel name:
    const char* const kernel_symbol = "_Z15julia_frb_1030913CuDeviceArrayI7Int16x2Li1ELi1EES_I9Float16x2Li1ELi1EES_I6Int4x8Li1ELi1EES_IS1_Li1ELi1EES_I5Int32Li1ELi1EE";

    // Kernel arguments:
    static constexpr std::size_t S_length = 2304UL;
    static constexpr std::size_t W_length = 1179648UL;
    static constexpr std::size_t E_length = 541065216UL;
    static constexpr std::size_t I_length = 239616UL;
    static constexpr std::size_t info_length = 786432UL;

    // Runtime parameters:

    // GPU memory:
    const std::string S_memname;
    const std::string W_memname;
    const std::string E_memname;
    const std::string I_memname;
    const std::string info_memname;
};

REGISTER_CUDA_COMMAND(cuda);

cuda::cuda(Config& config, const std::string& unique_name,
                                             bufferContainer& host_buffers,
                                             cudaDeviceInterface& device) :
    cudaCommand(config, unique_name, host_buffers, device, "", ".ptx")
    , S_memname(config.get<std::string>(unique_name, "gpu_mem_dishlayout"))
    , W_memname(config.get<std::string>(unique_name, "gpu_mem_phase"))
    , E_memname(config.get<std::string>(unique_name, "gpu_mem_voltage"))
    , I_memname(config.get<std::string>(unique_name, "gpu_mem_beamgrid"))
    , info_memname(config.get<std::string>(unique_name, "gpu_mem_info"))
{
    const int num_dishes = config.get<int>(unique_name, "num_dishes");
    if (num_dishes != (cuda_number_of_dishes))
      throw std::runtime_error(
        "The num_dishes config setting must be " + std::to_string(cuda_number_of_dishes) + " for the CUDA Baseband Beamformer");
    const int dish_grid_size = config.get<int>(unique_name, "dish_grid_size");
    if (dish_grid_size != (cuda_dish_layout_M))
      throw std::runtime_error(
        "The dish_grid_size config setting must be " + std::to_string(cuda_dish_layout_M) + " for the CUDA Baseband Beamformer");
    const int num_local_freq = config.get<int>(unique_name, "num_local_freq");
    if (num_local_freq != (cuda_number_of_frequencies))
      throw std::runtime_error(
        "The num_local_freq config setting must be " + std::to_string(cuda_number_of_frequencies) + " for the CUDA Baseband Beamformer");
    const int samples_per_data_set = config.get<int>(unique_name, "samples_per_data_set");
    if (samples_per_data_set != (cuda_number_of_timesamples))
      throw std::runtime_error(
        "The samples_per_data_set config setting must be " + std::to_string(cuda_number_of_timesamples) + " for the CUDA Baseband Beamformer");
    const int time_downsampling = config.get<int>(unique_name, "time_downsampling");
    if (time_downsampling != (cuda_downsampling_factor))
      throw std::runtime_error(
        "The time_downsampling config setting must be " + std::to_string(cuda_downsampling_factor) + " for the CUDA Baseband Beamformer");


    set_command_type(gpuCommandType::KERNEL);
    const std::vector<std::string> opts = {
        "--gpu-name=sm_86",
        "--verbose",
    };
    build_ptx({kernel_symbol}, opts);
}

cuda::~cuda() {}

cudaEvent_t cuda::execute(const int gpu_frame_id,
                                           const std::vector<cudaEvent_t>& /*pre_events*/,
                                           bool* const /*quit*/) {
    pre_execute(gpu_frame_id);

    void* const S_memory = device.get_gpu_memory_array(S_memname, gpu_frame_id, S_length);
    void* const W_memory = device.get_gpu_memory_array(W_memname, gpu_frame_id, W_length);
    void* const E_memory = device.get_gpu_memory_array(E_memname, gpu_frame_id, E_length);
    void* const I_memory = device.get_gpu_memory_array(I_memname, gpu_frame_id, I_length);
    void* const info_memory = device.get_gpu_memory_array(info_memname, gpu_frame_id, info_length);

    record_start_event(gpu_frame_id);

    const char* exc_arg = "exception";
    kernel_arg S_arg(S_memory, S_length);
    kernel_arg W_arg(W_memory, W_length);
    kernel_arg E_arg(E_memory, E_length);
    kernel_arg I_arg(I_memory, I_length);
    kernel_arg info_arg(info_memory, info_length);
    void* args[] = {&exc_arg
        , &S_arg
        , &W_arg
        , &E_arg
        , &I_arg
        , &info_arg
    };

    DEBUG("kernel_symbol: {}", kernel_symbol);
    DEBUG("runtime_kernels[kernel_symbol]: {}", static_cast<void*>(runtime_kernels[kernel_symbol]));
    CHECK_CU_ERROR(cuFuncSetAttribute(runtime_kernels[kernel_symbol],
                                      CU_FUNC_ATTRIBUTE_MAX_DYNAMIC_SHARED_SIZE_BYTES,
                                      shmem_bytes));

    DEBUG("Running CUDA  on GPU frame {:d}", gpu_frame_id);
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
