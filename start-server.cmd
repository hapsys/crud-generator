@echo off

SET JAVA_HOME=D:\Java\x64\jdk19
SET JAVA_EXE=%JAVA_HOME%\bin\java.exe
%JAVA_EXE% -jar ./target/generator-0.0.1-SNAPSHOT.jar  -Dspring.profiles.active=default

@rem pause