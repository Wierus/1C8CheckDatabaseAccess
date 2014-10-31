' VBS-скрипт «1C82CheckDatabaseAccess_parameterless.vbs» проверяет доступность базы данных на сервере приложений 1С 8.2 путем попытки подключения к базе.
' Скрипт предназначен для работы в качестве пользовательского сенсора PRTG.
' Результат выполнения возвращается в стандартный поток вывода в формате, требуемом для пользовательского сенсора PRTG.
' Код возврата соответствует формату для пользовательского сенсора PRTG.

' Версия скрипта: 0.1

' Подробное описание по использованию скрипта смотрите в файле «README.md».

' Имя или IP-адрес сервера приложений 1С
serverName = "server16"
' Имя базы данных на сервере приложений 1С
databaseName = "fmkupp"

On Error Resume Next

Set connector = CreateObject("V82.ComConnector")
connector.connect("Srvr=""" & serverName & """;Ref=""" & databaseName & """;")

If (InStr(Err.Description, "Идентификация пользователя не выполнена") <> 0) Then
	' "Анализируемая база данных доступна"
	WScript.Echo "0:Database available"
	' OK
	WScript.Quit 0
ElseIf (InStr(Err.Description, "Начало сеанса с информационной базой запрещено") <> 0) Then
	' "Анализируемая база данных заблокирована"
	WScript.Echo "1:Database blocked"
	' Warning
	WScript.Quit 1
ElseIf (InStr(Err.Description, "Информационная база не обнаружена") <> 0) Then
	' "Проверьте имя анализируемой базы данных"
	WScript.Echo "2:Database not found"
	' System Error
	WScript.Quit 2
ElseIf (InStr(Err.Description, "Сервер 1С:Предприятия не обнаружен") <> 0) Then
	' "Проверьте имя сервера приложений 1С"
	WScript.Echo "3:Server name cannot be resolved"
	' System Error
	WScript.Quit 2
ElseIf (InStr(Err.Description, "Ошибка при выполнении операции с информационной базой") <> 0) Then
	' "Проверьте имя или IP-адрес сервера приложений 1С"
	WScript.Echo "4:Server not found"
	' System Error
	WScript.Quit 2
ElseIf (InStr(Err.Description, "Несоответствие версий клиента и сервера 1С:Предприятия") <> 0) Then
	' "Проверьте версию зарегистрированного dll-файла ""comcntr.dll"""
	WScript.Echo "5:Server version incorrect"
	' Protocol Error
	WScript.Quit 3
ElseIf (InStr(Err.Description, "Требуется объект") <> 0) Then
	' "Не удается загрузить тип COM"
	WScript.Echo "8:COM error loading"
	' System Error
	WScript.Quit 2
Else
	' "Неизвестная ошибка"
	WScript.Echo "-1:Unknown error"
	' System Error
	WScript.Quit 2
End If
