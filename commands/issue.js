const {gitHubSearchCommand} = require("../common.js");
module.exports = gitHubSearchCommand({
	name: "issue",
	aliases: ["bug", "problem", "request"],
	usage: "<search term>",
	description: "Search Luanti issues on GitHub",
}, "issue");
