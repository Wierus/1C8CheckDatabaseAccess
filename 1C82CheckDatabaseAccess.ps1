# PowerShell-скрипт «1C82CheckDatabaseAccess.ps1» проверяет доступность базы данных на сервере приложений 1С 8.2 путем попытки подключения к базе.
# Скрипт предназначен для работы в качестве пользовательского сенсора PRTG.
# Результат выполнения возвращается в стандартный поток вывода в формате, требуемом для пользовательского сенсора PRTG.
# Код возврата соответствует формату для пользовательского сенсора PRTG.

# Версия скрипта: 0.1.1

# Подробное описание по использованию скрипта смотрите в файле «README.md».

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
        Write-Host "0:Database available"
        # OK
        exit 0
    }
    elseif ($_.ToString().IndexOf("Начало сеанса с информационной базой запрещено") -ne -1) {
        Write-Verbose "Анализируемая база данных заблокирована"
        Write-Host "1:Database blocked"
        # Warning
        exit 1
    }
    elseif ($_.ToString().IndexOf("Информационная база не обнаружена") -ne -1) {
        Write-Verbose "Проверьте имя анализируемой базы данных"
        Write-Host "2:Database not found"
        # System Error
        exit 2
    }
    elseif ($_.ToString().IndexOf("Сервер 1С:Предприятия не обнаружен") -ne -1) {
        Write-Verbose "Проверьте имя сервера приложений 1С"
        Write-Host "3:Server name cannot be resolved"
        # System Error
        exit 2
    }
    elseif ($_.ToString().IndexOf("Ошибка при выполнении операции с информационной базой") -ne -1) {
        Write-Verbose "Проверьте имя или IP-адрес сервера приложений 1С"
        Write-Host "4:Server not found"
        # System Error
        exit 2
    }
    elseif ($_.ToString().IndexOf("Несоответствие версий клиента и сервера 1С:Предприятия") -ne -1) {
        Write-Verbose "Проверьте версию зарегистрированного dll-файла `"comcntr.dll`""
        Write-Host "5:Server version incorrect"
        # Protocol Error
        exit 3
    }
    elseif ($_.ToString().IndexOf("Не удалось получить фабрику класса COM для компонента") -ne -1) {
        if ($_.ToString().IndexOf("CLSID {00000000-0000-0000-0000-000000000000}") -eq -1) {
            Write-Verbose "Не совпадают разрядности PowerShell и зарегистрированного dll-файла `"comcntr.dll`""
            Write-Verbose "Запустите данный скрипт из 32-битной версии PowerShell"
            Write-Host "6:COM bit width incorrect"
            # System Error
            exit 2
        }
        else {
            Write-Verbose "Не зарегистрирован dll-файл `"comcntr.dll`""
            Write-Verbose "Для регистрации выполните команду `"regsvr32.exe comcntr.dll`""
            Write-Host "7:COM class unregistered"
            # System Error
            exit 2
        }
    }
    elseif ($_.ToString().IndexOf("Не удается загрузить тип COM") -ne -1) {
        Write-Verbose "Не удается загрузить тип COM"
        Write-Host "8:COM error loading"
        # System Error
        exit 2
    }
    else {
        Write-Verbose "Неизвестная ошибка"
        Write-Host "-1:Unknown error"
        # System Error
        exit 2
    }
}
