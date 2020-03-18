const {prefix} = require("../config.json");
const {color} = require("../config.js");

module.exports = {
	name: "help",
	description: "List available commands or info about a specific command.",
	aliases: ["commands"],
	usage: "[command name]",
	// cooldown: 5,
	execute(message, args) {
		const client = message.client;
		const {commands} = client;

		const fields = [];

		let append = "";

		if (!args.length) {
			commands.array().forEach((command) => {
				let desc = "No description.";
				if (command.description) desc = command.description;

				let aliases = "";
				if (command.aliases) aliases = ` | Aliases: ${command.aliases.join(", ")}`;

				fields.push({
					name: `Command: \`${command.name}\``,
					value: `${desc}${aliases}`
				})
			})

			append =  ` | See ${prefix}help <command> for usage.`;
		} else {
			const name = args[0].toLowerCase();
			const command = commands.get(name) || commands.find(c => c.aliases && c.aliases.includes(name));

			if (!command) {
				message.channel.send({embed: {
					color: color,
					title: `Command "${name}" does not exist.`,
					timestamp: new Date(),
					footer: {
						text: `Use ${prefix}help to list all commands.`
					},
				}});
				return;
			}

			let desc = "No description.";
			if (command.description) desc = command.description;

			let aliases = "";
			if (command.aliases) aliases = ` | Aliases: ${command.aliases.join(", ")}`;

			let usage = "";
			if (command.usage) usage = `\nUsage: \`${command.usage}\``;
			fields.push({
				name: `Command: \`${command.name}\``,
				value: `${desc}${aliases}${usage}`
			})
		}

		const embed = {
			color: color,
			title: `${client.user.username} Commands:`,
			thumbnail: {
				url: client.user.avatarURL(),
			},
			fields: fields,
			timestamp: new Date(),
			footer: {
				text: `Prefix: ${prefix}${append}`
			},
		};

		if (args.length) {
			message.channel.send({embed: embed});
		} else {
			return message.author.send({embed: embed}).then(() => {
				if (message.channel.type === "dm") return;
				message.reply("I\'ve sent you a DM with all my commands.");
			}).catch(error => {
				console.error(`Could not send help DM to ${message.author.tag}.\n`, error);
				message.reply("help DM couldn't be sent, do you have DMs disabled?");
			});
		}
	},
};
