const {valid_issue_states} = require("./config.json");
const valid_issue_states_lookup = {}
for (const state of valid_issue_states) {
	valid_issue_states_lookup[state] = true;
}
const {color} = require("./config.js");
const max_length = 256;
const {MessageEmbed} = require("discord.js");
const request = require("request");

function sendGitHubEmbedReply(message, issue) {
	let embed = new MessageEmbed();
	if (!valid_issue_states_lookup[issue.state]) {
		return;
	}
	embed.setURL(issue.html_url);
	embed.setTitle(`**${issue.title.trim()}**`);
	embed.setAuthor(issue.user.login, issue.user.avatar_url, issue.user.html_url);
	embed.setDescription((issue.body.length > max_length) ? issue.body.substring(0, 256 - 3).trim() + "..." : issue.body);
	embed.setColor(color);
	const matches = issue.body.match(/!\[.*\]\((http.*)\)/);
	if (matches) {
		embed.setImage(matches[1]);
	}
	embed.setFooter((issue.pull_request ? "Pull Request" : "Issue") + " #" + issue.number, "https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png")
	message.channel.send({
		embed: embed
	});
}

function gitHubSearchCommand(def, type) {
	def.execute = function(message, args) {
		if (args.length === 0) {
			message.channel.send({embed: {color: color, title: "Empty search term."}})
		} else {
			request({
				url: `https://api.github.com/search/issues?q=is:${type}+repo:minetest/minetest+${encodeURI(args.join(" "))}`,
				json: true,
				headers: {
					"User-Agent": "Minetest Bot"
				}
			}, function(err, res, pkg) {
				sendGitHubEmbedReply(message, pkg.items[0]);
			});
		}
	}
	return def;
}

module.exports = {
	sendGitHubEmbedReply,
	gitHubSearchCommand
};
