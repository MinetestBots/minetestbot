const fs = require("fs");
const Discord = require("discord.js");
const {prefix, token} = require('./config.json');

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
client.searchText = function(text, term) {
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
	mentionString = `<@${client.user.id}>`

	client.user.setActivity("no one.", {type: "LISTENING"});
});

client.on("message", async message => {
	// Pingsock >:/
	if (message.content === mentionString) {
		const pingsock = client.guilds.get("531580497789190145").emojis.find(emoji => emoji.name === "pingsock");
		message.channel.send(`${pingsock}`);
		return;
	}

	if (message.author.bot) return;

	// Try prefix first, then mentionString (could probably be done better)
	let p = prefix;
	if (!message.content.startsWith(p)) {
		p = `${mentionString} `;
		if (!message.content.startsWith(p)) return;
	}

	const args = message.content.slice(p.length).trim().split(/ +/g);
	const commandName = args.shift().toLowerCase();

	const command = client.commands.get(commandName)
		|| client.commands.find(cmd => cmd.aliases && cmd.aliases.includes(commandName));

	if (!command) return;

	try {
		command.execute(message, args, client);
	} catch(error) {
		console.error(error);
		message.channel.send(":warning: Yikes, something broke.");
	}
});

// Page handler
client.on("messageReactionAdd", (reaction, user) => {
	const message = reaction.message;
	if (message.author != client.user || user == client.user) return; // Message author must be bot; Reactor must not be bot

	if (!message.embeds.length) return;
	const embed = message.embeds[0];

	if (!embed.footer) return;
	if (!(new RegExp(/^Page /).test(embed.footer.text))) return;
	const matches = embed.footer.text.match(/^Page (\d+) ?\/ ?(\d+) \| (.+)/);
	const commandName = matches[3];
	const command = client.pages.get(commandName)

	if (!command || !reaction.me) return;

	let event = ""; // Unused internally; Up to commands to utilize if needed
	for (const [action, name] of Object.entries(client.pageControls)) {
		if (reaction.emoji.name === name) {
			event = action;
			break;
		}
	}
	if (event === "") return;

	let page = parseInt(matches[1]);
	const total = parseInt(matches[2]);

	switch(event) {
		case "next":
			page++;
			if (page > total) page = 1;
			break;
		case "prev":
			page--;
			if (page < 1) page = total;
			break;
		case "exit":
			const authorID = embed.footer.iconURL.match(/avatars\/(\d+)/)[1];
			if (authorID == user.id ||
				message.guild.member(user).hasPermission("MANAGE_MESSAGES")) message.delete();
			return;
	}

	// (message, current page, total pages, reaction event)
	command.execute(message, page, total, event);
	reaction.remove(user);
});

// Launch
client.login(token);
