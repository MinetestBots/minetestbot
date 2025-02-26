const config = require("./config.json");
const request = require("sync-request");

let version = "";

console.log("Loading configurations...");
const res = request("GET", "https://api.github.com/repos/luanti-org/luanti/releases/latest", {
	headers: {
		"User-Agent": "https://github.com/GreenXenith/minetestbot/ Luanti latest version fetcher"
	}
});
version = JSON.parse(res.getBody('utf8')).tag_name;

if (!config.color) config.color = "#66601c"; // Configure your bot color or I'll pick an ugly one for you

module.exports = {
	color: parseInt(config.color.replace("#", ""), 16),
	version: version,
};
