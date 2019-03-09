--[[ Init ]]--

-- Get HTTPs API, json string to lua table, url handler, and Discord API
_G.http = require("coro-http")
_G.json = require("json")
_G.url = require("socket.url")
_G.discordia = require("discordia")
_G.client = discordia.Client({
	cacheAllMembers = true,
	autoReconnect = true,
})
_G.irc = require("irc")
discordia.extensions()
--client.cacheAllMembers = true

-- Get utils
dofile("util.lua")

if mbot.relay.enabled then
	dofile("relay.lua")
end

--[[ Register Commands ]]--

-- General Minetest command
mbot.register_command("minetest", {
	description = "General Minetest helpers.",
	usage = "Use empty command to see options.",
	aliases = {"mt"},
	func = function(message)
		-- Get arguments
		local args = message.content:split(" ")
		args[1] = args[1]:gsub(mbot.prefix, "")
		-- List of info
		local commands = {
			-- If empty
			default = {
				title = "Helpful Minetest Commands",
				fields = {
					{
						name = "Usage:",
						value = "`"..mbot.prefix.."minetest <command>`"
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
							name = "Use `"..mbot.prefix.."minetest install OShere` for OS-specific instructions.",
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
							value = "**[Google](https://www.google.com/) is your friend.**\n\nWhile slightly more involved, compiling works on any Linux distribution.\nSee `"..mbot.prefix.."minetest compile linux` for details."
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
							name = "Use `"..mbot.prefix.."minetest compile OShere` for OS-specific instructions.",
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
				color = mbot.color,
				-- OS-specific icon
				author = {
					name = content.name,
					icon_url = content.icon
				},
				fields = content.fields or {}
			}
		})
	end,
})

-- Server rules
mbot.register_command("rules", {
	description = "List rules.",
	usage = "rules [rule number]",
	aliases = {"r"},
	func = function(message)
		local msg = message.content
		if not message.guild then
			message.channel:send({
				content = "This command must be run in a server!"
			})
			return
		end
		-- Make sure we are a staff member
		if not message.member:getPermissions():__tostring():find("kickMembers") then
			message.channel:send({
				content = "You do not have the permissions to run this command!"
			})
			return
		end
		-- Do we have rules for this server?
		local servername = message.guild.name
		local server = mbot.servers[servername]
		if not server then
			return
		end
		local rules = server.rules
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
			if not mbot.servers[servername].rules[tonumber(rule)] then
				return
			end
			local rule_content = mbot.servers[servername].rules[tonumber(rule)]
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
				color = mbot.color,
				-- Get server icon
				author = {
					name = servername,
					icon_url = message.guild.iconURL
				},
				fields = content
			}
		})
	end,
})

-- ContentDB search
mbot.register_command("cdb", {
	description = "Search the ContentDB",
	usage = "cdb <search term>",
	aliases = {"mod", "modsearch", "search"},
	func = function(message)
		local msg = message.content
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
					color = mbot.color,
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
					color = mbot.color,
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
					color = mbot.color,
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
				url = "https://content.minetest.net/packages/"..author.."/"..name.."/",
				title = "**"..title.."**",
				description = "By "..author,
				color = mbot.color,
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
})

-- Minetest Modding Book search
mbot.register_command("modbook", {
	description = "Search the Modding Book",
	usage = "modbook [search term]",
	aliases = {"book"},
	func = function(message)
		local msg = message.content
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
			local max = 10
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
					color = mbot.color,
					footer = {
						icon_url =  message.author.avatarURL,
						text = "Page 1/"..pages.." | modbook"
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
						color = mbot.color,
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
					color = mbot.color,
				}
			})
		end
	end,
	page = function(page)
		local current_page = page.current
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
		local max = 10
		for i = 1,#results do
			if i > max*(current_page-1) and i <= max*(current_page) then
				fields[#fields+1] = results[i]
			end
		end
		return fields, "fields"
	end,
})

