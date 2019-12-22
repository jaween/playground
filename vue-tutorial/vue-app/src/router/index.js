import Vue from 'vue'
import Router from 'vue-router'
import Home from '@/components/Home'
import Another from '@/components/Another'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'Home',
      component: Home,
    },
    {
      path: '/another',
      name: 'Another',
      component: Another,
    },
  ]
})