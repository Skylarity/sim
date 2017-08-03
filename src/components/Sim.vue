<template>
	<div class="sim">
		<h2>Sim:</h2>
		<div>
			id: {{ sim.id }}
			<br>
			name: {{ sim.name }}
		</div>
	</div>
</template>

<script>
import Sim from '../classes/Sim'

export default {
	name: 'hello',
	mounted () {
		this.sim = new Sim("Sim")
	},
	data () {
		return {
			sim: null
		}
	}
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.sim {
	font-family: monospace;
}
</style>