-- RTFM
mbot.register_command("lua_api", {
	description = "Get Lua API links",
	usage = "lua_api <search term>",
	aliases = {"api", "rtfm", "docs", "doc"},
	func = function(message)
		local msg = message.content
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
					color = mbot.color,
					fields = {
						{
							name = "lua_api.txt with nice formatting",
							value = "lua_api.txt but looks a little nicer. Located [here](https://rubenwardy.com/minetest_modding_book/lua_api.html)."
						},
						{
							name = "lua_api.txt (stable, "..mbot.stable_version..")",
							value = "Lua API in a text file (use CTRL+F). Located [here](https://github.com/minetest/minetest/blob/"..mbot.stable_version.."/doc/lua_api.txt)."
						},
						{
							name = "lua_api.txt (unstable, "..mbot.unstable_version..")",
							value = "Unstable Lua API in a text file (use CTRL+F). Located [here](https://github.com/minetest/minetest/blob/master/doc/lua_api.txt)."
						},
					}
				}
			})
		else
			-- Get the actual term
			local term = msg:sub(termidx+1)
			message.channel:send({
				embed = mbot.searchUrl(message.author, "https://github.com/minetest/minetest/blob/"..mbot.stable_version.."/doc/lua_api.txt", term, {
					icon = "https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Minetest-logo.svg/1024px-Minetest-logo.svg.png",
					title = "Minetest Lua API",
					max = 6,
				}, "lua_api")
			})
		end
	end,
	page = function(page)
		local embed = page.embed
		local desc = embed.description
		local term = desc:sub(desc:find("`")+1, desc:find("`%]")-1)
		local user = mbot.iconUser(embed)
		return mbot.searchUrl(user, "https://github.com/minetest/minetest/blob/0.4.17.1/doc/lua_api.txt", term, {
			icon = "https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Minetest-logo.svg/1024px-Minetest-logo.svg.png",
			title = "Minetest Lua API",
			max = 6,
		}, "lua_api", page.current), "embed"
	end,
})

-- GitHub file search
mbot.register_command("githubsearch", {
	description = "Search a GitHub file",
	usage = "githubsearch <url> <search term>",
	aliases = {"ghsearch", "github", "gh"},
	func = function(message)
		local msg = message.content
		-- Do we have a search term
		msg = msg:split(" ", 2)
		local url = msg[2]
		local term = msg[3]
		if not url then
			message.channel:send("Empty command!")
			return
		end
		if not term then
			message.channel:send("Empty search term!")
			return
		end
		if not url:find("github%.com/") then
			message.channel:send("Not a valid GitHub URL!")
			return
		end

		message.channel:send({
			embed = mbot.searchUrl(message.author, url, term, {
				title = "GitHub Search",
				max = 6,
			}, "githubsearch")
		})
	end,
	page = function(page)
		local embed = page.embed
		local desc = embed.description
		local term = desc:sub(desc:find("`")+1, desc:find("`%]")-1)
		local url = desc:sub(desc:find("%]%(")+2, desc:find("%)")-1)
		local user = mbot.iconUser(embed)
		return mbot.searchUrl(user, url, term, {
			title = "GitHub Search",
			max = 6,
		}, "githubsearch", page.current), "embed"
	end,
})

