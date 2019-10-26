const {prefix} = require("../config.json");
const {color, version} = require("../config.js");
const minetest_logo = "https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Minetest-logo.svg/1024px-Minetest-logo.svg.png";
const commands = {
	default: {
		title: "Helpful Minetest Commands",
		fields: [
			{
				name: "Usage:",
				value: `\`${prefix}minetest <command>\``
			},
			{
				name: "Avaliable commands:",
				value: "```\ninstall\ncompile\nabout```"
			},
		]
	},
	install: {
		default: {
			name: "Install Minetest",
			url: "https://www.minetest.net/downloads/",
			title: "Downloads for Minetest are located here.",
			fields: [
				{
					name: `Use \`${prefix}minetest install OShere\` for OS-specific instructions.`,
					value: "```\nlinux\nwindows\nmac\nandroid\nios```"
				},
			]
		},
		linux: {
			name: "Install Minetest (Linux)",
			icon: "http://www.stickpng.com/assets/images/58480e82cef1014c0b5e4927.png",
			title: "The recommended way to install Minetest on Linux is through your package manager.\nNote: the version shipped by default may be out of date.\nIn which case, you can use a PPA (if applicable), or compiling may be a better option.",
			fields: [
				{
					name: "__For Debian/Ubuntu-based Distributions:__",
					value: "Open a terminal and run these 3 commands:\n```sudo add-apt-repository ppa:minetestdevs/stable\nsudo apt update\nsudo apt install minetest```"
				},
				{
					name: "__For Arch Distributions:__",
					value: "Open a terminal and run this command:\n```sudo pacman -S minetest```"
				},
				{
					name: "Again, this will vary depending on your distribution. ",
					value: `**[Google](https://www.google.com/) is your friend.**\n\nWhile slightly more involved, compiling works on any Linux distribution.\nSee \`${prefix}minetest compile linux\` for details.`
				},
			]
		},
		windows: {
			name: "Install Minetest (Windows)",
			icon: "http://pngimg.com/uploads/windows_logos/windows_logos_PNG25.png",
			title: "Installing Minetest on Windows is quite simple.",
			fields: [
				{
					name: "__Download:__",
					value: "Visit https://www.minetest.net/downloads/, navigate to the Windows downloads, and download the proper package for your system."
				},
				{
					name: "__Installation:__",
					value: "Extract your Minetest folder to the location of your choice.\n\nThe executable is located in `YOUR-DIR-PATH\\minetest\\bin\\`.\n\nCreate a desktop link to the executable."
				},
			]
		},
		mac: {
			name: "Install Minetest (MacOS)",
			icon: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bb/OS_X_El_Capitan_logo.svg/1024px-OS_X_El_Capitan_logo.svg.png",
			title: "Installing Minetest on MacOS is about as simple as it gets.",
			fields: [
				{
					name: "__Installation:__",
					value: "Open a terminal.\n\nMake sure you have [homebrew](https://brew.sh/) installed!\nRun:\n```brew install minetest```"
				},
			]
		},
		android: {
			name: "Install Minetest (Android)",
			icon: "https://cdn.freebiesupply.com/logos/large/2x/android-logo-png-transparent.png",
			title: "Minetest on mobile devices is not the best experience, but if you really must..",
			fields: [
				{
					name: "__Download:__",
					value: "Navigate to the Google Play Store.\n\nSearch for and download the [official Minetest app](https://play.google.com/store/apps/details?id=net.minetest.minetest).\n\nOptionally, you may also download [Rubenwardy's Minetest Mods app](https://play.google.com/store/apps/details?id=com.rubenwardy.minetestmodmanager)."
				},
			]
		},
		ios: {
			name: "Install Minetest (iOS)",
			icon: "https://png.icons8.com/color/1600/ios-logo.png",
			title: "Step one: Switch to an Android device!",
			fields: [
				{
					name: "__Installation:__",
					value: "No, seriously. There is no official Minetest app on the app store for iOS devices.\nHowever, there are more than enough \"clones\" full of ads and bugs you could try if you really wanted to."
				},
			]
		},
	},
	compile: {
		default: {
			name: "Compile Minetest",
			url: "https://dev.minetest.net/Compiling_Minetest",
			title: "Compiling instructions are located here.",
			fields: [
				{
					name: `Use \`${prefix}minetest compile OShere\` for OS-specific instructions.`,
					value: "```\nlinux\nwindows```"
				},
			]
		},
		linux: {
			name: "Compile Minetest (Linux)",
			icon: "http://www.stickpng.com/assets/images/58480e82cef1014c0b5e4927.png",
			title: "Compiling on Linux will allow you to view and modify the source code yourself, as well as run multiple Minetest builds.",
			fields: [
				{
					name: "__Compiling:__",
					value: "Open a terminal.\n\nInstall dependencies. Here's an example for Debian-based and Ubuntu-based distributions:\n```apt install build-essential cmake git libirrlicht-dev libbz2-dev libgettextpo-dev libfreetype6-dev libpng12-dev libjpeg8-dev libxxf86vm-dev libgl1-mesa-dev libsqlite3-dev libogg-dev libvorbis-dev libopenal-dev libhiredis-dev libcurl3-dev```\n\nDownload the engine:```git clone https://github.com/minetest/minetest.git cd minetest/```\n\nDownload Minetest Game:\n```cd games/ git clone https://github.com/minetest/minetest_game.git cd ../```\n\nBuild the game (the make command is set to automatically detect the number of CPU threads to use):\n```cmake . -DENABLE_GETTEXT=1 -DENABLE_FREETYPE=1 -DENABLE_LEVELDB=1 -DENABLE_REDIS=1\nmake -j$(grep -c processor /proc/cpuinfo)```\n\nFor more information, see https://dev.minetest.net/Compiling_Minetest#Compiling_on_GNU.2FLinux."
				},
			]
		},
		windows: {
			name: "Compile Minetest (Windows)",
			icon: "http://pngimg.com/uploads/windows_logos/windows_logos_PNG25.png",
			title: "Compiling on Windows is not an easy task, and is not going to be covered easily by me.",
			fields: [
				{
					name: "__Compiling:__",
					value: "Please see https://dev.minetest.net/Compiling_Minetest#Compiling_on_Windows for instructions on compiling Minetest on Windows."
				},
			]
		},
	},
	about: {
		default: {
			name: "About Minetest",
			icon: minetest_logo,
			fields: [
				{
					name: "Features",
					value: "https://www.minetest.net/#Features"
				},
				{
					name: "Latest Version",
					value: `[${version}](https://www.github.com/minetest/minetest/releases/latest)`
				}
			]
		},
	}
};

module.exports = {
	name: "minetest",
	aliases: ["mt"],
	description: "General Minetest helpers.",
	usage: "Use empty command to see options.",
	execute(message, args) {
		let content = {};
		if (!args[0]) {
			content.title = commands.default.title;
			content.fields = commands.default.fields;
			content.name = "Minetest";
			content.icon = minetest_logo;
		} else {
			if (!commands[args[0]]) return;

			if (!args[1]) args[1] = "default";
			if (!commands[args[0]][args[1]]) return;

			content.url = commands[args[0]][args[1]].url;
			content.title = commands[args[0]][args[1]].title;
			content.fields = commands[args[0]][args[1]].fields;
			content.name = commands[args[0]][args[1]].name;
			content.icon = commands[args[0]][args[1]].icon;
		}

		const embed = {
			url: content.url || "",
			title: content.title,
			color: color,
			author: {
				name: content.name,
				icon_url: content.icon
			},
			fields: content.fields || []
		};

		// Send the message
		message.channel.send({embed: embed});
	}
}
