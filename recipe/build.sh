set -ex

if [[ "$cuda_compiler_version" == "None" ]]; then
  export FORCE_CUDA=0
else
  if [[ ${cuda_compiler_version} == 12.9 ]]; then
      export TORCH_CUDA_ARCH_LIST="5.0;6.0;7.0;7.5;8.0;8.6;8.9;9.0;10.0;12.0+PTX"
      # $CUDA_HOME not set in CUDA 12.0. Using $PREFIX
      export CUDA_TOOLKIT_ROOT_DIR="${PREFIX}"
  else
      echo "unsupported cuda version. edit build.sh"
      exit 1
  fi
  export FORCE_CUDA=1
fi

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" == "1" ]]; then
  # Fix wrong (build) architecture being set instead of host architecture
  CFLAGS="$(echo ${CFLAGS} | sed 's/ -march=[^ ]*//g' | sed 's/ -mcpu=[^ ]*//g' |sed 's/ -mtune=[^ ]*//g')"
  CXXFLAGS="$(echo ${CXXFLAGS} | sed 's/ -march=[^ ]*//g' | sed 's/ -mcpu=[^ ]*//g' |sed 's/ -mtune=[^ ]*//g')"

  # remove build prefix headers that conflict wtih cross compilation
  rm -rf "${BUILD_PREFIX}"/venv/lib/python3.*/site-packages/torch/include/torch/csrc/api/include/
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
