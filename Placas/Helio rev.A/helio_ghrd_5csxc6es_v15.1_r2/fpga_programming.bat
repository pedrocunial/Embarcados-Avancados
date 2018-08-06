@echo off
 @ REM ######################################
 @ REM # Variable to ignore <CR> in DOS
 @ REM # line endings
 @ set SHELLOPTS=igncr
 
@ REM ######################################
 @ REM # Variable to ignore mixed paths
 @ REM # i.e. G:/$SOPC_KIT_NIOS2/bin
 @ set CYGWIN=nodosfilewarning
 

@set QUARTUS_BIN=%QUARTUS_ROOTDIR%\\bin
 @if exist %QUARTUS_BIN%\\quartus_pgm.exe (goto DownLoad)
 
@set QUARTUS_BIN=%QUARTUS_ROOTDIR%\\bin64
 @if exist %QUARTUS_BIN%\\quartus_pgm.exe (goto DownLoad)

 
:: Prepare for future use (if exes are in bin32)
 @set QUARTUS_BIN=%QUARTUS_ROOTDIR%\\bin32
 
:DownLoad
 set project.sof=%~dp0\output_files\\helio_ghrd_top.sof
 set project.jic=%~dp0\output_files\\helio_ghrd_top.jic
 ::Please select Helio Revision 1.3 or 1.4
 set HELIO_REV=1.3
 if "%HELIO_REV%"=="1.4" (
  :: Helio After rev1.4
  echo Helio Rev.1.4
  @set device_sfl.sof=%QUARTUS_ROOTDIR%\\common\\devinfo\\programmer\\sfl_enhanced_01_02D120DD.sof
 ) else (
  :: Helio Before rev1.3
  echo Helio Rev.1.3
  @set device_sfl.sof=%QUARTUS_ROOTDIR%\\common\\devinfo\\programmer\\sfl_enhanced_01_02d020dd.sof
 )

 set DEVICE_POSITION=2
 goto main
 
:main
 echo **********************************
 echo  Please make sure both SoC and FPGA are chained in JTAG
 echo  Plesase choose your operation
 echo    "1" for programming .sof to FPGA.
 echo    "2" for converting .sof to .jic 
 echo    "3" for programming .jic to EPCQ.
 echo    "4" for erasing .jic from EPCQ.
 echo    "5" for Exit.
 echo **********************************
 choice /C 12345 /M "Please enter your choise:" 
if errorlevel 5 goto end
if errorlevel 4 goto d 
if errorlevel 3 goto c  
if errorlevel 2 goto b  
if errorlevel 1 goto a 


:a
 echo ===========================================================
 echo "Progrming .sof to FPGA"
 echo ===========================================================
 %QUARTUS_BIN%\\quartus_pgm.exe -m jtag -c 1 -o "p;%project.sof%@%DEVICE_POSITION%"
 @ set SOPC_BUILDER_PATH=%SOPC_KIT_NIOS2%+%SOPC_BUILDER_PATH%
 goto end
 

:b 
echo ===========================================================
 echo "Convert .sof to .jic"
 echo ===========================================================
 if "%HELIO_REV%"=="1.4" (
  :: Helio After rev1.4
  %QUARTUS_BIN%\\quartus_cpf -c -d epcq256 -s 5csxfc5c6u23c7 %project.sof% %project.jic%
 ) else (
  :: Helio Before rev1.3
  %QUARTUS_BIN%\\quartus_cpf -c -d epcq256 -s 5csxfc6c6es %project.sof% %project.jic%
 )
 goto end
 
:c
 echo ===========================================================
 echo "Programming EPCQ with .jic"
 echo ===========================================================
 %QUARTUS_BIN%\\quartus_pgm.exe -m jtag -c 1 -o "p;%device_sfl.sof%@%DEVICE_POSITION%"
 %QUARTUS_BIN%\\quartus_pgm.exe -m jtag -c 1 -o "p;%project.jic%@%DEVICE_POSITION%"
 goto end
 
:d
 echo ===========================================================
 echo "Erasing EPCQ with .jic"
 echo ===========================================================
 %QUARTUS_BIN%\\quartus_pgm.exe -m jtag -c 1 -o "p;%device_sfl.sof%@%DEVICE_POSITION%"
 %QUARTUS_BIN%\\quartus_pgm.exe -m jtag -c 1 -o "r;%project.jic%@%DEVICE_POSITION%"
 goto end
 
:end
 echo Finish
 pause
