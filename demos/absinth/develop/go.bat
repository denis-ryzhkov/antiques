@echo off
call VCVARS32.BAT
rc absinth.rc
cvtres /nologo /machine:IX86 /out:rc.obj absinth.res
del absinth.res
cl absinth.cpp rc.obj /nologo /O2 /Fe../absinth/absinth.exe /link user32.lib gdi32.lib > cl.log
if errorlevel 1 goto skip_exec
upx -9 ../absinth/absinth.exe
start ../absinth/absinth
:skip_exec
type cl.log
if exist *.obj del *.obj
if exist cl.log del cl.log
