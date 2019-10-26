module.exports = {
	name: "ping",
	description: "Ping pong.",
	execute(message) {
		const res = ":ping_pong: Pong.";
		message.channel.send(res + "..").then(msg => {
			const ping = msg.createdTimestamp - message.createdTimestamp
			msg.edit(`${res} ${ping}ms.`);
		})
	},
};
