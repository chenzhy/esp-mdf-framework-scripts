@echo off
@chcp 65001
if defined MSYSTEM (
    echo This .bat file is for Windows CMD.EXE shell only. When using MSYS, run:
    echo   . ./export.sh.
    goto :eof
)

:: MDF SDK包名称 IDF SDK包名称 IDF 
set ESP_MDF_FOLDER_NAME=esp-mdf
set ESP_IDF_FOLDER_NAME=esp-idf
set ESP_ESPRESSIF_FOLDER_NAME=espressif
rem 当前执行文件名
set COMMAND_NAME=%~nx0

rem 当前完整路径含执行文件名
set COMMAND_PATH=%~f0 

rem 当前路径不含执行文件名
rem set MDF_PATH=%cd% = set MDF_PATH=%~dp0 + set MDF_PATH=%MDF_PATH:~0,-1%
set MDF_PATH=%cd%\%ESP_MDF_FOLDER_NAME%
set IDF_PATH=%MDF_PATH%\%ESP_IDF_FOLDER_NAME%
set IDF_TOOLS_PATH=%MDF_PATH%\%ESP_IDF_FOLDER_NAME%\%ESP_ESPRESSIF_FOLDER_NAME%

echo windows批处理文件名称:%COMMAND_NAME%
echo                  位置:%COMMAND_PATH%
echo         ESP-MDF SDK包名称:%ESP_MDF_FOLDER_NAME%
echo                  位置:%MDF_PATH%
echo         ESP-IDF SDK包名称包名称:%ESP_IDF_FOLDER_NAME%
echo                  位置:%IDF_PATH%
echo     ESP-IDF工具包名称:%ESP_ESPRESSIF_FOLDER_NAME%
echo                  位置:%IDF_TOOLS_PATH%

echo .
echo ---------------------Setting PATH----------------------
echo MDF SDK包                MDF_PATH: %MDF_PATH%
echo IDF SDK包                IDF_PATH: %IDF_PATH%
echo IDF IDE编译工具包  IDF_TOOLS_PATH: %IDF_TOOLS_PATH%
echo 官方有关于IDF_TOOLS_PATH的详细介绍

echo .
echo ---------------------install.bat----------------------
echo Installing ESP-IDF tools--下载ESP-IDF工具包---位置:%IDF_TOOLS_PATH%

rem echo 任意键继续
pause

python.exe %IDF_PATH%\tools\idf_tools.py install

if %errorlevel% neq 0 goto :end

echo Setting up Python environment
python.exe %IDF_PATH%\tools\idf_tools.py install-python-env

if %errorlevel% neq 0 goto :end

echo All done! You can now run:
echo export.bat
echo .
rem echo Adding ESP-IDF tools to PATH
echo ------------------------export.bat----------------------
echo -------------添加ESP-IDF工具包到系统环境变量中----------

rem echo 任意键继续
rem echo pause

set IDF_TOOLS_PY_PATH=%IDF_PATH%\tools\idf_tools.py
set IDF_TOOLS_JSON_PATH=%IDF_PATH%\tools\tools.json
set IDF_TOOLS_EXPORT_CMD=%IDF_PATH%\export.bat
set IDF_TOOLS_INSTALL_CMD=%IDF_PATH%\install.bat
set "OLD_PATH=%PATH%"
rem echo OLD_PATH:%OLD_PATH%

echo .
echo 设置ESP-IDF工具包路径
echo Setting IDF_PATH: %IDF_PATH%
echo IDF_TOOLS_PY_PATH:%IDF_PATH%\tools\idf_tools.py
echo IDF_TOOLS_JSON_PATH:%IDF_PATH%\tools\tools.json
echo IDF_TOOLS_EXPORT_CMD:%IDF_PATH%\export.bat
echo IDF_TOOLS_INSTALL_CMD:%IDF_PATH%\install.bat

echo .
echo 当前系统环境变量PATH
if not "%OLD_PATH%"=="" echo %OLD_PATH:;=&echo.    %

:: Export tool paths and environment variables.
:: It is possible to do this without a temporary file (running idf_tools.py from for /r command),
:: but that way it is impossible to get the exit code of idf_tools.py.
echo .
echo 开始导出ESP-IDF工具包路径和环境变量。
set "IDF_TOOLS_EXPORTS_FILE=%TEMP%\idf_export_vars.tmp"
rem echo IDF_TOOLS_EXPORTS_FILE:%IDF_TOOLS_EXPORTS_FILE%
python.exe %IDF_PATH%\tools\idf_tools.py export --format key-value >"%IDF_TOOLS_EXPORTS_FILE%"
if %errorlevel% neq 0 goto :end
echo 成功导出ESP-IDF工具包路径和环境变量。
echo IDF_TOOLS_EXPORTS_FILE:%IDF_TOOLS_EXPORTS_FILE%

for /f "usebackq tokens=1,2 eol=# delims==" %%a in ("%IDF_TOOLS_EXPORTS_FILE%") do (
      call set "%%a=%%b"
    )


:: This removes OLD_PATH substring from PATH, leaving only the paths which have been added,
:: and prints semicolon-delimited components of the path on separate lines
echo .
echo 成功添加ESP-IDF工具包路径到环境变量。
if not "%PATH%"=="" echo %PATH:;=&echo.    %

rem echo 系统环境变量OLD_PATH
rem if not "%OLD_PATH%"=="" echo %OLD_PATH:;=&echo.    %
call set PATH_ADDITIONS=%%PATH:%OLD_PATH%=%%
rem echo PATH_ADDITIONS:%PATH_ADDITIONS%

if "%PATH_ADDITIONS%"=="" call :print_nothing_added
echo .
echo ESP-IDF工具包路径
if not "%PATH_ADDITIONS%"=="" echo %PATH_ADDITIONS:;=&echo.    %

echo .
echo Checking if Python packages are up to date...
python.exe %IDF_PATH%\tools\check_python_dependencies.py

if %errorlevel% neq 0 goto :end
echo .
echo .
echo "Done! You can now compile ESP-MDF projects."
echo "Go to the project directory and run:"
echo ""
echo "  idf.py menuconfig--配置"
echo "  idf.py build--编译"
echo "  idf.py -p PORT flash--固件烧写"
echo "  idf.py -p PORT erase_flash--固件烧写"
echo "  idf.py clean--编译清除"
echo "  idf.py fullclean--编译全部清除"
echo "  idf.py monitor--串口打印"
echo "  idf.py app--仅构建应用程序"
echo "  idf.py app-flash--仅烧写应用程序"
echo ""

goto :end

:print_nothing_added
    echo No directories added to PATH:
    echo.
    echo %PATH%
    echo.
    goto :eof

:end

:: Clean up
if not "%IDF_TOOLS_EXPORTS_FILE%"=="" (
    del "%IDF_TOOLS_EXPORTS_FILE%" 1>nul 2>nul
)
set IDF_TOOLS_EXPORTS_FILE=

set IDF_TOOLS_PY_PATH=
set IDF_TOOLS_JSON_PATH=
set IDF_TOOLS_EXPORT_CMD=
set IDF_TOOLS_INSTALL_CMD=

set OLD_PATH=
set PATH_ADDITIONS=

echo --------------Windows cmd命令行模式下编译--------------
echo -------------ESP32 ESP-MDF开发框架搭建成功-------------
cmd
