REM remove pyproject.toml to avoid installing deps from pip
if EXIST pyproject.toml DEL pyproject.toml
rd /s /q torchvision/csrc/io/image/cpu/giflib

set "TORCHVISION_INCLUDE=%LIBRARY_INC%"

set "TORCHVISION_USE_AVIF=1"
set "TORCHVISION_USE_HEIC=1"
set "TORCHVISION_USE_FFMPEG=0"

if not "%cuda_compiler_version%" == "None" (
    set TORCH_CUDA_ARCH_LIST=5.0;6.0;7.0;7.5;8.0;8.6;8.9;9.0;10.0;12.0+PTX
    set FORCE_CUDA=1
    set TORCHVISION_USE_NVJPEG=1
) else (
    set FORCE_CUDA=0
    set TORCHVISION_USE_NVJPEG=0
)

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
