const request = require("request");
const {color} = require("./config.js");

module.exports = {
	searchText: function(text, term) {
		let results = [];
		const lines = text.split("\n");
		for (let i = 0; i < lines.length; i++) {
			const l = lines[i];
			if (l.toLowerCase().includes(term.toLowerCase())) results.push([i + 1, l]);
		}
		return results;
	},
	pageFooter: function(message, command, page, total) {
		return {
			icon_url: message.author.avatarURL,
			text: `Page ${page} / ${total} | ${command}`
		};
	},
	getPage: function(command, message, config, term, func) {
		request(`${config.url.search}`, async function (err, res, body) {
			if (err || res.statusCode != 200) {
				message.channel.send(":warning: Something went wrong.");
				return;
			}

			let embed = {};
			const fields = [];
			const results = await module.exports.searchText(body, term);

			if (results.length > 100) {
				embed = {
					title: "Error: Result overflow!",
					description: `Got ${results.length} results. Search [the page](${config.url.display}) manually instead.`,
					color: color
				};
			} else {
				for (let i = (config.page - 1) * config.pageSize; i < (config.page * config.pageSize); i++) {
					const res = results[i];
					if (!res) break;
					fields.push({
						name: `Line ${res[0]}:`,
						value: `[\`\`\`\n${res[1]}\n\`\`\`](${config.url.display}#L${res[0]})`
					})
				}
				
				embed = {
					title: config.title,
					thumbnail: {
						url: config.thumbnail
					},
					description: `Results for [\`${term}\`](${config.url.display}):`,
					color: color,
					footer: module.exports.pageFooter(message, command, config.page, Math.ceil(results.length / config.pageSize)),
					fields: fields
				};
			}

			func(embed, results);
		})
	},
	addControls: async function(message, turn, exit) {
		try {
			const controls = message.client.pageControls;
			if (turn != false) {
				await message.react(controls.prev);
				await message.react(controls.next);
			}
			if (exit != false) await message.react(controls.exit);
		} catch (error) {
			console.error(`Failed to add page controls. Error: ${error}`);
		}
	}
}
