@echo off
@call VCVARS32.BAT
@cl.exe xmp.cpp /nologo /O1 /Og /Ot /GA /link advapi32.lib user32.lib gdi32.lib > cl.log
@type cl.log
@if exist xmp.obj del xmp.obj
