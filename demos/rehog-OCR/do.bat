@echo off
set src=rehog
set err=cl.err
call d:\app\msvc\bin\vcvars32.bat
if exist %err% del %err%
cl %src%.cpp /nologo > %err%
if errorlevel 1 goto skip_exec
del %err%
%src% input.bmp
goto skip_type_err
:skip_exec
type %err%
:skip_type_err
if exist %src%.obj del %src%.obj
