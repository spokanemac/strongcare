-- Install Latest StrongCare+ Client.
-- Created 2013.07.29 by Jack-Daniyel Strong.
-- 2013.07.29 - Initial Configuration

-- (C)opyright 2008-2013 J-D Strong Consulting, Inc.

-- Variable settings:

property MyTitle : "StrongCarePlus Installer"
property defaults : "/usr/bin/defaults"
property ClientGroup : "CLIENTGROUP"
property MONITORINGCLIENT : "/Library/MonitoringClient/ClientSettings"
property MONITORINGCLIENTPLUGIN : "/Library/MonitoringClient/PluginSupport/"
property defaults_write : defaults & " write "


-- Start the script (double click)
on run
	my main()
end run

on main()
	try
		
		my DisplayInfoMsg("This utility will install StrongCare+ on this machine. You will be prompted for an Administrative password, and be alerted when installation is complete.")
		
		my InstallStrongCare()
		
		my AlertDone()
		-- Catch any unexpected errors:
		
	on error ErrorMsg number ErrorNum
		my DisplayErrorMsg(ErrorMsg, ErrorNum)
	end try
end main


-- Install StrongCare
on InstallStrongCare()
	
	set cmd to defaults_write & MONITORINGCLIENT & " ClientGroup -string \"" & ClientGroup & "\" && "
	set cmd to cmd & defaults_write & MONITORINGCLIENTPLUGIN & "check_time_machine_settings Days_Until_Warning -int 7 && "
	set cmd to cmd & "/usr/bin/curl -L1 https://path/to/StrongCare.pkg > /tmp/StrongCare.pkg &&"
	set cmd to cmd & " /usr/sbin/installer -target / -pkg /tmp/StrongCare.pkg &&"
	set cmd to cmd & "/usr/local/munki/managedsoftwareupdate;"
	
	my DisplayInfoMsg(cmd)
	
	-- do shell script cmd with administrator privileges
	
end InstallStrongCare

on AlertDone()
	-- get current volume settings
	set curVolume to output volume of (get volume settings)
	set curAlertVolume to alert volume of (get volume settings)
	set isMuted to output muted of (get volume settings)
	-- check for a mute, and unmute
	if isMuted then set volume without output muted
	-- turn it up to 11
	set volume output volume 100
	set volume alert volume 100
	beep 3 -- get attention
	-- CleanUp
	set volume output muted isMuted
	set volume output volume curVolume
	set volume alert volume curAlertVolume
	
	display dialog "Done!" buttons {"OK"} default button 1 with icon note with title MyTitle giving up after 5
end AlertDone

-- Display information to the user:

on DisplayInfoMsg(DisplayInfo)
	tell me
		activate
		display dialog DisplayInfo buttons {"OK"} default button 1 with icon note with title MyTitle
	end tell
end DisplayInfoMsg

-- Display an error message to the user:

on DisplayErrorMsg(ErrorMsg, ErrorNum)
	set Msg to "Sorry, an error occured:" & return & return & ErrorMsg & " (" & ErrorNum & ")"
	tell me
		activate
		display dialog Msg buttons {"OK"} default button 1 with icon stop with title MyTitle
	end tell
end DisplayErrorMsg
