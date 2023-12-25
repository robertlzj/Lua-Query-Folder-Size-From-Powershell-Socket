# Function

- Powershell 5.1 socket TCP server
  Runs background by `Start-Process` cmdlet.
  - Connection test:
    - Test whether port is occupied, if occupied, retrieve process ID.
    - Heart-beat test, check if connection is alive or break.
  - Retrieve (respond) size of folder (directory)  by path queried (request) from client.
    - Check path is valid, otherwise return error code.
- Lua 5.3 socket TCP client
  Query (request) folder (directory) size by sending path to server.

# Usage

```lua
local Master = require'Lua_Query_Size_Of_Folder_Path_Through_Powershell_Via_Socket'

--	will auto start server within 'init.lua', or handle manually as bellow
print'start server.'
Master.Start_Server()
local Sleep = require'socket'.sleep
Sleep(2)

print'create client connection.'
local Client = assert(Master.Connect())
print"query size from client."
print(Client:Query_Size[[H:\Ghost]])
print(Client:Query[[H:\土豆]])
print(Client:Query[[H:\non_exist_path]])
print"close client."
Client:Close()
print'close server.'
Master.Close_Server()
```

will get

> start server.
> create client connection.
> query size from client.
> 12125432504
> 1397331691
> -1
> close client.
> close server.

See 'test' in "Client.lua"