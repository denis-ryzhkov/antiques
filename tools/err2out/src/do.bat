@echo off
call "VCVARS32.BAT" > nul
rem call "C:\Program Files\Microsoft Visual Studio\VC98\Bin\VCVARS32.BAT" > nul
set src=err2out
cl %src%.cpp /O2 /nologo | more
if exist %src%.obj del %src%.obj