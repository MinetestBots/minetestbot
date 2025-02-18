const {prefix} = require("../config.json");
const {color, version} = require("../config.js");
const luanti_logo = "https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Minetest-logo.svg/1024px-Minetest-logo.svg.png";
function getDaysSince(dateString) {
    const [day, month, year] = dateString.split('-');
    const startDate = new Date(year, month - 1, day); // month is 0-indexed in JS Date
    const currentDate = new Date();

    // Calculate the time difference in milliseconds
    const timeDifference = currentDate.getTime() - startDate.getTime();

    // Convert milliseconds to days and round down
    const daysSince = Math.floor(timeDifference / (1000 * 3600 * 24));

    return daysSince;
}

const rename_date = getDaysSince("13-10-2024");

const commands = {
	default: {
		title: "Helpful Luanti Commands",
		fields: [
			{
				name: "Usage:",
				value: `\`${prefix}luanti <command>\``
			},
			{
				name: "Avaliable commands:",
				value: "```\ninstall\ncompile\nabout```"
			},
		]
	},
	install: {
		default: {
			name: "Install Luanti",
			url: "https://www.luanti.org/downloads/",
			title: "Downloads for Luanti are located here.",
			fields: [
				{
					name: `Use \`${prefix}luanti install OShere\` for OS-specific instructions.`,
					value: "```\nlinux\nwindows\nmac\nandroid\nios```"
				},
			]
		},
		linux: {
			name: "Install Luanti (Linux)",
			icon: "http://www.stickpng.com/assets/images/58480e82cef1014c0b5e4927.png",
			title: "The recommended way to install Luanti on Linux is through your package manager.\nNote: the version shipped by default may be out of date.\nIn which case, you can use a PPA (if applicable), or compiling may be a better option.",
			fields: [
				{
					name: "__For Debian/Ubuntu-based Distributions:__",
					value: "Open a terminal and run these 3 commands:\n```sudo add-apt-repository ppa:minetestdevs/stable\nsudo apt update\nsudo apt install minetest```"
				},
				{
					name: "__For Arch Distributions:__",
					value: "Open a terminal and run this command:\n```sudo pacman -S luanti```"
				},
				{
					name: "Again, this will vary depending on your distribution. ",
					value: `**[Google](https://www.google.com/) is your friend.**\n\nWhile slightly more involved, compiling works on any Linux distribution.\nSee \`${prefix}minetest compile linux\` for details.`
				},
			]
		},
		windows: {
			name: "Install Luanti (Windows)",
			icon: "http://pngimg.com/uploads/windows_logos/windows_logos_PNG25.png",
			title: "Installing Luanti on Windows is quite simple.",
			fields: [
				{
					name: "__Download:__",
					value: "Visit https://www.luanti.org/downloads/, navigate to the Windows downloads, and download the proper package for your system."
				},
				{
					name: "__Installation:__",
					value: "Extract your Luanti folder to the location of your choice.\n\nThe executable is located in `YOUR-DIR-PATH\\minetest\\bin\\`.\n\nCreate a desktop link to the executable."
				},
			]
		},
		mac: {
			name: "Install Luanti (MacOS)",
			icon: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bb/OS_X_El_Capitan_logo.svg/1024px-OS_X_El_Capitan_logo.svg.png",
			title: "Installing Luanti on MacOS is about as simple as it gets.",
			fields: [
				{
					name: "__Installation:__",
					value: "Open a terminal.\n\nMake sure you have [homebrew](https://brew.sh/) installed!\nRun:\n```brew install luanti```"
				},
			]
		},
		android: {
			name: "Install Luanti (Android)",
			icon: "https://cdn.freebiesupply.com/logos/large/2x/android-logo-png-transparent.png",
			title: "Luanti on mobile devices is not the best experience, but it slowly gets less bad..",
			fields: [
				{
					name: "__Download:__",
					value: "Navigate to the Google Play Store.\n\nSearch for and download the [official Luanti app](https://play.google.com/store/apps/details?id=net.minetest.minetest)."
				},
			]
		},
		ios: {
			name: "Install Luanti (iOS)",
			icon: "https://png.icons8.com/color/1600/ios-logo.png",
			title: "Step one: Switch to an Android device!",
			fields: [
				{
					name: "__Installation:__",
					value: "No, seriously. There is no official Luanti app on the app store for iOS devices.\nHowever, there are more than enough \"clones\" full of ads and bugs you could try if you really wanted to."
				},
			]
		},
	},
	compile: {
		default: {
			name: "Compile Luanti",
			url: "https://docs.luanti.org/compiling/",
			title: "Compiling instructions are located here.",
			fields: [
				{
					name: `Use \`${prefix}luanti compile OShere\` for OS-specific instructions.`,
					value: "```\nlinux\nwindows```"
				},
			]
		},
		linux: {
			name: "Compile Luanti (Linux)",
			icon: "http://www.stickpng.com/assets/images/58480e82cef1014c0b5e4927.png",
			title: "Compiling on Linux will allow you to view and modify the source code yourself, as well as run multiple Luanti builds.",
			fields: [
				{
					name: "__Compiling:__",
					value: "Open a terminal.\n\nInstall dependencies. Here's an example for Debian-based and Ubuntu-based distributions:\n```apt install build-essential cmake git libirrlicht-dev libbz2-dev libgettextpo-dev libfreetype6-dev libpng12-dev libjpeg8-dev libxxf86vm-dev libgl1-mesa-dev libsqlite3-dev libogg-dev libvorbis-dev libopenal-dev libhiredis-dev libcurl3-dev```\n\nDownload the engine:```git clone https://github.com/luanti-org/luanti.git cd luanti/```\n\nDownload Minetest Game:\n```cd games/ git clone https://github.com/luanti-org/minetest_game.git cd ../```\n\nBuild the game (the make command is set to automatically detect the number of CPU threads to use):\n```cmake . -DENABLE_GETTEXT=1 -DENABLE_FREETYPE=1 -DENABLE_LEVELDB=1 -DENABLE_REDIS=1\nmake -j$(grep -c processor /proc/cpuinfo)```\n\nFor more information, see https://github.com/luanti-org/luanti/blob/master/doc/compiling/linux.md."
				},
			]
		},
		windows: {
			name: "Compile Luanti (Windows)",
			icon: "http://pngimg.com/uploads/windows_logos/windows_logos_PNG25.png",
			title: "Compiling on Windows is not an easy task, and is not going to be covered easily by me.",
			fields: [
				{
					name: "__Compiling:__",
					value: "Please see https://github.com/luanti-org/luanti/blob/master/doc/compiling/windows.md for instructions on compiling Luanti on Windows."
				},
			]
		},
	},
	about: {
		default: {
			name: "About Luanti",
			icon: luanti_logo,
			fields: [
				{
					name: "Features",
					value: "https://www.luanti.org/#Features"
				},
				{
					name: "Latest Version",
					value: `[${version}](https://www.github.com/luanti-org/luanti/releases/latest)`
				},
                {
                    name: "See also: ",
                    value: "```\nabout renaming```"
                }
			]
		},
        renaming: {
            name: "Our New Name",
            title: "Introducing Our New Name",
            url: "https://blog.luanti.org/2024/10/13/Introducing-Our-New-Name/",
            icon: luanti_logo,
            fields: [
                {
                    name: "The new name was announced on October 13th, 2024.",
                    value: `That was ${rename_date} days ago.`
                }
            ]
        }
	}
};

module.exports = {
	name: "luanti",
	aliases: ["lt"],
	description: "General Luanti helpers.",
	usage: "Use empty command to see options.",
	execute(message, args) {
		let content = {};
		if (!args[0]) {
			content.title = commands.default.title;
			content.fields = commands.default.fields;
			content.name = "Luanti";
			content.icon = luanti_logo;
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
