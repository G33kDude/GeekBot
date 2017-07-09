#NoEnv
#Persistent
#NoTrayIcon
#SingleInstance, Off
SetWorkingDir, %A_LineFile%\..
SetBatchLines, -1
#Include %A_LineFile%\..\lib\
#Include RemoteObj.ahk\RemoteObj.ahk
#Include Socket.ahk\Socket.ahk
#Include AutoHotkey-JSON\Jxon.ahk
#Include Utils.ahk

Json = %1%
for Var, Value in Jxon_Load(Json)
	%Var% := Value

Settings := Ini_Read("Settings.ini")
if (Settings.Bitly.login)
	Shorten(Settings.Bitly.login, Settings.Bitly.apiKey)

global IRC := new RemoteObjClient(["127.0.0.1", Settings.Plugins.BindPort])

Chat(Channel, Text)
{
	IRC.Chat(Channel, Text)
}