@echo off
echo Building Booze Elroy...

REM Create a zip file of the game (excluding build artifacts)
powershell -Command "Compress-Archive -Path *.lua,sprites,moonshine -DestinationPath booze-elroy.zip -Force"

REM Concatenate love.exe with the zip file
REM Note: You'll need to have love.exe in your PATH or specify the full path
copy /b love.exe + booze-elroy.zip booze-elroy.exe

echo Done! booze-elroy.exe created.
echo.
echo Note: Make sure love.exe is in your PATH or modify this script to use the full path.


