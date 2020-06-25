--// Log commands to Trello

server = nil
service = nil

return function()
	local board = server.Settings.Trello_Primary
	local appkey = server.Settings.Trello_AppKey
	local token = server.Settings.Trello_Token
	
	local trello = server.HTTP.Trello.API(appkey,token)
	local lists = trello.getLists(board)
	local logList = trello.getListObj(lists,{"Logs","Admin Logs","Command Logs"})

	service.Events.CommandRan:connect(function(p,msg,command,args,index,table,ran,error)
		if ran and logList then 
			local arg = ""
			if args then
				for i,v in pairs(args) do
					arg = arg..","..v
				end
			end
			
			trello.makeCard(logList.id,tostring(p)..": "..msg,
				"--------------------------------------------"..
				"\nPlayer: "..tostring(p)..
				"\nMessage: "..tostring(msg)..
				"\n"..
				"\nCommand: "..tostring(command)..
				"\nArgs: "..tostring(arg)..
				"\n"..
				"\nTime: "..tostring(service.GetTime())..
				"\nSuccessful: "..tostring(ran)..
				"\nError: "..tostring(error)..
				"\n--------------------------------------------")
		end
	end)
end