-- Let Me Google That For You
mbot.register_command("lmgtfy", {
	description = "Let Me Google That For You.",
	usage = "lmgtfy [-s|iie] [-g|y|d|b] <search term>",
	aliases = {"google", "www"},
	func = function(message)
		-- Get message and arguments
		local term = message.content:split(" ", 1)[2]
		if not term then
			message.channel:send("Empty command!")
			return
		end
		local args = term:split(" ", 2)
		local mode = 0
		local engine = "g"
		for _, arg in ipairs(args) do
			-- Did we get a specific search engine?
			local en_op = arg:match("^-[gybd]$")
			if en_op then
				engine = en_op:sub(2)
				term = term:gsub(en_op.." ", "", 1)
			-- Should we enable the Internet Explainer?
			elseif arg:match("^-iie$") then
				mode = 1
				term = term:gsub("-iie ", "", 1)
			-- Default mode
			elseif arg:match("^-s$") then
				mode = 0
				term = term:gsub("-s ", "", 1)
			end
		end
		local footer = ""
		if mode == 1 then
			footer = "Internet Explainer"
		end
		-- Search engine data
		local engines = {
			g = {
				icon = "https://cdn4.iconfinder.com/data/icons/new-google-logo-2015/400/new-google-favicon-512.png",
				name = "Google",
				color = "#4081EC",
			},
			y = {
				icon = "https://cdn1.iconfinder.com/data/icons/smallicons-logotypes/32/yahoo-512.png",
				name = "Yahoo",
				color = "#770094",
			},
			b = {
				icon = "https://cdn.icon-icons.com/icons2/1195/PNG/512/1490889706-bing_82538.png",
				name = "Bing",
				color = "#ECB726",
			},
			d = {
				icon = "https://cdn.icon-icons.com/icons2/844/PNG/512/DuckDuckGo_icon-icons.com_67089.png",
				name = "DuckDuckGo",
				color = "#D75531",
			},
		}
		message.channel:send({
			embed = {
				title = engines[engine].name.." Search:",
				thumbnail = {
					url = engines[engine].icon,
				},
				description = "[Search for `"..term.."`](http://lmgtfy.com/?s="..engine.."&iie="..mode.."&q="..url.escape(term)..").",
				color = mbot.getColor(engines[engine].color),
				footer = {
					text = footer
				}
			}
		})
	end,
})

-- Bot Info
mbot.register_command("info", {
	description = "Show MinetestBot info.",
	func = function(message)
		-- Get uptime
		local t = mbot.uptime:getTime():toTable()
		local check = {"weeks", "days", "hours", "minutes", "seconds"}
		local ustr = ""
		-- Format string
		for i = 1, 5 do
			local v = check[i]
			if t[v] == 0 then
				t[v] = nil
			else
				break
			end
		end
		for i = 1, #check do
			local v = check[i]
			if t[v] then
				local n = v
				if t[v] == 1 then
					n = n:sub(1,-2)
				end
				ustr = ustr..", "..t[v].." "..n:gsub("^%l", string.upper)
			end
		end

		local creator = client:getUser("286032516467654656")

		message.channel:send({
			embed = {
				title = "MinetestBot Info",
				thumbnail = {
					url = client.user:getAvatarURL(),
				},
				description = "Open-source, Lua-powered Discord bot providing useful Minetest features. Consider [donating](https://www.patreon.com/GreenXenith/).",
				fields = {
					{
						name = "Sauce",
						value = "<https://github.com/GreenXenith/minetestbot>"
					},
					{
						name = "Uptime",
						value = ustr:sub(3)
					},
				},
				color = mbot.color,
				footer = {
					icon_url = creator.avatarURL,
					text = "Created by "..creator.tag
				}
			}
		})
	end,
})

-- Bueller? Bueller?
mbot.register_command("ping", {
	description = "Answers with pong.",
	func = function(message)
		message.channel:send("🏓 Pong!")
	end,
})

--[[ Message Handling ]]--

-- Bot loaded
client:on("ready", function()
	-- client.user is the path for bot
	print("Logged in as ".. client.user.username)
end)

