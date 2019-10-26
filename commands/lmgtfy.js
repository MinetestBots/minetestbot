const {color} = require("../config.js");

module.exports = {
	name: "lmgtfy",
	usage: "[-x] [-g|y|d|b] <search term>",
	description: "Let Me Google That For You.",
	execute: function(message, args) {
		let iie = false;
		let engine = "g";
		let footer = "";

		const valid = ["g", "d", "b", "y"];
		const a = new RegExp(/^\-\w$/);

		while (a.test(args[0])) {
			const arg = args.shift().slice(1);
			if (valid.includes(arg)) {
				engine = arg;
			} else if (arg === "x") {
				iie = true;
				footer = "Internet Explainer";
			}
		}

		const engines = {
			g: {
				icon: "https://cdn4.iconfinder.com/data/icons/new-google-logo-2015/400/new-google-favicon-512.png",
				name: "Google",
				color: "4081EC",
			},
			y: {
				icon: "https://cdn1.iconfinder.com/data/icons/smallicons-logotypes/32/yahoo-512.png",
				name: "Yahoo",
				color: "770094",
			},
			b: {
				icon: "https://cdn.icon-icons.com/icons2/1195/PNG/512/1490889706-bing_82538.png",
				name: "Bing",
				color: "ECB726",
			},
			d: {
				icon: "https://cdn.icon-icons.com/icons2/844/PNG/512/DuckDuckGo_icon-icons.com_67089.png",
				name: "DuckDuckGo",
				color: "D75531",
			},
		};

		const term = args.join(" ");
		let embed = {};

		if (term === "") {
			embed = {
				title: "Empty search term.",
				color: color
			};
		} else {
			embed = {
				title: `${engines[engine].name} Search:`,
				thumbnail: {
					url: engines[engine].icon,
				},
				description: `[Search for "${term}"](http://lmgtfy.com/?s=${engine}&iie=${iie}&q=${encodeURI(term)}).`,
				color: parseInt(engines[engine].color, 16),
				footer: {
					text: footer
				}
			};
		}

		message.channel.send({embed: embed});
	}
};
