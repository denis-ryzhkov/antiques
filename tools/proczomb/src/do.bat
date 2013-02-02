@echo off
call "C:\Program Files\Microsoft Visual Studio\VC98\Bin\VCVARS32.BAT"
set fn=proczomb
cl %fn%.cpp /nologo /O2 /link user32.lib | more
if exist %fn%.obj del %fn%.obj
