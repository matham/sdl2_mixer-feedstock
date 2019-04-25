setlocal EnableDelayedExpansion

if %ARCH%==32 (
	set PLATFORM=Win32
) else if %ARCH%==64 (
	set PLATFORM=x64
)

:: See https://github.com/conda-forge/staged-recipes/pull/194#issuecomment-203577297
:: Nasty workaround. Need to move a more current msbuild into PATH.  The one on
:: AppVeyor barfs on the solution. This one comes from the Win7 SDK (.net 4.0),
:: and is known to work.
if %VS_MAJOR%==9 (
    set "PATH=C:\Windows\Microsoft.NET\Framework\v4.0.30319;%PATH%"
)

if not %USERNAME%==appveyor (
    echo "setting VCTargetsPath"
    set "VCTargetsPath=C:\Program Files (x86)\MSBuild\Microsoft.Cpp\v4.0\v140"
)

cd VisualC
if %VS_MAJOR% GTR 10 (
    if %USERNAME%==appveyor (
        echo "Upgrading solution (appveyor)"
    	"%VSINSTALLDIR%\Common7\IDE\devenv.exe" SDL_mixer.sln /upgrade
    ) else (
        echo "Upgrading solution (azure)"
    	"C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\devenv.exe" SDL_mixer.sln /upgrade
    )
)
if errorlevel 1 exit 1

set "INCLUDE=%LIBRARY_INC%;%INCLUDE%;%LIBRARY_INC%\SDL2"
set "LIB=%LIBRARY_LIB%;%LIBRARY_BIN%;%LIB%"
set "AdditionalIncludeDirectories=%INCLUDE%"

echo "Build env configuration"
echo %INCLUDE%
echo %LIB%
echo %AdditionalIncludeDirectories%


msbuild /nologo SDL_mixer.sln "/p:Configuration=Release;Platform=%PLATFORM%;useenv=true"
if errorlevel 1 exit 1


move %PLATFORM%\Release\SDL2_mixer.lib %LIBRARY_LIB%
move %PLATFORM%\Release\SDL2_mixer.dll %LIBRARY_BIN%
move ..\SDL_mixer.h %LIBRARY_INC%\\SDL2
if errorlevel 1 exit 1
