@echo on

REM remove pyproject.toml to avoid installing deps from pip
if EXIST pyproject.toml DEL pyproject.toml
rd /s /q torchvision/csrc/io/image/cpu/giflib

set "TORCHVISION_INCLUDE=%LIBRARY_INC%"

set "TORCHVISION_USE_AVIF=1"
set "TORCHVISION_USE_HEIC=1"
set "TORCHVISION_USE_FFMPEG=0"

if not "%cuda_compiler_version%" == "None" (
    REM CF_TORCH_CUDA_ARCH_LIST is set by pytorch's activation scripts to match the arch list pytorch was built with.
    REM See https://github.com/conda-forge/pytorch-cpu-feedstock/blob/main/recipe/activate.sh
    if "%CF_TORCH_CUDA_ARCH_LIST%" == "" (
        echo CF_TORCH_CUDA_ARCH_LIST is not set. Ensure the correct pytorch is installed and its activation scripts have run.
        exit /b 1
    )
    set "TORCH_CUDA_ARCH_LIST=%CF_TORCH_CUDA_ARCH_LIST%"
    echo TORCH_CUDA_ARCH_LIST is set to %TORCH_CUDA_ARCH_LIST%

    set FORCE_CUDA=1
    set TORCHVISION_USE_NVJPEG=1
) else (
    set FORCE_CUDA=0
    set TORCHVISION_USE_NVJPEG=0
)

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
