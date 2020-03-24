const {gitHubSearchCommand} = require("../common.js");
module.exports = gitHubSearchCommand({
    name: "pull",
    aliases: ["pr"],
    usage: "<search term>",
    description: "Search Minetest pull requests on GitHub"
}, "pr");