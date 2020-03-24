const {
    sendGitHubEmbedReply
} = require("../common.js");
const request = require("request");
module.exports = {
    name: "pull",
    aliases: ["pr"],
    usage: "[search term]",
    description: "Search Minetest pull requests on GitHub",
    execute: function (message, args) {
        request({
            url: "https://api.github.com/search/issues?q=is:pr+repo:minetest/minetest+" + encodeURI(args.join(" ")),
            json: true,
            headers: {
                "User-Agent": "Minetest Bot"
            }
        }, function (err, res, pkg) {
            sendGitHubEmbedReply(message, pkg.items[0]);
        });
    }
}