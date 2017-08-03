export default class {
	constructor(name) {
		this.id = guid()
		this.name = name
	}
}

function guid() {
	return Math.floor((1 + Math.random()) * 0x10000)
		.toString(16)
		.substring(1)
}
