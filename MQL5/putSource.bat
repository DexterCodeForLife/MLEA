choice /M "�Ƿ��Ƶ�MLEA\MQL5?��"
if ERRORLEVEL 2 goto end

xcopy /y /s /EXCLUDE:exclude.txt "D:\Program Files\MetaTrader 5\MQL5\Include" .\Include
xcopy /y /s /EXCLUDE:exclude.txt "D:\Program Files\MetaTrader 5\MQL5\Experts" .\Experts
xcopy /y /s /EXCLUDE:exclude.txt "D:\Program Files\MetaTrader 5\MQL5\Scripts" .\Scripts
xcopy /y /s /EXCLUDE:exclude.txt "D:\Program Files\MetaTrader 5\MQL5\Indicators" .\Indicators

: end
pause
