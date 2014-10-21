# PowerShell-скрипт «1C82CheckDatabaseAccess.ps1» проверяет доступность базы данных на сервере приложений 1С 8.2 путем попытки подключения к базе.
# Скрипт предназначен для работы в качестве пользовательского сенсора PRTG.
# Результат выполнения возвращается в стандартный поток вывода в формате, требуемом для пользовательского сенсора PRTG.
# Код возврата соответствует формату для пользовательского сенсора PRTG.

# Версия скрипта: 0.1

# Подробное описание по использованию скрипта смотрите в файле «1C82CheckDatabaseAccess.readme.txt».

[CmdletBinding()]
Param (
    # Имя или IP-адрес сервера приложений 1С
    [string]$serverName,
    # Имя базы данных на сервере приложений 1С
    [string]$databaseName
)

try {
    # Создать COM-объект для подключения к серверу приложений 1С
    $connector = New-Object -ComObject "V82.ComConnector"
    # Подключиться к серверу приложений 1С с указанными параметрами
    $connection = $connector.Connect("Srvr=`"$serverName`";Ref=`"$databaseName`";")
}
catch {
    # Вывести в консоль тип ошибки (для подробного вывода)
    Write-Verbose $_.GetType()
    # Вывести в консоль текст ошибки (для подробного вывода)
    Write-Verbose $_.ToString()
    if ($_.ToString().IndexOf("Идентификация пользователя не выполнена") -ne -1) {
        Write-Verbose "Анализируемая база данных доступна"
        Write-Host "0:DatabaseAvailable"
        # OK
        exit 0
    }
    elseif ($_.ToString().IndexOf("Начало сеанса с информационной базой запрещено") -ne -1) {
        Write-Verbose "Анализируемая база данных заблокирована"
        Write-Host "1:DatabaseBlocked"
        # Warning
        exit 1
    }
    elseif ($_.ToString().IndexOf("Информационная база не обнаружена") -ne -1) {
        Write-Verbose "Проверьте имя анализируемой базы данных"
        Write-Host "2:DatabaseNotFound"
        # System Error
        exit 2
    }
    elseif ($_.ToString().IndexOf("Сервер 1С:Предприятия не обнаружен") -ne -1) {
        Write-Verbose "Проверьте имя или IP-адрес сервера приложений 1С"
        Write-Host "3:ServerNotFound"
        # System Error
        exit 2
    }
    elseif ($_.ToString().IndexOf("Несоответствие версий клиента и сервера 1С:Предприятия") -ne -1) {
        Write-Verbose "Проверьте версию зарегистрированного dll-файла `"comcntr.dll`""
        Write-Host "4:ServerVersionIncorrect"
        # Protocol Error
        exit 3
    }
    elseif ($_.ToString().IndexOf("Не удалось получить фабрику класса COM для компонента") -ne -1) {
        if ($_.ToString().IndexOf("CLSID {00000000-0000-0000-0000-000000000000}") -eq -1) {
            Write-Verbose "Не совпадают разрядности PowerShell и зарегистрированного dll-файла `"comcntr.dll`""
            Write-Verbose "Запустите данный скрипт из 32-битной версии PowerShell"
            Write-Host "5:COMBitWidthIncorrect"
            # System Error
            exit 2
        }
        else {
            Write-Verbose "Не зарегистрирован dll-файл `"comcntr.dll`""
            Write-Verbose "Для регистрации выполните команду `"regsvr32.exe comcntr.dll`""
            Write-Host "6:COMClassUnregistered"
            # System Error
            exit 2
        }
    }
    elseif ($_.ToString().IndexOf("Не удается загрузить тип COM") -ne -1) {
        Write-Verbose "Не удается загрузить тип COM"
        Write-Host "7:COMErrorLoading"
        # System Error
        exit 2
    }
    else {
        Write-Verbose "Неизвестная ошибка"
        Write-Host "8:UnknownError"
        # System Error
        exit 2
    }
}