-- On receive message
client:on("messageCreate", function(message)
	-- Is this sent by someone other than self?
	if message.author.name ~= client.user.name then
		if message.content == client.user.mentionString then
			-- Send pingsock
			message.channel:send("<"..mbot.botEmoji().pingsock..">")
			return
		end

		-- Turn mention into prefix and split all arguments into a table 
		local args = message.content:gsub("^"..client.user.mentionString.." ", mbot.prefix):split(" ")

		-- Is it a command?
		if not args[1]:find("^"..mbot.prefix) then
			return
		end

		-- If so, execute it
		command = args[1]:sub(2)
		if mbot.aliases[command] then
			command = mbot.aliases[command]
		end
		if mbot.commands[command] then
			if mbot.commands[command].perms then
				for _, perm in pairs(mbot.commands[command].perms) do
					if not message.author:hasPermission(perm) then
						return
					end
				end
			end
			mbot.commands[command].func(message)
		end
			
		-- If we get this far, see if the command is 'help'
		if args[1] == mbot.prefix.."help" then
			local fields = {}
			local helplist = ""
			-- Did we specify a command?
			if args[2] then
				if mbot.aliases[args[2]] then
					args[2] = mbot.aliases[args[2]]
				end
				local cmd = mbot.commands[args[2]]
				if cmd and not cmd.secret then
					local infostr = ""
					-- Do we have aliases?
					if cmd.aliases then
						infostr = "Aliases:"
						-- If so, list them
						for _,aliase in pairs(cmd.aliases) do
							infostr = infostr.." "..aliase..","
						end
						infostr = infostr:sub(1,-2)
					end
					if cmd.description then
						if cmd.aliases then
							infostr = cmd.description.." | "..infostr
						else
							infostr = cmd.description
						end
					end
					local usg = ""
					if cmd.usage then
						usg = "Usage: `"..cmd.usage.."`"
					end
					if infostr ~= "" then
						infostr = infostr.."\n"..usg
					else
						infostr = usg
					end
					if infostr == "" then
						infostr = "⠀"
					end
					fields[1] = {
						name = "Command: `"..args[2].."`",
						value = infostr
					}
				else
					-- Throw fail
					message.channel:send({
						embed = {
							title = "Command \""..args[2].."\" does not exist.",
							color = mbot.color,
						}
					})
					return
				end
			else
				-- Get all commands
				for cmd, def in pairs(mbot.commands) do
					-- Is this a dev command?
					if not def.secret then
						local infostr = ""
						-- Do we have aliases?
						if def.aliases then
							infostr = "Aliases:"
							-- If so, list them
							for _,aliase in pairs(def.aliases) do
								infostr = infostr.." "..aliase..","
							end
							infostr = infostr:sub(1,-2)
						end
						if def.description then
							if def.aliases then
								infostr = def.description.." | "..infostr
							else
								infostr = def.description
							end
						end
						if infostr == "" then
							infostr = "⠀"
						end
						fields[#fields+1] = {
							name = "Command: `"..cmd.."`",
							value = infostr
						}
					end
				end
				helplist = " | See "..mbot.prefix.."help <command> for usage."
			end
			-- Send the message
			message.channel:send({
				embed = {
					title = "MinetestBot Commands:",
					thumbnail = {
						url = client.user:getAvatarURL()
					},
					color = mbot.color,
					fields = fields,
					footer = {
						text = "Prefix: ".. mbot.prefix..helplist
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
				local text = embed.footer.text:gsub(" |", ""):split(" ")
				-- Is this a scrolling message and can we work with it?
				if text[1] == "Page" and text[3] and mbot.commands[text[3]] then
					-- Are there enough pages to bother adding turners?
					local page_total = text[2]:match("%d*$")
					if tonumber(page_total) ~= 1 then
						message:addReaction("⬅")
						message:addReaction("➡")
					end
					message:addReaction("❌")
				end
			end
		end
	end
end)

client:on("reactionAdd", mbot.pageTurn)

client:on("reactionAddUncached", function(channel, messageId, hash, userId)
	local message = channel:getMessage(messageId)
	if message then
		local reaction = message.reactions:get(hash)
		if reaction then
			return mbot.pageTurn(reaction, userId)
		end
	end
end)

-- Run the bot :D
client:run(botSettings.token)

client:setGame({
	name = "no one.",
	url = "https://www.minetest.net/",
	type = 2,
})

mbot.uptime = discordia.Stopwatch()
