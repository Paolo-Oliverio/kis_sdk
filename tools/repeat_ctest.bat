@echo off
:: repeat_ctest.bat - Windows wrapper to run the Python repeat_ctest script
:: Usage: repeat_ctest.bat 100 "High steal contention"
::   or: repeat_ctest.bat --repeat 100 --regex "High steal contention"
:: If Python isn't on PATH, use full path to python launcher (py).

:: Pass all arguments through to the Python script
@py "%~dp0repeat_ctest.py" %*
