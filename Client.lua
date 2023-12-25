-- 搭配 Server.ps1 (PowerShell_Server_Measure_Folder_Size.ps1) 使用

local Socket = require("socket")

local Client_Agent_List={}
local function Query_Size(self,Path)
	local Client = self._Client
	Client:send(Path..'\n')
	local result,response = ''
	repeat
		response = Client:receive"*l"
		result = result .. (response or '')
	until not response or result~=''
	return result
end--Query_Size
local function Close_Client(self)
	local Client = self._Client
--	Client:shutdown()
	Client:close()
	for Index,Client_Agent in ipairs(Client_Agent_List) do
		if Client_Agent==self then
			table.remove(Client_Agent_List,Index)
			break
		end
	end
end--Close_Client
local Metatable = {
	__index = {
		Query_Size = Query_Size,
		Query = Query_Size,
		Close_Client = Close_Client,
		Close = Close_Client,
	},
	__gc = Close_Client,
}
local function Create_Client_Connection(Host_Name_or_IP,Port)
	local Client, Error_Message = Socket.connect(Host_Name_or_IP or "localhost", Port or 8888)
	if not Client then
		return false, Error_Message
		--	"connection refused"
	end
	local Client_Agent = setmetatable(
		{
			_Client = Client,
		},Metatable
	)
	table.insert(Client_Agent_List,Client_Agent)
	return Client_Agent
end--Create_Client_Connection
local function Close_Server()
	local Client = assert((table.remove(Client_Agent_List,1) or Create_Client_Connection())._Client)
	assert(Client:send"Exit\n")
	Client:close()
end--Close_Server
local function Start_Server()
	local Client = Create_Client_Connection()
	if Client then
		--	already start (exist).
		Client:Close()
	else
		local Current_Folder=require'LuaLibs.Module.Require_Current_Folder'
		assert(os.execute([[powershell -NoProfile -WindowStyle hidden -Command ]]
			..[[Start-Process -FilePath "PowerShell.exe" ]]
			..[[-ArgumentList """-NoProfile -WindowStyle hidden -File `"""]]..Current_Folder..[[\Server.ps1`""" """]]))
	end
end--Start_Server

local Master = {
	Connect = Create_Client_Connection,
	Start_Server = Start_Server,
	Close_Server = Close_Server,
}

if not ... then--test
	print'start server.'
--	Master.Start_Server()
--	local Sleep = require'socket'.sleep
--	Sleep(2)
--	print'create client connection.'
	local Client = assert(Master.Connect())
	print"query size from client."
	print(Client:Query_Size[[H:\Ghost]])
	print(Client:Query[[H:\土豆]])
	print(Client:Query[[H:\non_exist_path]])
	print"close client."
	Client:Close()
	print'close server.'
	Master.Close_Server()
end

return Master