if [[ "$cuda_compiler_version" == "None" ]]; then
  export FORCE_CUDA=0
else
  export FORCE_CUDA=1
fi

export TORCHVISION_INCLUDE="${PREFIX}/include/"
${PYTHON} -m pip install . -vv
