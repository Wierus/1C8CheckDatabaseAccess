' VBS-������ �1C82CheckDatabaseAccess_parameterless.vbs� ��������� ����������� ���� ������ �� ������� ���������� 1� 8.2 ����� ������� ����������� � ����.
' ������ ������������ ��� ������ � �������� ����������������� ������� PRTG.
' ��������� ���������� ������������ � ����������� ����� ������ � �������, ��������� ��� ����������������� ������� PRTG.
' ��� �������� ������������� ������� ��� ����������������� ������� PRTG.

' ������ �������: 0.1

' ��������� �������� �� ������������� ������� �������� � ����� �README.md�.

' ��� ��� IP-����� ������� ���������� 1�
serverName = "server16"
' ��� ���� ������ �� ������� ���������� 1�
databaseName = "fmkupp"

On Error Resume Next

Set connector = CreateObject("V82.ComConnector")
connector.connect("Srvr=""" & serverName & """;Ref=""" & databaseName & """;")

If (InStr(Err.Description, "������������� ������������ �� ���������") <> 0) Then
	' "������������� ���� ������ ��������"
	WScript.Echo "0:Database available"
	' OK
	WScript.Quit 0
ElseIf (InStr(Err.Description, "������ ������ � �������������� ����� ���������") <> 0) Then
	' "������������� ���� ������ �������������"
	WScript.Echo "1:Database blocked"
	' Warning
	WScript.Quit 1
ElseIf (InStr(Err.Description, "�������������� ���� �� ����������") <> 0) Then
	' "��������� ��� ������������� ���� ������"
	WScript.Echo "2:Database not found"
	' System Error
	WScript.Quit 2
ElseIf (InStr(Err.Description, "������ 1�:����������� �� ���������") <> 0) Then
	' "��������� ��� ������� ���������� 1�"
	WScript.Echo "3:Server name cannot be resolved"
	' System Error
	WScript.Quit 2
ElseIf (InStr(Err.Description, "������ ��� ���������� �������� � �������������� �����") <> 0) Then
	' "��������� ��� ��� IP-����� ������� ���������� 1�"
	WScript.Echo "4:Server not found"
	' System Error
	WScript.Quit 2
ElseIf (InStr(Err.Description, "�������������� ������ ������� � ������� 1�:�����������") <> 0) Then
	' "��������� ������ ������������������� dll-����� ""comcntr.dll"""
	WScript.Echo "5:Server version incorrect"
	' Protocol Error
	WScript.Quit 3
ElseIf (InStr(Err.Description, "��������� ������") <> 0) Then
	' "�� ������� ��������� ��� COM"
	WScript.Echo "8:COM error loading"
	' System Error
	WScript.Quit 2
Else
	' "����������� ������"
	WScript.Echo "-1:Unknown error"
	' System Error
	WScript.Quit 2
End If
