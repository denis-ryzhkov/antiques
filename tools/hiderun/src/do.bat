@echo off
call vcvars32.bat
cl hiderun.cpp /nologo /O2 > cl.log
type cl.log
if exist hiderun.obj del hiderun.obj