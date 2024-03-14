@echo off

#SET URL-DB=192.168.1.51
#SET PORT-DB=5432
#SET DB-NAME=postgres-cargo
#SET POSTGRES-USER=postgres
#SET POSTGRES-PASSWORD=password

SET URL-DB=localhost
SET PORT-DB=5432
SET DB-NAME=postgres-cargo
SET POSTGRES-USER=postgres
SET POSTGRES-PASSWORD=postgres


SET JAVA_HOME=D:\Java\x64\jdk19
SET JAVA_EXE=%JAVA_HOME%\bin\java.exe
%JAVA_EXE% -jar ./target/generator-0.0.1-SNAPSHOT.jar
REM -Dfile.encoding=WIN-1251

@rem pause