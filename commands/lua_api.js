const {color, version} = require("../config.js")
const minetest_logo = "https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Minetest-logo.svg/1024px-Minetest-logo.svg.png";
const apiURL = `https://github.com/luanti-org/luanti/blob/${version}/doc/lua_api.md`;
const rawURL = `https://raw.githubusercontent.com/luanti-org/luanti/${version}/doc/lua_api.md`;
const pageSize = 6;
const pages = require("../pages.js");

module.exports = {
	name: "lua_api",
	aliases: ["api", "rtfm", "docs", "doc"],
	usage: "<search term>",
	description: "Get Lua API links or search the Lua API",
	execute: async function(message, args) {
		if (!args.length) {
			const embed = {
				title: "Lua API",
				thumbnail: {
					url: minetest_logo,
				},
				description: "Luanti Lua API Documentation",
				color: color,
				fields: [
					{
						name: `lua_api.md (stable, ${version})`,
						value: `Lua API in a text file (use CTRL+F). Located [here](${apiURL}).`
					},
					{
						name: "lua_api.md (unstable)",
						value: "Unstable Lua API in a text file (use CTRL+F). Located [here](https://github.com/luanti-org/luanti/blob/master/doc/lua_api.md)."
					},
					{
						name: "Read the Docs Luanti API",
						value: "lua_api.md with page formatting. Located [here](http://minetest.gitlab.io/minetest/)."
					}
				]
			};
			const msg = await message.channel.send({embed: embed});
			pages.addControls(msg, false);
		} else {
			const term = args.join(" ");
			pages.getPage("lua_api", message, {
				url: {
					search: rawURL,
					display: apiURL + "?plain=1",
				},
				page: 1,
				pageSize: pageSize,
				title: "Luanti Lua API",
				thumbnail: minetest_logo,
			}, term, async function(embed, results) {
				let turn = true;
				if (results.length <= pageSize || results.length > 100) turn = false;
				const msg = await message.channel.send({embed: embed});
				pages.addControls(msg, turn);
			});
		}
	},
	page: {
		execute: function(message, page) {
			const oldEmbed = message.embeds[0];
			const term = oldEmbed.description.match(/Results for \[`(.+)`\]/)[1];
			pages.getPage("lua_api", message, {
				url: {
					search: rawURL,
					display: apiURL + "?plain=1",
				},
				page: page,
				pageSize: pageSize,
				title: "Luanti Lua API",
				thumbnail: minetest_logo,
			}, term, function(embed) {
				embed.footer.icon_url = oldEmbed.footer.iconURL;
				message.edit({embed: embed});
			});
		},
	}
};
