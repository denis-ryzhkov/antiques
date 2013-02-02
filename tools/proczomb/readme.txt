proczomb, version 1.3 2007-08-16--2008-01-14 (c) Denis Ryzhkov
http://denis.ryzhkov.org/?soft/proczomb

usage: proczomb 0.001 60 1000 "C:\Program Files\App\App.exe" AppParam1 ... AppParamN

means: proczomb starts "C:\Program Files\App\App.exe" with AppParams
and if its CPU Usage is 0.001% or less for 60 periods each 1000 mls
then proczomb restarts the process.

can be used to watch bots and restart hanged ones automatically.
source code provided.
