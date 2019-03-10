-- Settings
local relay = mbot.relay
local default_avatar = "https://i.imgur.com/qa6QJZl.png"

if not relay.irc_channel or not relay.minetest_user or not relay.discord_channel or not relay.webhook then
	print("IRC Relay configured incorrectly! Aborting.")
	client:quit()
	return
end

-- Mainly for code blocks. Might extend later.
local function simplifyMarkdown(input)
	return input:gsub("\n", " "):gsub("  ", "")
end

-- Get user avatar if they exist
local function cloneAvatar(name)
	local avatar
	local channel = client:getChannel(relay.discord_channel).guild
	channel.members:forEach(function(m)
		if m.user.username == name then
			avatar = m.user.avatarURL
		end
	end)
	return avatar
end

-- Find @mentions and replace them
local function userMention(msg)
	local channel = client:getChannel(relay.discord_channel).guild
	channel.members:forEach(function(m)
		msg = msg:gsub("@"..m.user.username.."#?%d?%d?%d?%d?", m.user.mentionString)
		msg = msg:gsub("@"..m.user.username:lower().."#?%d?%d?%d?%d?", m.user.mentionString)
		if m.nickname then
			msg = msg:gsub("@"..m.nickname.."#?%d?%d?%d?%d?", m.user.mentionString)
			msg = msg:gsub("@"..m.nickname:lower().."#?%d?%d?%d?%d?", m.user.mentionString)
		end
	end)
	return msg
end

-- Find #channels and replace them
local function channelMention(msg)
	local channel = client:getChannel(relay.discord_channel).guild
	channel.textChannels:forEach(function(c)
		msg = msg:gsub("#"..c.name, c.mentionString)
	end)
	return msg
end

-- Convert IRC to Discord markdown
local function discordFormat(str)
	-- Get occurences
	local function find(input, search)
		local ct = 0
		for char in string.gmatch(input, ".") do if char == search then ct = ct + 1 end end
		return ct
	end

	-- Italic, bold, and underline chars
	local pat = "["..string.char(0x1D)..string.char(0x02)..string.char(0x1F).."]"

	-- Formats
	local formatChars = {
		italic = {string.char(0x1D), "_"},
		bold = {string.char(0x02), "**"},
		underline = {string.char(0x1F), "__"},
	}
	
	-- Find pairs
	str = str:gsub(pat.."+.-"..pat.."+", function(section)
		local wrap = section:sub(section:match("^"..pat.."+"):len()+1,-section:match(pat.."+$"):len()-1)
		for _, chars in pairs(formatChars) do
			local found = find(section, chars[1])
			if found and found > 1 then
				wrap = chars[2]..wrap..chars[2]
			end
		end
		if wrap == "" then
			wrap = section
		end
		return wrap
	end)

	-- Find unmatched (should only be 0 or 1)
	str = str:gsub(pat.."+.-$", function(section)
		local wrap = section:sub(section:match("^"..pat.."+"):len()+1)
		for _, chars in pairs(formatChars) do
			local found = find(section, chars[1])
			if found and found == 1 then
				wrap = chars[2]..wrap..chars[2]
			end
		end
		return wrap
	end)
	return str
end

-- Combine above
local function smartParse(msg)
	msg = userMention(msg)
	msg = channelMention(msg)
	return discordFormat(msg)
end

-- Send webhook message
local function hook(payload)
	-- Content
	local send = {
		username = payload.name,
		avatar_url = payload.avatar,
		content = payload.msg or "ERROR: Missing message content" 
	}

	-- Send to webhook
	coroutine.wrap(function()
		http.request("POST", relay.webhook, {{"Content-Type", "application/json"}}, json.encode(send))
	end)()
end

-- Create relay user
local c = irc:new(relay.server or "irc.freenode.net", "Discord", {auto_join={relay.irc_channel}})

-- Connect
c:connect()

-- Log/info
c:on("connect", function()
	print("Discord-IRC relay connected.")
	hook({msg = "Relay connected.", avatar = default_avatar})
end)

c:on("disconnect", function(reason)
	hook({msg = "Relay disconnected.", avatar = default_avatar})
	print(string.format("Disconnected: %s", reason))
end)

-- Send IRC chat to Discord
c:on("message", function(from, to, msg)
	local avatar = cloneAvatar(from)
	if relay.minetest_user and from == relay.minetest_user then
		avatar = nil
	end
	hook({name = from, msg = smartParse(msg), avatar = avatar})
end)

c:on("action", function(from, to, msg)
	local avatar = cloneAvatar(from)
	hook({name = from, msg = "*"..smartParse(msg).."*", plain = true, avatar = avatar})
end)

-- Send Discord chat to IRC
client:on("messageCreate", function(message)
	-- Dont send relay messages; stay in desegnated channel
	if message.member and message.channel.id == relay.discord_channel then
		-- Get nickname, if any
		local member = message.member or message.author
		-- Send commands from Discord to IRC for server to catch
		if message.content:lower():match("^"..relay.minetest_user:lower()..",") then
			c:say(relay.irc_channel, "Command sent by "..member.name..":")
			c:say(relay.irc_channel, simplifyMarkdown(message.content))
		else
			c:say(relay.irc_channel, "<"..member.name.."> "..simplifyMarkdown(message.content))
		end
	end
end)

