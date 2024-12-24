
api = freeswitch.API()
-- Load database handle
dbh = freeswitch.Dbh("odbc://freeswitch:diya:Diya123!")

-- Check if the database connection is successful
if dbh:connected() then
    freeswitch.consoleLog("notice", "Connected to the database!\n")
else
    freeswitch.consoleLog("err", "Cannot connect to the database!\n")
    return
end

-- SQL statements
local create_table_query = [[
CREATE TABLE IF NOT EXISTS test (
    id INT AUTO_INCREMENT PRIMARY KEY,
    caller VARCHAR(50),
    callee VARCHAR(50),
    uuid VARCHAR(255),
    call_id VARCHAR(255)
);
]]

caller = tostring(session:getVariable("caller_id_number"))
callee = tostring(session:getVariable("destination_number"))
uuid = tostring(session:getVariable("uuid"))
call_id = tostring(session:getVariable("sip_call_id"))

--freeswitch.consoleLog("notice", ..callee.."\n")
--freeswitch.consoleLog("notice", ..caller.."\n")
session:consoleLog("info", "CALLER : " .. caller .. "\n")
session:consoleLog("info", "CALLEE : " .. callee .. "\n")
session:consoleLog("info", "UUID : " .. uuid .. "\n")
session:consoleLog("info", "CALL_ID : " .. call_id .. "\n")

-- Execute the queries
if dbh:query(create_table_query) then
    freeswitch.consoleLog("notice", "Table created successfully or already exists.\n")
else
    freeswitch.consoleLog("err", "Failed to create the table.\n")
end

if dbh:query("INSERT INTO test(caller,callee,uuid,call_id) VALUES (".."\""..caller.."\""..",".."\""..callee.."\""..",".."\""..uuid.."\""..",".."\""..call_id.."\""..")") then

    freeswitch.consoleLog("notice", "Data inserted successfully.\n")
else
    freeswitch.consoleLog("err", "Failed to insert data.\n")
end

-- Close the database connection
dbh:release()

