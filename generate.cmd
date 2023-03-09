@echo off

SET JAVA_HOME=D:\Java\x64\jdk19
SET JAVA_EXE=%JAVA_HOME%\bin\java.exe
%JAVA_EXE% -jar ./target/generator-0.0.1-SNAPSHOT.jar %1 %2 %3 %4 %5 %6 %7 %8 %9

@rem pause