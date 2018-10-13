REM - batch file to build 32&64 bit VS2010 VST/APP project and VS2005 RTAS project and zip the resulting binaries
REM - requires 7zip in C:\Program Files\7-Zip\7z.exe

echo "making IPlugGamma win distribution..."

echo "updating version numbers"
call python update_version.py

REM - START VST2/APP VS2010

if exist "%programfiles(x86)%" (goto 64-Bit) else (goto 32-Bit)

:32-Bit
echo 32-Bit O/S detected
call "C:\Program Files\Microsoft Visual Studio 10.0\VC\vcvarsall.bat"
goto END

:64-Bit
echo 64-Bit Host O/S detected
call "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat"
goto END
:END
REM - msbuild IPlugGamma.vcxproj /p:configuration=release /p:platform=win32
REM - msbuild IPlugGamma-app.vcxproj /p:configuration=release /p:platform=win32
REM - msbuild IPlugGamma.vcxproj /p:configuration=release /p:platform=x64
REM - msbuild IPlugGamma-app.vcxproj /p:configuration=release /p:platform=x64

msbuild IPlugGamma.sln /p:configuration=release /p:platform=win32
msbuild IPlugGamma.sln /p:configuration=release /p:platform=x64

REM - START RTAS VS2005

REM - this is bit in elegant, oh well
if exist "%programfiles(x86)%" (goto 64-Bit-rtas) else (goto 32-Bit-rtas)

:32-Bit-rtas
echo 32-Bit O/S detected
call "C:\Program Files\Microsoft Visual Studio 8\VC\vcvarsall.bat"
goto END-rtas

:64-Bit-rtas
echo 64-Bit Host O/S detected
call "C:\Program Files (x86)\Microsoft Visual Studio 8\VC\vcvarsall.bat"
goto END-rtas

:END-rtas

msbuild IPlugGamma-rtas.sln /p:configuration=release

REM - Make Installer (InnoSetup)

"C:\Program Files\Inno Setup 5\iscc" /cc ".\installer\IPlugGamma.iss"

REM - ZIP
REM - "C:\Program Files\7-Zip\7z.exe" a .\installer\IPlugGamma-win-32bit.zip .\build-win-app\win32\bin\IPlugGamma.exe .\build-win-vst2\win32\bin\IPlugGamma.dll .\build-win-rtas\bin\IPlugGamma.dpm .\build-win-rtas\bin\IPlugGamma.dpm.rsr .\installer\license.rtf .\installer\readmewin.rtf
REM - "C:\Program Files\7-Zip\7z.exe" a .\installer\IPlugGamma-win-64bit.zip .\build-win-app\x64\bin\IPlugGamma.exe .\build-win-vst2\x64\bin\IPlugGamma.dll .\installer\license.rtf .\installer\readmewin.rtf

echo off
pause