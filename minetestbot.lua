-- Get HTTPs API, json string to lua table, and Discord API
local http = require("coro-http")
local json = require("json")
local discordia = require("discordia")
local client = discordia.Client()
discordia.extensions()
dofile("settings.lua")

local dbg = function(msg)
	discordia.Logger(4, tostring(os.date())):log(4, tostring(msg))
end

local prefix = botSettings.prefix
local color = botSettings.color
local servers = botSettings.servers

local stable_version = "0.4.17.1"
local bleeding_version = "5.0"

-- Page limits
local perpage = {
	lua_api = 6,
	modbook = 10,
}

-- Command functions
local exe = {
	-- Embed example
--[[	["embed"] = {
		description = "Tests embed.",
		exec = function(message)
			message.channel:send({
				embed = {
					title = "title ~~(did you know you can have markdown here too?)~~",
					description = "this supports [named links](https://discordapp.com) on top of the previously shown subset of markdown. ```\nyes, even code blocks```",
					url = "https://discordapp.com",
					color = 2200752,
					timestamp = "2018-09-22T18:00:39.712Z",
					footer = {
						icon_url = "https://cdn.discordapp.com/embed/avatars/0.png",
						text = "footer text"
					},
					thumbnail = {
						url = "https://cdn.discordapp.com/embed/avatars/0.png"
					},
					image = {
						url = "https://cdn.discordapp.com/embed/avatars/0.png"
					},
					author = {
						name = "author name",
						url = "https://discordapp.com",
						icon_url = "https://cdn.discordapp.com/embed/avatars/0.png"
					},
					fields ={
						{
							name = "🤔",
							value = "some of these properties have certain limits..."
						},
						{
							name = "😱",
							value = "try exceeding some of them!"
						},
						{
							name = "🙄",
							value = "an informative error should show up, and this view will remain as-is until all issues are fixed"
						},
						{
							name = "<a:thonkang:219069250692841473>",
							value = "these last two",
							inline = true
						},
						{
							name = "<a:thonkang:219069250692841473>",
							value = "are inline fields",
							inline = true
						}
					}
				}
			})
		end
	},]]
	-- General Minetest command
	["minetest"] = function(message)
		local msg = message.content:gsub("^"..client.user.mentionString.." ", prefix)
		-- Get arguments
		local args = msg:split(" ")
		args[1] = args[1]:gsub(prefix, "")
		-- List of info
		local commands = {
			-- If empty
			default = {
				title = "Helpful Minetest Commands",
				fields = {
					{
						name = "Usage:",
						value = "`"..prefix.."minetest <command>`"
					},
					{
						name = "Avaliable commands:",
						value = "```\ninstall\ncompile\nabout```"
					},
				}
			},
			install = {
				default = {
					name = "Install",
					url = "https://www.minetest.net/downloads/",
					title = "Downloads for Minetest are located here.",
					fields = {
						{
							name = "Use `"..prefix.."minetest install OShere` for OS-specific instructions.",
							value = "```\nlinux\nwindows\nmac\nandroid\nios```"
						},
					}
				},
				linux = {
					name = "Install (Linux)",
					icon = "http://www.stickpng.com/assets/images/58480e82cef1014c0b5e4927.png",
					title = "The recommended way to install Minetest on Linux is through your package manager.\nNote: the version shipped by default may be out of date.\nIn which case, you can use a PPA (if applicable), or compiling may be a better option.",
					fields = {
						{
							name = "__For Debian/Ubuntu-based Distributions:__",
							value = "Open a terminal and run these 3 commands:\n```sudo add-apt-repository ppa:minetestdevs/stable\nsudo apt update\nsudo apt install minetest```"
						},
						{
							name = "__For Arch Distributions:__",
							value = "Open a terminal and run this command:\n```sudo pacman -S minetest```"
						},
						{
							name = "Again, this will vary depending on your distribution. ",
							value = "**[Google](https://www.google.com/) is your friend.**\n\nWhile slightly more involved, compiling works on any Linux distribution.\nSee `"..prefix.."minetest compile linux` for details."
						},
					}
				},
				windows = {
					name = "Install (Windows)",
					icon = "http://pngimg.com/uploads/windows_logos/windows_logos_PNG25.png",
					title = "Installing Minetest on Windows is quite simple.",
					fields = {
						{
							name = "__Download:__",
							value = "Visit https://www.minetest.net/downloads/, navigate to the Windows downloads, and download the proper package for your system."
						},
						{
							name = "__Installation:__",
							value = "Extract your Minetest folder to the location of your choice.\n\nThe executable is located in `YOUR-DIR-PATH\\minetest\\bin\\`.\n\nCreate a desktop link to the executable."
						},
					}
				},
				mac = {
					name = "Install (MacOS)",
					icon = "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bb/OS_X_El_Capitan_logo.svg/1024px-OS_X_El_Capitan_logo.svg.png",
					title = "Installing Minetest on MacOS is about as simple as it gets.",
					fields = {
						{
							name = "__Installation:__",
							value = "Open a terminal.\n\nMake sure you have [homebrew](https://brew.sh/) installed!\nRun:\n```brew install minetest```"
						},
					}
				},
				android = {
					name = "Install (Android)",
					icon = "https://cdn.freebiesupply.com/logos/large/2x/android-logo-png-transparent.png",
					title = "Minetest on mobile devices is not the best experience, but if you really must..",
					fields = {
						{
							name = "__Download:__",
							value = "Navigate to the Google Play Store.\n\nSearch for and download the [official Minetest app](https://play.google.com/store/apps/details?id=net.minetest.minetest).\n\nOptionally, you may also download [Rubenwardy's Minetest Mods app](https://play.google.com/store/apps/details?id=com.rubenwardy.minetestmodmanager)."
						},
					}
				},
				ios = {
					name = "Install (iOS)",
					icon = "https://png.icons8.com/color/1600/ios-logo.png",
					title = "Step one: Switch to an Android device!",
					fields = {
						{
							name = "__Installation:__",
							value = "No, seriously. There is no official Minetest app on the app store for iOS devices.\nHowever, there are more than enough \"clones\" full of ads and bugs you could try if you really wanted to."
						},
					}
				},
			},
			compile = {
				default = {
					name = "Compile",
					url = "https://dev.minetest.net/Compiling_Minetest",
					title = "Compiling instructions are located here.",
					fields = {
						{
							name = "Use `"..prefix.."minetest compile OShere` for OS-specific instructions.",
							value = "```\nlinux\nwindows```"
						},
					}
				},
				linux = {
					name = "Compile (Linux)",
					icon = "http://www.stickpng.com/assets/images/58480e82cef1014c0b5e4927.png",
					title = "Compiling on Linux will allow you to view and modify the source code yourself, as well as run multiple Minetest builds.",
					fields = {
						{
							name = "__Compiling:__",
							value = "Open a terminal.\n\nInstall dependencies. Here's an example for Debian-based and Ubuntu-based distributions:\n```apt install build-essential cmake git libirrlicht-dev libbz2-dev libgettextpo-dev libfreetype6-dev libpng12-dev libjpeg8-dev libxxf86vm-dev libgl1-mesa-dev libsqlite3-dev libogg-dev libvorbis-dev libopenal-dev libhiredis-dev libcurl3-dev```\n\nDownload the engine:```git clone https://github.com/minetest/minetest.git cd minetest/```\n\nDownload Minetest Game:\n```cd games/ git clone https://github.com/minetest/minetest_game.git cd ../```\n\nBuild the game (the make command is set to automatically detect the number of CPU threads to use):\n```cmake . -DENABLE_GETTEXT=1 -DENABLE_FREETYPE=1 -DENABLE_LEVELDB=1 -DENABLE_REDIS=1\nmake -j$(grep -c processor /proc/cpuinfo)```\n\nFor more information, see https://dev.minetest.net/Compiling_Minetest#Compiling_on_GNU.2FLinux."
						},
					}
				},
				windows = {
					name = "Compile (Windows)",
					icon = "http://pngimg.com/uploads/windows_logos/windows_logos_PNG25.png",
					title = "Compiling on Windows is not an easy task, and is not going to be covered easily by me.",
					fields = {
						{
							name = "__Compiling:__",
							value = "Please see https://dev.minetest.net/Compiling_Minetest#Compiling_on_Windows for instructions on compiling Minetest on Windows."
						},
					}
				},
			},
			about = {
				default = {
					url = "https://www.minetest.net/#Features",
					title = "A quick and comprehensive feature list can be found here!",
				},
			}
		}
		-- Content used later in message
		local content = {}
		-- Minetest logo
		local default_icon = "https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Minetest-logo.svg/1024px-Minetest-logo.svg.png"
		-- Is this a blank command?
		if not args[2] then
			-- Use default inputs
			content.title = commands.default.title
			content.fields = commands.default.fields
			content.name = "Minetest"
			content.icon = default_icon
		elseif args[2] then
			-- Is the first input valid?
			if not commands[args[2]] then
				return
			end
			-- Do we have a third argument or not?
			if not args[3] then
				content.url = commands[args[2]].default.url
				content.title = commands[args[2]].default.title
				content.fields = commands[args[2]].default.fields
				content.name = commands[args[2]].default.name
				content.icon = default_icon
			else
				-- Is the third argument valid?
				if not commands[args[2]][args[3]] then
					return
				end
				content.url = commands[args[2]][args[3]].url
				content.title = commands[args[2]][args[3]].title
				content.fields = commands[args[2]][args[3]].fields
				content.name = commands[args[2]][args[3]].name
				content.icon = commands[args[2]][args[3]].icon
			end
		end
		-- Send the message
		message.channel:send({
			embed = {
				-- Title URL (to instructions)
				url = content.url or "",
				title = content.title,
				color = color,
				-- OS-specific icon
				author = {
					name = content.name,
					icon_url = content.icon
				},
				fields = content.fields or {}
			}
		})
	end,
	-- Server rules
	["rules"] = function(message)
		local msg = message.content:gsub("^"..client.user.mentionString.." ", prefix)
		-- Make sure we are a staff member
		if not message.member:getPermissions():__tostring():find("kickMembers") then
			message.channel:send({
				content = "You do not have the permissions to run this command!"
			})
		end
		-- Do we have rules for this server?
		local servername = message.guild.name
		local rules = servers[servername].rules
		if not rules then
			return
		end
		local args = msg:split(" ")
		local content = {}
		local title = ""
		local rule = args[2]
		-- Is this a blank command?
		if not rule then
			-- Get all the rules and put them in a table
			title = "__**Rules:**__"
			for _,text in pairs(rules) do
				if text[2] == "" then
					text[2] = "⠀"
				end
				content[_] = {
					name = "**"..tostring(_)..".** "..text[1],
					value = text[2]
				}
			end
		else
			-- Is this a valid rule number?
			if not servers[servername].rules[tonumber(rule)] then
				return
			end
			local rule_content = servers[servername].rules[tonumber(rule)]
			if rule_content[2] == "" then
				rule_content[2] = "⠀"
			end			
			-- Set the table to one rule
			content[tonumber(rule)] = {
				name = "**"..rule..".** "..rule_content[1],
				value = rule_content[2]
			}
		end
		-- Send the message using the content
		message.channel:send({
			embed = {
				title = title,
				color = color,
				-- Get server icon
				author = {
					name = servername,
					icon_url = message.guild.iconURL
				},
				fields = content
			}
		})
	end,
	-- ContentDB search
	["cdb"] = function(message)
		local msg = message.content:gsub("^"..client.user.mentionString.." ", prefix)
		-- Get stuff after command
		local termidx = msg:find(" ")
		-- Is there a search term
		if not termidx then
			-- Send general info
			message.channel:send({
				embed = {
					url = "https://content.minetest.net/",
					title = "**ContentDB**",
					description = "Minetest's official content repository.",
					color = color,
					thumbnail = {
						url = "https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Minetest-logo.svg/1024px-Minetest-logo.svg.png",
					},
					fields = {
						{
							name = "Usage:",
							value = "`cdb <search term>`"
						}
					}
				}
			})
			return
		end
		-- Get search term
		local term = msg:sub(termidx+1)
		-- Get webpage with search term
		local _, rawbody = http.request(
			"GET",
			"https://content.minetest.net/api/packages/?q="..term:gsub(" ", "+").."&lucky=1",
			{{"content-type", "application/json"}}
		)
		-- Turn json string into lua table (awesome!)
		rawbody = json.decode(rawbody)[1]
		-- Did we get results?
		if not rawbody then
			-- If not, say so
			message.channel:send({
				embed = {
					title = "Could not find any packages related to \""..term.."\".",
					color = color,
				}
			})
			return
		end
		-- Get the data we need
		local author = rawbody.author
		local name = rawbody.name
		local title = rawbody.title
		local desc = rawbody.short_description
		local thumb = rawbody.thumbnail
		-- Failsafe in case something screwed up
		if not name then
			message.channel:send({
				embed = {
					title = "Could not find any packages related to \""..term.."\".",
					color = color,
				}
			})
			return
		end
		-- Get the actual package URL
		local url = "https://content.minetest.net/api/packages/"..author.."/"..name.."/"
		local _, body = http.request(
			"GET",
			url,
			{{"content-type", "application/json"}}
		)
		body = json.decode(body)
		-- Get the Forum and Git repo links (and format a string)
		local forums = body.forums
		local forumthread = ""
		if not (forums == "" or forums == nil or forums == "null") then
			forumthread = "\n[Forum thread](https://forum.minetest.net/viewtopic.php?t="..forums..")"
		end
		local repourl = body.repo
		local gitrepo = ""
		if not (repourl == "" or repourl == nil or repourl == "null") then
			if forumthread == "" then
				gitrepo = "\n[Git Repo]("..repourl..")"
			else
				gitrepo = " | [Git Repo]("..repourl..")"
			end
		end
		-- Send the message
		message.channel:send({
			embed = {
				url = ur"https://content.minetest.net/packages/"..author.."/"..name.."/",
				title = "**"..title.."**",
				description = "By "..author,
				color = color,
				image = {
					url = thumb
				},
				fields = {
					{
						name = "Description:",
						value = desc..forumthread..gitrepo
					}
				}
			}
		})
	end,
	-- Minetest Modding Book search
	["modbook"] = function(message)
		local msg = message.content:gsub("^"..client.user.mentionString.." ", prefix)
		-- Get the search term
		local termidx = msg:find(" ")
		-- Get the sitemap
		local _, body = http.request(
			"GET",
			"https://rubenwardy.com/minetest_modding_book/sitemap.json",
			{{"content-type", "application/json"}}
		)
		-- json string to lua table
		local sitemap = json.decode(body)
		-- Is it an empty command?
		if not termidx then
			-- Set table to nicely formatted chapters
			local pages = 1
			local results = {}
			for _,chapter in pairs(sitemap) do
				if chapter.chapter_number then
					local desc = ""
					if chapter.description then
						desc = chapter.description
					end
					results[#results+1] = {
						-- I hate this, I cant use in-line links in the name >:(
						name = "**Chapter "..tostring(chapter.chapter_number)..": "..chapter.title.."**",
						value = desc.." [[Open]]("..chapter.loc..")"
					}
				end
			end
			-- Did we get more than 10 results?
			local max = perpage.modbook
			if #results > max then
				pages = math.ceil(#results / max )
				for i = 1,#results do
					if i > max then
						results[i] = nil
					end
				end
			end
			-- Send the message
			message.channel:send({
				embed = {
					title = "Minetest Modding Book",
					url = "https://rubenwardy.com/minetest_modding_book/en/index.html",
					thumbnail = {
						url = "https://avatars0.githubusercontent.com/u/2122943?s=460&v=4.png",
					},
					description = "By Rubenwardy",
					color = color,
					footer = {
						text = "Page 1/"..tostring(pages)
					},
					fields = results
				}
			})
			return
		-- We have a search term
		else
			-- Get the actual term
			local term = msg:sub(termidx+1):lower()
			local index, url, title
			local desc = ""
			-- Is our term a chapter number or title?
			if tonumber(term) then
				-- If its a number, get all the chapters by index
				local chapters = {}
				for i,chapter in pairs(sitemap) do
					chapters[tostring(chapter.chapter_number)] = i
				end
				-- Is our term a valid index?
				if chapters[term] then
					-- If so, set the variables
					local chapter = sitemap[chapters[term]]
					if chapter.description then
						desc = chapter.description
					end
					index = chapter.chapter_number
					url = chapter.loc
					title = chapter.title
				end
			-- Or we have a term
			else
				-- Get titles, compare to search term
				for _,chapter in pairs(sitemap) do
					if chapter.title then
						if chapter.title:lower():find(term) then
							-- If title contains search term, count it as a hit
							if chapter.description then
								desc = chapter.description
							end
							index = chapter.chapter_number
							url = chapter.loc
							title = chapter.title
							break
						end
					end
				end
				-- Do we have anything yet?
				if not url then
					for _,chapter in pairs(sitemap) do
						-- Let's check the descriptions
						if chapter.description then
							if chapter.description:lower():find(term) then
								-- If description contains search term, count it as a hit
								if chapter.description then
									desc = chapter.description
								end
								index = chapter.chapter_number
								url = chapter.loc
								title = chapter.title
								break
							end
						end
					end
				end
			end
			-- Do we have anything to send?
			if url then
				local chapterstr = "**"
				if index then
					chapterstr = "**Chapter "..index..": "
				end
				-- Send the message
				message.channel:send({
					embed = {
						title = "Minetest Modding Book",
						url = "https://rubenwardy.com/minetest_modding_book/en/index.html",
						thumbnail = {
							url = "https://avatars0.githubusercontent.com/u/2122943?s=460&v=4.png",
						},
						color = color,
						fields = {
							{
								name = chapterstr..title.."**",
								value = desc.." [[Open]]("..url..")"
							}
						}
					}
				})
				return
			end
			-- If we havent had a success, throw a fail
			message.channel:send({
				embed = {
					title = "Could not find chapter \""..term.."\".",
					color = color,
				}
			})
		end
	end,
	-- RTFM
	["lua_api"] = function(message)
		local msg = message.content:gsub("^"..client.user.mentionString.." ", prefix)
		-- Get the search term
		local termidx = msg:find(" ")
		-- Do we have a term?
		if not termidx then
			-- If not, send some links
			message.channel:send({
				embed = {
					title = "Lua API",
					thumbnail = {
						url = "https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Minetest-logo.svg/1024px-Minetest-logo.svg.png",
					},
					description = "Minetest Lua API Documentation",
					color = color,
					fields = {
						{
							name = "lua_api.txt with nice formatting",
							value = "lua_api.txt but looks a little nicer. Located [here](https://rubenwardy.com/minetest_modding_book/lua_api.html)."
						},
						{
							name = "lua_api.txt (stable, "..stable_version..")",
							value = "Lua API in a text file (use CTRL+F). Located [here](https://github.com/minetest/minetest/blob/6dc7177a5de51f1329c1be04e7f07be64d5cc76c/doc/lua_api.txt)."
						},
						{
							name = "lua_api.txt (bleeding, "..bleeding_version..")",
							value = "Unstable Lua API in a text file (use CTRL+F). Located [here](https://github.com/minetest/minetest/blob/master/doc/lua_api.txt)."
						},
					}
				}
			})
		else
			-- Get the actual term
			local term = msg:sub(termidx+1)
			local line_num = 0
			local pages = 1
			local results = {}

			-- Read the API
			for line in io.lines("./lua_api.txt") do
				line_num = line_num + 1
				-- Add a field with the line number and a preview (link)
				if line:lower():find(term:lower()) or line:lower():find(term:lower():gsub(" ", "_")) then
					results[#results+1] = {
						name = "Line "..tostring(line_num)..":",
						value = "[```\n"..line:gsub("[%[%]]", "").."\n```](https://github.com/minetest/minetest/blob/6dc7177a5de51f1329c1be04e7f07be64d5cc76c/doc/lua_api.txt#L"..tostring(line_num)..")"
					}
				end
			end

			local max = perpage.lua_api
			-- Did we get more than 10 results?
			if #results > max then
				-- Did we get way too many?
				if #results > 100 then
					message.channel:send({
						embed = {
							title = "Error: Result overflow!",
							description = "Got "..tostring(#results).." results. Search [the API](https://github.com/minetest/minetest/blob/6dc7177a5de51f1329c1be04e7f07be64d5cc76c/doc/lua_api.txt) manually instead.",
							color = color
						}
					})
					return
				end
				pages = math.ceil(#results / max )
				for i = 1,#results do
					if i > max then
						results[i] = nil
					end
				end
			end
			-- Send the message
			message.channel:send({
				embed = {
					title = "Minetest Lua API",
					thumbnail = {
						url = "https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Minetest-logo.svg/1024px-Minetest-logo.svg.png",
					},
					description = "Results for `"..term.."`:",
					color = color,
					footer = {
						text = "Page 1/"..tostring(pages)
					},
					fields = results
				}
			})
		end
	end,
}

-- Make the commands
local commands = {
	["ping"] = {
		description = "Answers with pong.",
		exec = function(message)
			message.channel:send("Pong!")
		end
	},
	["minetest"] = {
		aliases = {"mt"},
		description = "General Minetest helpers.",
		exec = exe.minetest
	},
	["rules"] = {
		description = "List rules.",
		exec = exe.rules
	},
	["cdb"] = {
		aliases = {"mod", "modsearch", "search"},
		description = "Search the ContentDB",
		exec = exe.cdb
	},
	["modbook"] = {
		aliases = {"book"},
		description = "Search the Modding Book",
		exec = exe.modbook
	},
	["lua_api"] = {
		aliases = {"api", "rtfm", "docs", "doc"},
		description = "Get Lua API links",
		exec = exe.lua_api
	},
}

-- Add alias commands
local aliases = {}
for cmd in pairs(commands) do
	if commands[cmd].aliases then
		for _,aliase in pairs(commands[cmd].aliases) do
			-- Dont include aliase field, add is_aliase
			aliases[aliase] = {
				is_aliase = true,
				description = commands[cmd].description,
				exec = commands[cmd].exec
			}
		end
	end
end
for cmd in pairs(aliases) do
	commands[cmd] = aliases[cmd]
end
aliases = nil

-- Bot loaded
client:on("ready", function()
	-- client.user is the path for bot
	print("Logged in as ".. client.user.username)
end)

-- On receive message
client:on("messageCreate", function(message)
	-- Is this sent by someone other than self?
	if message.author.name ~= client.user.name then
		-- Split all arguments into a table (turn mention into prefix)
		local args = message.content:gsub("^"..client.user.mentionString.." ", prefix):split(" ")

		if message.content == client.user.mentionString then
			local servername = message.guild.name
			local pingsock = servers[servername].pingsock
			if not pingsock then
				return
			end
			-- Send pingsock
			message.channel:send({
				content = "<"..pingsock..">"
			})
			return
		end

		-- Is it a command?
		if not args[1]:find("^"..prefix) then
			return
		end

		-- If so, execute it
		local command = commands[args[1]:gsub("^"..prefix, "")]
		if command then
			command.exec(message)
		end

		-- If we get this far, see if the command is 'help'
		if args[1] == prefix.."help" then
			local fields = {}
			-- Did we specify a command?
			if args[2] then
				local cmd = commands[args[2]]
				if cmd then
					local aliasestr = ""
					-- Do we have aliases?
					if cmd.aliases then
						aliasestr = " | Aliases:"
						-- If so, list them
						for _,aliase in pairs(cmd.aliases) do
							aliasestr = aliasestr.." "..aliase..","
						end
						aliasestr = aliasestr:gsub(",$", "")
					end
					fields[1] = {
						name = "Command: `"..args[2].."`",
						value = (cmd.description or "⠀")..aliasestr
					}
				else
					-- Throw fail
					message.channel:send({
						embed = {
							title = "Command \""..args[2].."\" does not exist.",
							color = color,
						}
					})
					return
				end
			else
				-- Get all commands
				for word, tbl in pairs(commands) do
					local aliasestr = ""
					-- Do we have aliases?
					if tbl.aliases then
						aliasestr = " | Aliases:"
						-- If so, list them
						for _,aliase in pairs(tbl.aliases) do
							aliasestr = aliasestr.." "..aliase..","
						end
						aliasestr = aliasestr:gsub(",$", "")
					end
					-- Is this an aliase itself?
					if not tbl.is_aliase then
						-- Is this a dev command?
						if not tbl.secret then
							-- If not then add it
							fields[#fields+1] = {
								name = "Command: `"..word.."`",
								value = (tbl.description or "⠀")..aliasestr
							}
						end
					end
				end
			end
			-- Send the message
			message.channel:send({
				embed = {
					title = "MinetestBot Commands:",
					thumbnail = {
						url = client.user:getAvatarURL()
					},
					color = color,
					fields = fields,
					footer = {
						text = "Prefix: "..botSettings.prefix
					},
				}
			})
		end
	-- Otherwise its my own message
	else
		local embed = message.embed
		-- Do we have an embed and footer with page count?
		if embed then
			if embed.footer then
				local text = embed.footer.text
				if text:find("Page") then
					-- Are there enough pages to bother adding turners?
					local page_total = text:match("%d*$")
					if tonumber(page_total) ~= 1 then
						message:addReaction("⬅")
						message:addReaction("➡")
					end
				end
			end
		end
	end
end)

-- Page functions
local pages = {
	["Minetest Modding Book"] = function(page)
		local current_page = page.current_page
		local results = {}
		local fields = {}
		-- Get the sitemap
		local _, body = http.request(
			"GET",
			"https://rubenwardy.com/minetest_modding_book/sitemap.json",
			{{"content-type", "application/json"}}
		)
		-- json string to lua table
		local sitemap = json.decode(body)
		for _,chapter in pairs(sitemap) do
			if chapter.chapter_number then
				local desc = ""
				if chapter.description then
					desc = chapter.description
				end
				results[#results+1] = {
					-- I hate this, I cant use in-line links in the name >:(
					name = "**Chapter "..tostring(chapter.chapter_number)..": "..chapter.title.."**",
					value = desc.." [[Open]]("..chapter.loc..")"
				}
			end
		end
		local max = perpage.modbook
		for i = 1,#results do
			if i > max*(current_page-1) and i <= max*(current_page) then
				fields[#fields+1] = results[i]
			end
		end
		return fields
	end,
	["Minetest Lua API"] = function(page)
		local current_page = page.current_page
		local embed = page.embed
		local term = embed.description:sub(embed.description:find("`")+1):gsub("`:", "")
		local line_num = 0
		local results = {}
		local fields = {}
		-- Read the API
		for line in io.lines("./lua_api.txt") do
			line_num = line_num + 1
			if line:lower():find(term:lower()) or line:lower():find(term:lower():gsub(" ", "_")) then
				-- Add a field with the line number and a preview (link)
				results[#results+1] = {
					name = "Line "..tostring(line_num)..":",
					value = "[```\n"..line:gsub("[%[%]]", "").."\n```](https://github.com/minetest/minetest/blob/6dc7177a5de51f1329c1be04e7f07be64d5cc76c/doc/lua_api.txt#L"..tostring(line_num)..")"
				}
			end
		end
		local max = perpage.lua_api
		for i = 1,#results do
			if i > max*(current_page-1) and i <= max*(current_page) then
				fields[#fields+1] = results[i]
			end
		end
		return fields
	end,
}

local function page_turner(reaction, userId)
	local message = reaction.message
	local reactor = client:getUser(userId)
	local embed = message.embed
	local sender = message.author.name
	if sender == client.user.name then
		if reactor.name ~= client.user.name then
			if embed then
				if embed.footer then
					local text = embed.footer.text
					if text:find("Page") then
						message:removeReaction(reaction, userId)
						if reaction.emojiName == "⬅" or reaction.emojiName == "➡" then
							if not pages[embed.title] then
								return
							end
							local page_total = tonumber(text:match("%d*$"))
							if page_total == 1 then
								return
							end
							local current_page = text:match("%d*/"):gsub("/", "")
							current_page = tonumber(current_page)
							if reaction.emojiName == "➡" then
								if current_page == page_total then
									current_page = 1
								else
									current_page = current_page + 1
								end
							else
								if current_page == 1 then
									current_page = page_total
								else
									current_page = current_page - 1
								end
							end
							local input = pages[embed.title]({
								reaction = reaction,
								current_page = current_page,
								embed = embed,
							})
							-- Edit the message
							message:setEmbed({
								title = embed.title or nil,
								thumbnail = embed.thumbnail or nil,
								description = embed.description or nil,
								color = color,
								footer = {
									text = "Page "..tostring(current_page).."/"..page_total
								},
								fields = input,
							})
						end
					end
				end
			end
		end
	end
end

client:on("reactionAdd", page_turner)

client:on("reactionAddUncached", function(channel, messageId, hash, userId)
	local message = channel:getMessage(messageId)
	if message then
		local reaction = message.reactions:get(hash)
		if reaction then
			return page_turner(reaction, userId)
		end
	end
end)

-- Run the bot :D
client:run(botSettings.token)
