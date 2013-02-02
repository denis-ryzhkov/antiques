filemsg, version 1.1 2007-11-28 (c) Denis Ryzhkov
http://denis.ryzhkov.org/?soft/filemsg

usage: filemsg filename

description:

filemsg waits for file specified by filename,
then immediately loads it,
and parses line by line.

each line is either text to output,
or command, beginning with "!" character.

all parameters of all commands have their default values,
so can be omitted.
any specified parameter value is stored as default
during filemsg execution time.

by default, text is outputted to "OK" message-boxes.
there are commands to switch output to unclosable window,
more suitable for reloadable daemons,
and configure it.

general commands:

command: set title
param-s: title(string)
default: !t filemsg

command: sleep
param-s: sleepTime(mls)
default: !s 1000

command: beep internal pc-speaker
param-s: beepFrequency(hertz) beepDuration(mls)
default: !b 800 200

command: reload file
param-s: none
usage  : !r

command: only once execute next lines (if onceLevel is greater than stored)
param-s: onceLevel(0-18446744073709551615) onceSkip(lines)
default: !o 0 1

unclosable window commands:

command: set initial position
param-s: initLeft initTop (pixel)
default: !i 100 100

command: show window
param-s: windowWidth windowHeight windowMargin (pixel)
default: !w 200 100 10

command: hide window
param-s: none
default: !h

command: set align
param-s: align(single character: l=left c=center r=right)
default: !a l

command: set font
param-s: fontSize(points) fontStyle(string with characters:
         b=bold i=italic u=underline s=strikeout OR n=normal)
         fontFace(string OR "any")
default: !f 14 n any

command: set color
param-s: textR textG textB backR backG backB (RGB 0-255)
default: !c 255 255 255 0 0 0

example 1:

hello world
!t my
message
!s
!b
!s 2000
!b 700 100
!b 1000

example 2:

!w 100
!f 24 bis courier new
!a c
!c 128 0 255
stat 7
!s 1000
!o 2007112812445901 4
!h
!b
turning to daemon that reloads modified file
don't forget to drag the window
!w
!r