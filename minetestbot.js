const fs = require("fs");
const Discord = require("discord.js");
const {prefix, token} = require('./config.json');
const request = require("request");
const {sendGitHubEmbedReply} = require("./common.js");

// Error if missing configuration
if (!token || !prefix) {
	console.log("Error: Missing configurations! See config.json.example.");
	return;
}

const client = new Discord.Client();
client.commands = new Discord.Collection();

client.pages = new Discord.Collection();
client.pageControls = {
	prev: "⬅",
	next: "➡",
	exit: "🇽"
};

// Find term function
client.searchText = function (text, term) {
	let results = [];
	const lines = text.split("\n");
	for (let i = 0; i < lines.length; i++) {
		const l = lines[i];
		if (l.toLowerCase().includes(term.toLowerCase())) results.push([i + 1, l]);
	}
	return results;
}

// Load commands
const commandFiles = fs.readdirSync("./commands").filter(file => file.endsWith(".js"));
for (const file of commandFiles) {
	let command = require(`./commands/${file}`);
	if (typeof(command) === "function") command = command(client); // Pass client if needed
	client.commands.set(command.name, command);

	if (command.page) client.pages.set(command.name, command.page);
}

let mentionString = "";

client.once("ready", () => {
	console.log(`Logged in as ${client.user.tag}.`);
	mentionString = `<@!${client.user.id}>`

	client.user.setActivity("no one.", {type: "LISTENING"});
});

client.on("message", async message => {
	// Pingsock >:/
	if (message.content === mentionString) {
		const pingsock = client.guilds.cache.get("531580497789190145").emojis.cache.find(emoji => emoji.name === "pingsock");
		message.channel.send(`${pingsock}`);
		return;
	}

	if (message.author.bot) return;

	try {
		let p;
		if (message.content.startsWith(p = prefix) || message.content.startsWith(p = mentionString)) {
			const args = message.content.slice(p.length).trim().split(/ +/g);
			const commandName = args.shift().toLowerCase();

			const command = client.commands.get(commandName) ||
				client.commands.find(cmd => cmd.aliases && cmd.aliases.includes(commandName));
			if (command) {
				command.execute(message, args, client);
				return;
			}
		}
		// No valid command, look for #d+, referencing pulls or issues
		for (const match of message.content.matchAll(/#(\d+)/g)) {
			const number = match[1];
			request({
				url: "https://api.github.com/repos/minetest/minetest/issues/" + number,
				json: true,
				headers: {
					"User-Agent": "Minetest Bot"
				}
			}, function (err, res, pkg) {
				if (pkg.url) {
					sendGitHubEmbedReply(message, pkg);
				}
			});
		}
	} catch (error) {
		console.error(error);
		message.channel.send(":warning: Yikes, something broke.");
	}
});

// Page handler
client.on("messageReactionAdd", (reaction, user) => {
	const message = reaction.message;
	if (message.author != client.user || user == client.user) return; // Message author must be bot; Reactor must not be bot
	reaction.users.remove(user);

	if (!reaction.me) return;
	if (!message.embeds.length) return;
	const embed = message.embeds[0];

	let event = ""; // Unused internally; Up to commands to utilize if needed
	for (const [action, name] of Object.entries(client.pageControls)) {
		if (reaction.emoji.name === name) {
			event = action;
			break;
		}
	}

	if (event === "") return;
	if (event === "exit") {
		if (!embed.footer ||
			embed.footer.iconURL().match(/avatars\/(\d+)/)[1] == user.id ||
			message.guild.member(user).hasPermission("MANAGE_MESSAGES"))
			message.delete();
		return;
	} else {
		if (!embed.footer) return;
		if (!(new RegExp(/^Page /).test(embed.footer.text))) return; // Nothing to do if no pages

		const matches = embed.footer.text.match(/^Page (\d+) ?\/ ?(\d+) \| (.+)/);
		const commandName = matches[3];
		const command = client.pages.get(commandName)
		if (!command) return;

		let page = parseInt(matches[1]);
		const total = parseInt(matches[2]);

		switch (event) {
			case "next":
				page++;
				if (page > total) page = 1;
				break;
			case "prev":
				page--;
				if (page < 1) page = total;
				break;
		}

		// (message, current page, total pages, reaction event)
		command.execute(message, page, total, event);
	}
});

// Launch
client.login(token);
