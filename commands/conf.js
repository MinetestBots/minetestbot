const {color, version} = require("../config.js")
const minetest_logo = "https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Minetest-logo.svg/1024px-Minetest-logo.svg.png";
const confURL = `https://github.com/minetest/minetest/blob/${version}/minetest.conf.example`;
const rawURL = `https://raw.githubusercontent.com/minetest/minetest/${version}/minetest.conf.example`;
const pageSize = 6;
const pages = require("../pages.js");

module.exports = {
	name: "conf",
	aliases: ["mtconf"],
	usage: "<search term>",
	description: "Search minetest.conf.example",
	execute: async function(message, args) {
		if (!args.length) {
			const embed = {
				title: "Minetest Configuration",
				thumbnail: {
					url: minetest_logo,
				},
				color: color,
				fields: [
					{
						name: "minetest.conf.example (stable)",
						value: confURL,
					},
					{
						name: "minetest.conf.example (unstable)",
						value: "https://github.com/minetest/minetest/blob/master/minetest.conf.example"
					}
				]
			};
			const msg = await message.channel.send({embed: embed});
			pages.addControls(msg, false);
		} else {
			const term = args.join(" ");
			pages.getPage("conf", message, {
				url: {
					search: rawURL,
					display: confURL
				},
				page: 1,
				pageSize: pageSize,
				title: "Minetest Configuration",
				thumbnail: minetest_logo,
			}, term, async function(embed, results) {
				let turn = true;
				if (results.length > 100) turn = false;
				const msg = await message.channel.send({embed: embed});
				pages.addControls(msg, turn);
			});
		}
	},
	page: {
		execute: function(message, page) {
			const oldEmbed = message.embeds[0];
			const term = oldEmbed.description.match(/Results for \[`(.+)`\]/)[1];
			pages.getPage("conf", message, {
				url: {
					search: rawURL,
					display: confURL
				},
				page: page,
				pageSize: pageSize,
				title: "Minetest Configuration",
				thumbnail: minetest_logo,
			}, term, function(embed) {
				embed.footer.icon_url = oldEmbed.footer.iconURL;
				message.edit({embed: embed});
			});
		},
	}
};
