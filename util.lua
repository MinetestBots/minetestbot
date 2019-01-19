_G.mbot = {}

dofile("settings.lua")

function mbot.dbg(msg)
	discordia.Logger(4, tostring(os.date())):log(4, tostring(msg))
end

mbot.prefix = botSettings.prefix
mbot.color = botSettings.color
mbot.servers = botSettings.servers

mbot.stable_version = "0.4.17.1"
mbot.unstable_version = "5.0"

mbot.commands = {}
mbot.aliases = {}

function mbot.botEmoji()
	local list = {}
	local emoteServer = client:getGuild("531580497789190145")
	for i in pairs(emoteServer.emojis) do
		local emoji = emoteServer:getEmoji(i)
		list[emoji.name] = ":"..emoji.name..":"..i
	end
	return list
end

function string:split(delimiter, max)
	local result = {}
	for match in (self..delimiter):gmatch("(.-)"..delimiter) do
		if max and #result == max then
			result[max+1] = self
			break
		end
		table.insert(result, match)
		self = self:sub(match:len()+2)
	end
	return result
end

--[[ URL Handling ]]--
local function readUrl(url)
	local _, body = http.request("GET", url)
	local lines = {}
	function adjust(s)
		if s:sub(-1)~="\n" then s=s.."\n" end
		return s:gmatch("(.-)\n")
	end
	for line in adjust(body) do
		lines[#lines+1] = line
	end
	return lines
end

function mbot.searchUrl(url, term, def, id, page)
	-- Init and defaults
	local pages = 1
	local results = {}
	local resultMax = def.max or 10
	local resultIcon = def.icon or "https://magentys.io/wp-content/uploads/2017/04/github-logo-1.png" --github logo
	local resultTitle = def.title or "Search Results"

	if not id or type(id) ~= "string" then
		return
	end

	if not page then
		page = 1
	end

	-- Adjust URL
	local cutoff = url:find("%.com/")
	url = url:sub(cutoff+5):gsub("#%w+", "")

	local githubUrl = "https://github.com/"..url
	local rawUrl = "https://raw.githubusercontent.com/"..url:gsub("/blob", "", 1)

	-- Read the API
	for num, line in pairs(readUrl(rawUrl)) do
		-- Add a field with the line number and a preview (link)
		if line:lower():find(term:lower(), 1, true) or line:lower():find(term:lower():gsub(" ", "_"), 1, true) then
			results[#results+1] = {
				name = "Line "..tostring(num)..":",
				value = "[```\n"..line:gsub("[%[%]]", "").."\n```]("..githubUrl.."#L"..num..")"
			}
		end
	end

	local fields = {}

	-- Did we get anything?
	if #results == 0 then
		local embed = {
			title = resultTitle,
			description = "No results!",
			color = mbot.color
		}
		return embed
	end

	-- Did we get more than max results?
	if #results > resultMax then
		-- Did we get way too many?
		if #results > 100 then
			local embed = {
				title = "Error: Result overflow!",
				description = "Got "..#results.." results. Search [the URL]("..githubUrl..") manually instead.",
				color = mbot.color
			}
			return embed
		end
		pages = math.ceil(#results / resultMax )
		for i = 1, #results do
			if i > resultMax*(page-1) and i <= resultMax*(page) then
				fields[#fields+1] = results[i]
			end
		end
	else
		fields = table.copy(results)
	end
	
	local embed = {
		title = resultTitle,
		thumbnail = {
			url = resultIcon,
		},
		description = "Results for [`"..term.."`]("..githubUrl.."):",
		color = mbot.color,
		footer = {
			text = "Page "..page.."/"..pages.." | "..id
		},
		fields = fields
	}

	return embed
end

function mbot.pageTurn(reaction, userId)
	local message = reaction.message
	local reactor = client:getUser(userId)
	local embed = message.embed
	local sender = message.author.name
	-- Was this a bot message, was it a normal user reacting, and does it have a footer to read?
	if sender == client.user.name and reactor.name ~= client.user.name and embed and embed.footer then
		local text = embed.footer.text:gsub(" |", ""):split(" ")
		-- Is this worth doing something with
		if text[1] ~= "Page" then
			return
		end
		-- Clean up extras
		message:removeReaction(reaction, userId)
		-- Only 2 valid interaction emotes
		if reaction.emojiName == "⬅" or reaction.emojiName == "➡" then
			-- No ID to work with
			if not mbot.commands[text[3]] or not mbot.commands[text[3]].page then
				return
			end
			-- Get total and current
			local page_total = tonumber(text[2]:match("%d+$"))
			-- This only has 1 page, dont do anything
			if page_total == 1 then
				return
			end
			local current_page = tonumber(text[2]:match("^%d+"))
			if reaction.emojiName == "➡" then
				-- Loop around
				if current_page == page_total then
					current_page = 1
				-- Or go forward
				else
					current_page = current_page + 1
				end
			else
				-- Loop around
				if current_page == 1 then
					current_page = page_total
				-- Or go backward
				else
					current_page = current_page - 1
				end
			end
			local input, type = mbot.commands[text[3]].page({
				current = current_page,
				embed = embed,
			})
			-- Edit the message
			if type == "fields" then
				message:setEmbed({
					title = embed.title or nil,
					thumbnail = embed.thumbnail or nil,
					description = embed.description or nil,
					color = mbot.color,
					footer = {
						text = "Page "..current_page.."/"..page_total.." | "..text[3]
					},
					fields = input,
				})
			else
				message:setEmbed(input)
			end						
		end
	end
end

--[[ Command Registration ]]--
function mbot.register_command(name, def)
	-- Not valid
	if not def.func then
		return
	end
	if def.description and type(def.description) ~= "string" then
		def.description = nil
	end
	if def.aliases and type(def.aliases) ~= "table" then
		def.aliases = {}
	end
	mbot.commands[name] = {
		func = def.func,
		description = def.description,
		usage = def.usage,
		aliases = def.aliases,
		page = def.page,
		secret = def.secret,
	}
	if def.aliases then
		for _,alias in pairs(def.aliases) do
			mbot.aliases[alias] = name
		end
	end
end
