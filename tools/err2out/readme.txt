err2out is stdERR TO stdOUT redirector, version 2.2
Copyright (c) 2002-2003 Denis Ryzhkov ( Creon )
http://creon.cjb.net/?soft/err2out

Examples:
err2out "C:\Program Files\jdk\bin\javac" Some.java | more
err2out "C:\Program Files\jdk\bin\javac" Some.java > err.txt
err2out "C:\Program Files\jdk\bin\javac" Some.java >> err.txt
