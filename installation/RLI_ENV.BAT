@echo off
rem 
rem This command file installs/updates the Windows environment variables so that a reboot isn't necessary
rem If a drive letter (without the colon) is passed it will use that. Otherwise, C is assumed.
rem
rem Version 1.0 - May 22, 2018
rem Version 1.1 - Dec 05, 2019
rem
rem Must be run with Admin privileges. Check
echo Administrative permissions required. Checking permissions...
net session >nul 2>&1
if %errorlevel%==0 (
	echo echo Success: Administrative permissions confirmed.
	) else (
	echo Failure: Please run as Administrator.
	exit
	)
set DRIVESPEC=%1
if [%DRIVESPEC%] == [] set DRIVESPEC=C
setx RLI_HOME %DRIVESPEC%:\radiantone\vds /M
setx RLI_APPSERVER_HOME %DRIVESPEC%:\radiantone\vds\appserver\glassfish /M
setx RLI_JAVA_HOME %DRIVESPEC%:\radiantone\vds\jdk\jre /M
