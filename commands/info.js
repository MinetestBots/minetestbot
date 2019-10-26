const {color} = require("../config.js");

function pluralize(time, period) {
	const msg = `${time.toString()} ${period}`;
	if (time > 1) {
		return  `${msg}s, `;
	} else if (time == 0) {
		return "";
	}
	return `${msg}, `;
}

function duration(ms) {
	let sec = (ms / 1000) | 0;
	
	let min = (sec / 60) | 0;
	sec -= min * 60;
	
	let hrs = (min / 60) | 0;
	min -= hrs * 60;
	
	let day = (hrs / 24) | 0;
	hrs -= day * 24;
	
	let wks = (day / 7) | 0;
	day -= wks * 7;

	return `${pluralize(wks, "week")}${pluralize(day, "day")}${pluralize(hrs, "hour")}${pluralize(min, "minute")}${pluralize(sec, "second").slice(0, -2)}.`;
}

module.exports = {
	name: "info",
	aliases: ["about"],
	description: "Bot info.",
	execute(message) {
		const client = message.client;
		const creator = client.users.get("286032516467654656");
		const embed = {
			color: color,
			title: `${client.user.username} Info`,
			description: "Open-source, JavaScript-powered, Discord bot providing useful Minetest features. Consider [donating](https://www.patreon.com/GreenXenith/).",
			thumbnail: {
				url: client.user.avatarURL,
			},
			fields: [
				{
					name: "Sauce",
					value: "<https://github.com/GreenXenith/minetestbot>"
				},
				{
					name: "Uptime",
					value: duration(client.uptime)
				},
			],
			timestamp: new Date(),
			footer: {
				text: `Created by ${creator.tag}`,
				icon_url: creator.avatarURL,
			},
		};

		message.channel.send({embed: embed});
	},
};
