@echo off
perl2exe -gui -opt -icon=YesNoTester.ico -o=..\YesNoTester.exe YesNoTester.pl
cd ..
start YesNoTester
