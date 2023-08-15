@echo off

set logfile=%~dpn0%.log
echo.>%logfile%

set odmv2schema=..\schema\ODM.xsd
set example_folder=..\examples

for /F "eol=; tokens=1 delims=" %%i IN ('dir /b /s %example_folder%\*.xml ^| findstr /v "1_3_2"') do @call :ValidateFile %%i 
goto:EOF

:ValidateFile

  set /a counter=counter+1 > nul
  echo %counter% *** %1
  echo *** %1 >> %logfile%

  cmd /c ant -quiet -Dcdisc.odm.file.v20=%1 -Dcdisc.odm.v20.schema.file=%odmv2schema% >> %logfile% 2>>&1

goto :EOF

