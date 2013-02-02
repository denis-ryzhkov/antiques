@echo off
call "VCVARS32.BAT" > nul
rem call "C:\Program Files\Microsoft Visual Studio\VC98\Bin\VCVARS32.BAT" > nul
set src=sbr
cd ..
if exist %src%.exe del %src%.exe
cl _develop\%src%.cpp /O2 /Ot /Og /nologo /link user32.lib shell32.lib > _develop\cl.log
if exist %src%.obj del %src%.obj
if not exist %src%.exe goto bad
del _develop\cl.log
%src%.exe
goto exit
:bad
type _develop\cl.log | more
:exit
cd _develop
