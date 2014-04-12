' ===================================================================
' Cancelar-Impressao.vbs - Script para limpar trabalhos de impressão
' Autor: Roldão Rego Jr <http://roldaojr.github.io>
' Versão: 1.2
' 
' Distribuído Gratuitamente
'
' Este trabalho está licenciado sob uma Licença Creative Commons
' Atribuição 4.0 Internacional. Para ver uma cópia desta licença,
' visite http://creativecommons.org/licenses/by/4.0/.
'
' Este script funciona em Windows 2000/XP/2003/Vista/7/8 e deve
' ser executado como administrador.
' Uso:
' 1. Desligue a impressora
' 2. Execute o script
' 3. Ligue a impressora
' 4. Pronto! Sua impressora está pronta para imprimir
' ===================================================================
'
On Error Resume Next
If MsgBox("Este programa irá cancelar TODOS os trabalhos de impressão de TODAS as impressoras. Deseja continuar.", vbYesNo+vbQuestion, "Cancelar Impressão") = vbNo then WScript.Quit
MsgBox "Desligue a impressora", 48, "Cancelar Impressão"
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
MsgBox "Ligue novamente a impressora." + vbCrLf + "Pronto! Sua impressora está pronta para imprimir.", vbInformation, "Cancelar Impressão"