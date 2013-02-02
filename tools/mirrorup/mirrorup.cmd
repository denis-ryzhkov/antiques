@echo off
for /f "eol=# delims=" %%n in ( mirrorup.txt ) do (
 echo %%n
 mirrorup.exe "C:\%%n" "U:\%%n" >>mirrorup.log
)
