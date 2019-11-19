const {color} = require("../config.js");
const request = require("request");

function score(term, check, add) {
	let s = 0;
	add = add || 0;
	term = term.toLowerCase();
	check = check.toLowerCase();

	if (check === term) {
		s = 2;
	} else if (check.match(term)) {
		s = 1;
	}

	return s + add;
}

function heuristics(body, term) {
	res = [];
	body.forEach(function(v, k) {
		res.push([
			score(term, v.name, 2) + score(term, v.title, 1) + score(term, v.short_description || ""), k
		]);
	})
	res.sort(function(a, b) {
		return b[0] - a[0];
	})
	return body[res[0][1]];
}

module.exports = {
	name: "cdb",
	aliases: ["contentdb", "mod", "modsearch", "search"],
	usage: "[search term]",
	description: "Search the ContentDB",
	execute: function(message, args) {
		if (!args.length) {
			const embed = {
				url: "https://content.minetest.net/",
				title: "**ContentDB**",
				description: "Minetest's official content repository.",
				color: color,
				thumbnail: {
					url: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Minetest-logo.svg/1024px-Minetest-logo.svg.png",
				},
				fields: [
					{
						name: "Usage:",
						value: "`<search term>`"
					}
				],
			};
			message.channel.send({embed: embed});
		} else {
			const term = args.join(" ");
			request({
				url: `https://content.minetest.net/api/packages/?q=${term}`,
				json: true,
			}, function(err, res, body) {
				if (!body.length) {
					const embed = {
						title: `Could not find any packages related to "${term}".`,
						color: color,
					};
					message.channel.send({embed: embed});
				} else {
					const meta = heuristics(body, term);
					request({
						url: `https://content.minetest.net/api/packages/${meta.author}/${meta.name}/`,
						json: true,
					}, function(err, res, pkg) {
						let desc = `${pkg.short_description}`;
						let info = [];
						if (pkg.forums) info.push(`[Forum thread](https://forum.minetest.net/viewtopic.php?t=${pkg.forums})`);
						if (pkg.repo) info.push(`[Git Repo](${pkg.repo})`);
						const embed = {
							url: encodeURI(`https://content.minetest.net/packages/${meta.author}/${meta.name}/`),
							title: `**${pkg.title}**`,
							description: `By ${pkg.author}`,
							color: color,
							image: {
								url: pkg.thumbnail
							},
							fields: [
								{
									name: "Description:",
									value: `${desc}\n${info.join(" | ")}`
								}
							]
						};
						message.channel.send({embed: embed});
					});
				}
			});
		}
	}
};
