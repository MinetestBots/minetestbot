const {gitHubSearchCommand} = require("../common.js");
module.exports = gitHubSearchCommand({
	name: "pull",
	aliases: ["pr"],
	usage: "<search term>",
	description: "Search Luanti pull requests on GitHub"
}, "pr");
