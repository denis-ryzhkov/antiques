@echo off
call vcvars32.bat
cl InsOFF.cpp /nologo /O1 /link user32.lib > cl.log
type cl.log
if exist InsOFF.obj del InsOFF.obj