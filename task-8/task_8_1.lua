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

num = tostring(session:getVariable("destination_number"))

-- authorize --
function authorize()
        
        local digit = session:playAndGetDigits(1, 1, 1, 5000, "#", "/home/diya/Downloads/unauth.mp3", "", "[12]")
       	freeswitch.consoleLog("info", digit)
       	if digit == "1" then
               	freeswitch.consoleLog("info", " get authorised")
               	dbh:query("INSERT INTO EMP (EMPID) VALUES(".."\""..num.."\""..")")
		session:execute("playback","/home/diya/Downloads/auth.mp3" );
        elseif digit == "2" then
               	freeswitch.consoleLog("info", "not want to get authorised")
		session:execute("playback","/home/diya/Downloads/tech.mp3" );
       	else
               	session:execute("playback","/home/diya/Downloads/invalid2.mp3" );
       	end

end

-- welcome --
function welcome()
        session:execute("playback","/home/diya/Downloads/welcome3.mp3" );
        language()
end

-- IVR MENU 1 --
function language()
        lang = session:playAndGetDigits(1, 1, 1, 5000, "#", "/home/diya/Downloads/lang.mp3", "", "[12309]")
        freeswitch.consoleLog("info", lang)
        if lang then
                main_ivr(lang)
        end
end

-- enter mobile number --
function main_ivr(lang)

        freeswitch.consoleLog("info", lang)

        if lang >= "1" and lang <= "3" then
                mob_num(lang)
        elseif lang == "0" then
                language()
        elseif lang == "9" then
                welcome()
        else
                session:execute("playback","/home/diya/Downloads/invalid2.mp3" );
        end

end

-- IVR MENU 2 --
function mob_num(lang)

	ch = tonumber(lang)
	local lang_files = {
 	   "/home/diya/Downloads/hindi.mp3", 
    	   "/home/diya/Downloads/eng.mp3", 
    	   "/home/diya/Downloads/guj.mp3"
}	
	repeat
		mobile = session:playAndGetDigits(10,11, 1, 5000, "#", lang_files[ch], "", "\\d+")
	until #mobile >= 10 
	
	insert_data(mobile)
	menu_3(ch)
end

-- insert data into contacts --
function insert_data(mobile)
	call_uuid = tostring(session:getVariable("uuid"))
	local empid = string.sub(tostring(session:getVariable("destination_number")),3)
	local from_num = tostring(session:getVariable("caller_id_number"))
	remoteip = tostring(session:getVariable("domain"))

	if not dbh:query("INSERT INTO CONTACTS(EMPID,CALL_UUID,FROM_NUMBER,TO_NUMBER,MOBILE,REMOTE_IP) VALUES (".."\""..empid.."\""..",".."\""..call_uuid.."\""..",".."\""..from_num.."\""..",".."\""..num.."\""..",".."\""..mobile.."\""..",".."\""..remoteip.."\""..")") then
	        freeswitch.consoleLog("err","ERROR WHILE INSERTING DATA INTO CONTACTS !!!!")
	end

end

-- IVR MENU 3--
function menu_3(ch)

local audio = {
           "/home/diya/Downloads/hindi2.mp3",
           "/home/diya/Downloads/eng2.mp3",
           "/home/diya/Downloads/guj2.mp3"
}

choice = session:playAndGetDigits(1,1 , 3, 5000, "#", audio[ch], "/home/diya/Downloads/invalid2.mp3", "[123]")        

if choice == "1" then
	 session:execute("bridge","user/91001@${domain_name}")
elseif choice == "2" then
	 session:execute("voicemail","default ${domain_name} "..num)
else    	  
	 session:execute("conference", "bridge:"..call_uuid.."@"..remoteip.."@default:user/91001@${domain}") 
	 session:execute("playback","/home/diya/Downloads/invalid2.mp3" );
end
end

-- main script

local checknum_query = "SELECT * FROM EMP WHERE EMPID="..num;

local row_found = false
        
dbh:query(checknum_query, function(row)
	row_found = true
        freeswitch.consoleLog("INFO", "Row found: ID=" .. row.ID .. ", EMPID=" .. row.EMPID .. "\n")
	welcome()
end)

if not row_found then
	freeswitch.consoleLog("info","not authorized")
	authorize()
end


