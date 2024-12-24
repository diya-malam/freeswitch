-- Lua script to execute the callcenter application in FreeSWITCH

local queue_name="FS@Ecosmob-800"
api = freeswitch.API()
session:execute("callcenter",queue_name)
   


