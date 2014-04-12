' ===================================================================
' Cancelar-Impressao.vbs - Script para limpar trabalhos de impress�o
' Autor: Rold�o Rego Jr <http://roldaojr.github.io>
' Vers�o: 1.2
' 
' Distribu�do Gratuitamente
'
' Este trabalho est� licenciado sob uma Licen�a Creative Commons
' Atribui��o 4.0 Internacional. Para ver uma c�pia desta licen�a,
' visite http://creativecommons.org/licenses/by/4.0/.
'
' Este script funciona em Windows 2000/XP/2003/Vista/7/8 e deve
' ser executado como administrador.
' Uso:
' 1. Desligue a impressora
' 2. Execute o script
' 3. Ligue a impressora
' 4. Pronto! Sua impressora est� pronta para imprimir
' ===================================================================
'
On Error Resume Next
If MsgBox("Este programa ir� cancelar TODOS os trabalhos de impress�o de TODAS as impressoras. Deseja continuar.", vbYesNo+vbQuestion, "Cancelar Impress�o") = vbNo then WScript.Quit
MsgBox "Desligue a impressora", 48, "Cancelar Impress�o"
Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
Set colServiceList = objWMIService.ExecQuery("select * from Win32_Service where Name='spooler'")
For each objService in colServiceList
errReturn = objService.StopService()
Next
Set Wshell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
fso.DeleteFile(Wshell.ExpandEnvironmentStrings("%WinDir%") & "\system32\spool\PRINTERS\*")
Set colServiceList = objWMIService.ExecQuery("select * from Win32_Service where Name='spooler'")
For each objService in colServiceList
errReturn = objService.StartService()
Next
MsgBox "Ligue novamente a impressora." + vbCrLf + "Pronto! Sua impressora est� pronta para imprimir.", vbInformation, "Cancelar Impress�o"