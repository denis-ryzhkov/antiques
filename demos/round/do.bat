@echo off
call VCVARS32.BAT
cl.exe round.cpp /nologo /O1 /Og /Ot /GA /link advapi32.lib user32.lib gdi32.lib > cl.log
if errorlevel 1 goto skip_exec
round
:skip_exec
type cl.log
if exist round.obj del round.obj
if exist cl.log del cl.log