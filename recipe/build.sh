#!/bin/bash
set -ex

if [[ "$cuda_compiler_version" == "None" ]]; then
  export FORCE_CUDA=0
else
  export CUDA_TOOLKIT_ROOT_DIR="${PREFIX}"
  # CF_TORCH_CUDA_ARCH_LIST is set by pytorch's activation scripts to match the arch list pytorch was built with.
  # See https://github.com/conda-forge/pytorch-cpu-feedstock/blob/main/recipe/activate.sh
  if [[ -z "${CF_TORCH_CUDA_ARCH_LIST:-}" ]]; then
    echo "CF_TORCH_CUDA_ARCH_LIST is not set. Ensure the correct pytorch is installed and its activation scripts have run."
    exit 1
  fi
  # Due to a change in the supported CUDA architectures, we need to replace 10.1 with 11.0 in the arch list if it is present.
  # See: https://github.com/conda-forge/pytorch-cpu-feedstock/issues/494
  export TORCH_CUDA_ARCH_LIST="${CF_TORCH_CUDA_ARCH_LIST//10.1/11.0}"
  echo "TORCH_CUDA_ARCH_LIST is set to ${TORCH_CUDA_ARCH_LIST}"
  export FORCE_CUDA=1
fi

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" == "1" ]]; then
  # Fix wrong (build) architecture being set instead of host architecture
  CFLAGS="$(echo ${CFLAGS} | sed 's/ -march=[^ ]*//g' | sed 's/ -mcpu=[^ ]*//g' |sed 's/ -mtune=[^ ]*//g')"
  CXXFLAGS="$(echo ${CXXFLAGS} | sed 's/ -march=[^ ]*//g' | sed 's/ -mcpu=[^ ]*//g' |sed 's/ -mtune=[^ ]*//g')"
fi

# remove pyproject.toml
rm -f pyproject.toml

# https://github.com/pytorch/vision/pull/8406/files#r1730151047
rm -rf torchvision/csrc/io/image/cpu/giflib

# hmaarrfk I found that it was pretty buggy:
# https://github.com/conda-forge/torchvision-feedstock/pull/60
export TORCHVISION_USE_FFMPEG=0
export TORCHVISION_USE_NVJPEG=${FORCE_CUDA}
export TORCHVISION_INCLUDE="${PREFIX}/include/"

# disabled by default but with a TODO to "enable by default"
export TORCHVISION_USE_AVIF=1
export TORCHVISION_USE_HEIC=1

${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
