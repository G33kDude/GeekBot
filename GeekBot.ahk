#NoEnv
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

#Include lib\
#Include AutoHotkey-JSON\Jxon.ahk
#Include Socket.ahk\Socket.ahk
#Include MyRC\MyRC.ahk
#Include RemoteObj.ahk\RemoteObj.ahk
#Include Utils.ahk

SettingsFile := "Settings.ini"

if !(Settings := Ini_Read(SettingsFile))
{
	FileCopy, DefaultSettings.ini, %SettingsFile%, 1
	MsgBox, There was a problem reading your Settings.ini file. Please fill in the newly generated Settings.ini
	ExitApp
}

if (Settings.Bitly.login)
	Shorten(Settings.Bitly.login, Settings.Bitly.apiKey)

Server := Settings.Server
Nicks := StrSplit(Server.Nicks, ",", " `t")

IRC := new Bot(Settings.Trigger, Settings.Greetings, Settings.Aliases, Nicks, Settings.ShowHex)
IRC.Connect(Server.Addr, Server.Port, Nicks[1], Server.User, Server.Nick, Server.Pass)
IRC.SendJOIN(StrSplit(Server.Channels, ",", " `t")*)

PluginAPI := new RemoteObj(IRC, [Settings.Plugins.BindAddr, Settings.Plugins.BindPort])
return

class Bot extends IRC
{
	__New(Trigger, Greetings, Aliases, DefaultNicks, ShowHex=false)
	{
		this.Trigger := Trigger
		this.Greetings := Greetings
		this.Aliases := Aliases
		this.DefaultNicks := DefaultNicks
		return base.__New(ShowHex)
	}
	
	onCTCP(Nick,User,Host,Cmd,Params,Msg,Data)
	{
		if (Cmd != "ACTION")
			this.SendCTCPReply(Nick, Cmd, "Zark off!")
	}
	
	onPRIVMSG(Nick,User,Host,Cmd,Params,Msg,Data)
	{
		Channel := Params[1]
		
		if (Nick == this.Nick)
			return
		
		GreetEx := "i)^((?:" this.Greetings
		. "),?)\s.*" RegExEscape(this.Nick)
		. "(?P<Punct>[!?.]*).*$"
		
		; Greetings
		if (RegExMatch(Msg, GreetEx, Match))
		{
			this.Chat(Channel, Match1 " " Nick . MatchPunct)
			return
		}
		
		; If it is being sent to us
		if (Channel == this.Nick)
		{
			Channel := Nick
			if (InStr(Msg, this.Trigger) != 1) ; If message doesn't start with trigger
				Msg := this.Trigger . Msg
		}
		
		; If it is a command
		if (RegexMatch(Msg, "^" this.Trigger "\K(\S+)(?:\s+(.+?))?\s*$", Match))
		{
			Match1 := RegExReplace(Match1, "i)[^a-z0-9]")
			File := "plugins\" Match1 ".ahk"
			Param := Jxon_Dump({"PRIVMSG":{"Nick":Nick,"User":User,"Host":Host
			,"Cmd":Cmd,"Params":Params,"Msg":Msg,"Data":Data}
			,"Plugin":{"Name":Match1,"Param":Match2,"Params":[Match2],"Match":Match}
			,"Channel":Channel})
			
			if !FileExist(File)
				File := "plugins\Default.ahk"
			
			Run(A_AhkPath, File, Param)
		}
	}
	
	OnDisconnect(Socket)
	{
		ChannelBuffer := []
		for Channel in this.Channels
			ChannelBuffer.Insert(Channel)
		
		this.Log("Attempting to reconnect: try #1")
		while !this.Connect(this.Server, this.Port, this.DefaultNicks[1], this.DefaultUser, this.Name, this.Pass)
		{
			Sleep, 5000
			this.Log("Attempting to reconnect: try #" A_Index+1)
		}
		
		this.SendJOIN(ChannelBuffer*)
		
		this.UpdateDropDown()
		this.UpdateListView()
	}
	
	Chat(Channel, Message)
	{
		return this.SendPRIVMSG(Channel, Message)
	}
	
	; ERR_NICKNAMEINUSE
	on433(Nick,User,Host,Cmd,Params,Msg,Data)
	{
		for Index, Nick in this.DefaultNicks
			if (Nick == this.Nick)
				Break
		Index := (Index >= this.DefaultNicks.MaxIndex()) ? 1 : Index+1
		NewNick := this.DefaultNicks[Index]
		
		this.SendNICK(newNick)
		this.Nick := newNick
		
		this.UpdateDropDown()
		this.UpdateListView()
	}
	
	GetChans()
	{
		return this.Channels
	}
	
	Log(Message)
	{
		Print(Message)
	}
}

Print(Params*){
	static _ := DllCall("AllocConsole")
	StdOut := FileOpen("*", "w")
	for each, Param in Params
		StdOut.Write(Param "`n")
}