--[[c:on("notice", function(from, to, msg)
	from = from or c.server
	print(string.format("-%s:%s- %s", from, to, msg))
end)]]

-- IRC actions
c:on("ijoin", function(channel, whojoined)
	print(string.format("Joined channel: %s", channel))

	channel:on("join", function(whojoined)
		hook({msg = string.format("_%s_ has joined the channel", whojoined), avatar = default_avatar})
	end)

	channel:on("part", function(who, reason)
		hook({msg = string.format("_%s_ has left the channel", who)..(reason and " ("..reason..")" or ""), avatar = default_avatar})
	end)

	channel:on("kick", function(who, by, reason)
		hook({msg = string.format("_%s_ has been kicked from the channel by %s", who, by)..(reason and " ("..reason..")" or ""), avatar = default_avatar})
	end)

	channel:on("quit", function(who, reason)
		hook({msg = string.format("_%s_ has quit", who)..(reason and " ("..reason..")" or ""), avatar = default_avatar})
	end)

	channel:on("kill", function(who)
		hook({msg = string.format("_%s_ has been forcibly terminated by the server", who), avatar = default_avatar})
	end)

	channel:on("+mode", function(mode, setby, param)
		if setby == nil then return end
		hook({msg = string.format("_%s_ sets mode: %s%s",
			channel,
			setby,
			"+"..mode.flag,
			(param and " "..param or "")
		), avatar = default_avatar})
	end)

	channel:on("-mode", function(mode, setby, param)
		if setby == nil then return end
		hook({msg = string.format("_%s_ sets mode: %s%s",
			channel,
			setby,
			"-"..mode.flag,
			(param and " "..param or "")
		), avatar = default_avatar})
	end)
end)

c:on("ipart", function(channel, reason)
	print("Left channel")
end)

c:on("ikick", function(channel, kickedby, reason)
	print(string.format("Kicked from channel by %s (%s)", kickedby, reason))
end)

c:on("names", function(channel)
	local users = ""
	for _, user in pairs(channel.users) do
		users = users .. tostring(user) .. ", "
	end
	hook({msg = "Users in channel: "..users:sub(1,-3), avatar = default_avatar})
end)

if relay.dm_enabled == false then
	return
end

-- Response handler
local relayQueue = {}
local loggedIn

-- Relay interaction
mbot.register_command("irc", {
	description = "Interact with IRC relay",
	func = function(message)
		-- Only work in DM (to protect passwords when logging in)
		if message.channel.type ~= 1 then
			message.channel:send("This can only be used in a private DM!")
			return
		end
		-- Logout current login to prevent abuse if not the same user
		if loggedIn and loggedIn ~= message.channel.id then
			-- Handle logout response message
			relayQueue[#relayQueue+1] = loggedIn
			c:say(relay.minetest_user, "logout")
			loggedIn = nil
		end
		-- Get message parts
		local send = message.content
		local args = send:split(" ", 2)
		local cmd = args[2]
		if not cmd then
			message.channel:send("Empty command!")
			return
		end
		-- Handle server PMs
		if cmd:match("^@") then
			-- Add Discord sender
			args[3] = "<"..message.author.tag.."> "..args[3]
		end
		-- Create message
		send = args[2].." "..args[3]
		-- Handle response message and send
		relayQueue[#relayQueue+1] = message.channel.id
		c:say(relay.minetest_user, send)
	end,
})

c:on("pm", function (from, msg)
	-- Is the message a PM from a Minetest user
	if msg:match("^<[%w_-]-> ") then
		-- Get message parts
		local params = msg:split(" ", 2)
		local from = params[1]:sub(2,-2)
		local to = params[2]
		local send = params[3]
		local dm
		local channel = client:getChannel(relay.discord_channel).guild
		-- Find user
		channel.members:forEach(function(m)
			if to:match("#%d%d%d%d$") then
				if m.user.tag == to then
					dm = m.user
				end
			else
				if m.user.username == to then
					dm = m.user
				end
			end
		end)
		-- If the user exists, send the messsage to them
		if dm then
			coroutine.wrap(function()
				dm:getPrivateChannel():send("<"..from.."@"..relay.minetest_user.."> "..smartParse(send))
			end)()
		-- Otherwise deny message; use dummy queue to handle PM response
		else
			relayQueue[#relayQueue+1] = "dummy"
			c:say(relay.minetest_user, "@"..from.." User '"..to.."' is not on Discord!")
		end
	-- Is this an IRC response
	else
		coroutine.wrap(function()
			-- Send to next channel in queue if not dummy
			if relayQueue[1] and relayQueue[1] ~= "dummy" then
				-- Handle user logins
				if msg:match("^You are now logged in as ") then
					loggedIn = relayQueue[1]
				end
				client:getChannel(relayQueue[1]):send("<"..from.."> "..smartParse(msg))
			end
			-- Increment queue
			table.remove(relayQueue, 1)
		end)()
	end
end)
