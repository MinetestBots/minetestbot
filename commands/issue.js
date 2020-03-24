const {sendGitHubEmbedReply} = require("../common.js");
const request = require("request");
module.exports = {
	name: "issue",
	aliases: ["bug", "problem", "request"],
	usage: "[search term]",
	description: "Search Minetest issues on GitHub",
	execute: function(message, args) {
        request({
            url: "https://api.github.com/search/issues?q=is:issue+repo:minetest/minetest+"+encodeURI(args.join(" ")),
            json: true,
            headers: {
                "User-Agent": "Minetest Bot"
            }
        }, function(err, res, pkg) {
            sendGitHubEmbedReply(message, pkg.items[0]);
        });
    }
}