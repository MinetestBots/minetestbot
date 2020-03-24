const {color} = require("./config.js");
const max_length = 256;
const {MessageEmbed} = require("discord.js");
function sendGitHubEmbedReply(message, issue) {
    let embed = new MessageEmbed();
    embed.setURL(issue.html_url);
    embed.setTitle(`**${issue.title.trim()}**`);
    embed.setAuthor(issue.user.login, issue.user.avatar_url, issue.user.html_url);
    embed.setDescription((issue.body.length > max_length) ? issue.body.substring(0, 256-3).trim()+"..." : issue.body);
    embed.setColor(color);
    const matches = issue.body.match(/!\[.*\]\((http.*)\)/);
    if (matches) {
        embed.setImage(matches[1]);
    }
    embed.setFooter((issue.pull_request ? "Pull Request":"Issue")+" #"+issue.number, "https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png")
    message.channel.send({embed: embed});
}
module.exports = {sendGitHubEmbedReply};