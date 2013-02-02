@if exist ..\*.class del ..\*.class
@err2out d:\app\java\bin\javac -d .. Plotter.java | more