set "TORCHVISION_INCLUDE=%LIBRARY_INC%"

rem disabled by default but with a TODO to "enable by default"
set "TORCHVISION_USE_AVIF=1"
set "TORCHVISION_USE_HEIC=1"

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
