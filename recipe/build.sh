set -ex

if [[ "$cuda_compiler_version" == "None" ]]; then
  export FORCE_CUDA=0
else
  if [[ ${cuda_compiler_version} == 12.6 ]]; then
      export TORCH_CUDA_ARCH_LIST="5.0;6.0;6.1;7.0;7.5;8.0;8.6;8.9;9.0"
      # $CUDA_HOME not set in CUDA 12.0. Using $PREFIX
      export CUDA_TOOLKIT_ROOT_DIR="${PREFIX}"
  else
      echo "unsupported cuda version. edit build.sh"
      exit 1
  fi
  # Add PTX at the end, always
  export TORCH_CUDA_ARCH_LIST="${TORCH_CUDA_ARCH_LIST}+PTX"
  export FORCE_CUDA=1
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
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
