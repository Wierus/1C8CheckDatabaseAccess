# 1C8CheckDatabaseAccess

## Описание скриптов

Скрипты проверяют доступность базы данных на сервере приложений 1С 8.2 путем попытки подключения к базе и анализа сообщения об ошибке.

Скрипты предназначен для работы в качестве пользовательского сенсора PRTG.

Результат выполнения возвращается в стандартный поток вывода в формате, требуемом для пользовательского сенсора PRTG.

Код возврата соответствует формату для пользовательского сенсора PRTG.

## Использование скриптов

Есть 2 варианта использования скриптов: с параметрами и без параметров (точнее с параметрами жестко указанными в коде).

В общем случае следует использовать скрипт с параметрами, и параметры указывать в свойствах сенсора PRTG. Так, при изменении значений параметров (имени сервера или имени базы данных) не будет необходимости изменять код скрипта, а нужно будет всего лишь изменить свойства сенсора. Но, если по каким-либо причинам использование скрипта с параметрами не представляется возможным, то для такого случая предусмотрены скрипты без параметров (со словом «parameterless» в названии). При их использовании в коде выбранного скрипта требуется заранее указать имя сервера и имя базы данных, и затем устанавливать такой скрипт для сенсора PRTG без параметров.

## Типы скриптов

|                   | С параметрами               | Без параметров                            |
|-------------------|-----------------------------|-------------------------------------------|
| PowerShell script | 1C82CheckDatabaseAccess.ps1 | 1C82CheckDatabaseAccess_parameterless.ps1 |
| VBS script        | Отсутствует                 | 1C82CheckDatabaseAccess_parameterless.vbs |

### Параметры запуска скрипта «1C82CheckDatabaseAccess.ps1»

#### Порядок параметров

```
.\1C82CheckDatabaseAccess.ps1 -serverName <имя_сервера> -databaseName <имя_базы_данных> [-Verbose]
```
или
```
.\1C82CheckDatabaseAccess.ps1 <имя_сервера> <имя_базы_данных> [-Verbose]
```

#### Описание параметров

```
-serverName <имя_сервера>
    Имя или IP-адрес сервера приложений 1С
-databaseName <имя_базы_данных>
    Имя базы данных на сервере приложений 1С
-Verbose
    Включение вывода подробных сообщений об ошибках (опционально, использовать только при отладке)
```

## Настройка окружения для работы скриптов

### Регистрация DLL-файла «comcntr.dll»

Во время работы скрипта подключение к серверу выполняется через COM-соединение, для этого в системе заранее должен быть зарегистрирован DLL-файл «comcntr.dll» с помощью команды:
```
regsvr32.exe comcntr.dll
```
Версия «comcntr.dll» должна соответствовать версии сервера приложений 1С 8.2.

DLL-файл «comcntr.dll» зависит от следующих файлов (в порядке зависимостей): «stl82.dll», «core82.dll», «icuin46.dll», «icuuc46.dll», «icudt46.dll». Перечисленные файлы должны находится в каталоге с «comcntr.dll», регистрировать их не требуется.

При появлении ошибки при регистрации DLL-файла с помощью «regsvr32» попробуйте устранить ее одним из следующих способов:
- повторно запустить «regsvr32» в командной строке с повышенными привилегиями;
- использовать 32-разрядную версию «regsvr32» для регистрации 32-разрядной библиотеки в 64-разрядной версии Windows, которая расположена в «%systemroot%\SysWoW64\regsvr32.exe».

Подробнее о «regsvr32» изложено в статье «Использование средства Regsvr32 и устранение неполадок, связанных с выводимыми им сообщениями об ошибках»: http://support.microsoft.com/kb/249873/ru

### Настройка окружения для работы Powershell скрипта

#### 1. Установка Powershell 3.0

Для корректной работы скрипта требуется установить в системе Powershell 3.0, который содержится в Windows Management Framework 3.0: http://www.microsoft.com/en-us/download/details.aspx?id=34595

Узнать текущую установленную версию PowerShell можно с помощью команды:
```
$Host.Version.ToString()
```

#### 2. Настройка политики выполнения для PowerShell-скрипта

Для запуска скрипта требуется установить политику выполнения «RemoteSigned» для пользователя, от имени которого будет выполняться скрипт. Установить такую политику можно следующей командой:
```
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```
Определить текущую политику выполнения в текущей сессии можно с помощью команды:
```
Get-ExecutionPolicy
```

## Возможные результаты выполнения скриптов

| Возвращаемое значение в стандартный поток вывода | Код возврата     | Скрипты, поддерживающие данный результат |
|--------------------------------------------------|------------------|------------------------------------------|
| 0:Database available                             | 0 OK             | PowerShell script, VBS script            |
| 1:Database blocked                               | 1 Warning        | PowerShell script, VBS script            |
| 2:Database not found                             | 2 System error   | PowerShell script, VBS script            |
| 3:Server name cannot be resolved                 | 2 System error   | PowerShell script, VBS script            |
| 4:Server not found                               | 2 System error   | PowerShell script, VBS script            |
| 5:Server version incorrect                       | 3 Protocol error | PowerShell script, VBS script            |
| 6:COM bit width incorrect                        | 2 System error   | PowerShell script                        |
| 7:COM class unregistered                         | 2 System error   | PowerShell script                        |
| 8:COM error loading                              | 2 System error   | PowerShell script, VBS script            |
| -1:Unknown error                                 | 2 System error   | PowerShell script, VBS script            |

## Возможные коды ошибок, возвращаемые PRTG при работе EXE-сенсоров

(полный список кодов ошибок: http://kb.paessler.com/en/topic/32813-what-does-error-code-pexxx-mean)

| PExxx | Сообщение                                     | Контекст                     |
|-------|-----------------------------------------------|------------------------------|
| 008   | File not found                                | WMI file sensor, EXE sensors |
| 018   | Timeout                                       | EXE sensors                  |
| 022   | System Error                                  | EXE sensors                  |
| 023   | Protocol Error                                | EXE sensors                  |
| 024   | Content Error                                 | EXE sensors                  |
| 035   | Timeout caused by wait for mutex              | Mutex for EXE Sensors        |
| 036   | Could not create mutex                        | Mutex for EXE Sensors        |
| 087   | External EXE/Script did not return a response | EXE Sensors                  |
| 092   | Please specify a username and password in the device settings (Credentials for Windows Systems) | EXE Sensors |
| 121   | Timeout caused by wait for mutex. Consider distributing your VMware sensors across several probes! | Mutex for ESX-EXE Sensors |
| 132   | The output of the exe file does not match the expected format | EXE sensors |
