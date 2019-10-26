const {color} = require("../config.js");
const request = require("request");
const jsonURL = "https://rubenwardy.com/minetest_modding_book/sitemap.json";
const bookURL = "https://rubenwardy.com/minetest_modding_book/en/index.html";
const rubenAvatar = "https://avatars0.githubusercontent.com/u/2122943?s=460&v=4.png";

const pageSize = 6;
const pages = require("../pages.js");

function bookPage(message, page, func) {
	request({
		url: jsonURL,
		json: true,
	}, async function(err, res, body) {
		const embed = {
			title: "Minetest Modding Book",
			url: bookURL,
			thumbnail: {
				url: rubenAvatar,
			},
			description: "By Rubenwardy",
			color: color,
			footer: pages.pageFooter(message, "modbook", page, Math.ceil(body.length / pageSize)),
			fields: [],
		};

		let chapters = [];

		// Get chapters
		for (let i = 0; i < body.length; i++) {
			const c = body[i];
			if (c.chapter_number) {
				chapters.push(c)
			}
		}

		// Populate page
		for (let i = (page - 1) * pageSize; i < (page * pageSize); i++) {
			const c = chapters[i];
			if (!c) break;
			embed.fields.push({
				name: `**Chapter ${c.chapter_number}: ${c.title}**`,
				value: `${c.description || ""} [[Open]](${c.loc})`
			});
		}

		func(embed);
	});
}

module.exports = {
	name: "modbook",
	aliases: ["book", "mb"],
	usage: "[search term]",
	description: "Search Rubenwardy's Modding Book",
	execute: async function(message, args) {
		if(!args.length) {
			bookPage(message, 1, async function(embed) {
				const msg = await message.channel.send({embed: embed});
				pages.addControls(msg);
			});
		} else {
			const term = args[0].toLowerCase();
			request({
				url: jsonURL,
				json: true,
			}, async function(err, res, body) {
				let chapters = [];
				let chapter = 0;

				// Get chapters
				for (let i = 0; i < body.length; i++) {
					const c = body[i];
					if (c.chapter_number) {
						chapters.push(c)
					}
				}

				// Test for chapter number
				if (new RegExp(/^\d+$/).test(term)) {
					const ch = parseInt(term.match(/^(\d+)$/)[1]);
					if (chapters[ch - 1]) {
						chapter = ch;
					}					
				}

				// Search for term
				if (chapter === 0) {
					let results = [];
					for (let i = 0; i < chapters.length; i++) {
						const c = chapters[i];
						results.push([i, 0]);
						if (c.title.toLowerCase().includes(term)) results[i][1] += 2;
						if (c.description && c.description.toLowerCase().includes(term)) results[i][1] += 1;
					}
					results.sort(function(a, b) {return b[1] - a[1]});
					const top = results[0];
					if (top[1] > 0) {
						chapter = top[0] + 1;
					}
				}

				if (chapter != 0) {
					const c =  chapters[chapter - 1];
					const embed = {
						title: "Minetest Modding Book",
						url: bookURL,
						thumbnail: {
							url: rubenAvatar,
						},
						color: color,
						fields: [
							{
								name: `**Chapter ${c.chapter_number}: ${c.title}**`,
								value: `${c.description || ""} [[Open]](${c.loc})`
							}
						]
					};
					message.channel.send({embed: embed})
				} else {
					const embed = {
						title: `Could not find any chapter related to "${term}".`,
						color: color,
					};
					message.channel.send({embed: embed})
				}
			})
		}
	},
	page: {
		execute: function(message, page) {
			const oldEmbed = message.embeds[0]
			bookPage(message, page, function(embed) {
				embed.footer.icon_url = oldEmbed.footer.iconURL;
				message.edit({embed: embed});
			});
		}
	}
};
