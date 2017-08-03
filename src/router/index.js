import Vue from 'vue'
import Router from 'vue-router'
import Sim from '@/components/Sim'

Vue.use(Router)

export default new Router({
	routes: [
		{
			path: '/',
			name: 'Sim',
			component: Sim
		}
	]
})
