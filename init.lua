local Master = require'Client'
local Client = Master.Connect()
if Client then
	Client:Close()
else
	Master.Start_Service()
end
return Master