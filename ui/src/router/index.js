import Vue from 'vue'
import { BootstrapVue, IconsPlugin } from 'bootstrap-vue'
import VueRouter from 'vue-router'
import Home from '../views/Home.vue'
import Login from '../views/Login.vue'
import Logout from '../views/Logout.vue'

import { authenticationService } from '@/_services'

Vue.use(VueRouter)
Vue.use(BootstrapVue)
Vue.use(IconsPlugin)

const routes = [
  {
    path: '/login',
    component: Login
  },
  {
    path: '/logout',
    component: Logout
  },
  {
    path: '/',
    name: 'Home',
    component: Home,
    meta: { authorize: [] }
  }
]

const router = new VueRouter({
  mode: 'hash',
  base: process.env.BASE_URL,
  routes
})

// router.beforeEach((to, from, next) => {
//   document.title = `${process.env.VUE_APP_TITLE + ' | ' + to.name || ''}`
//   next()
// })

// TODO: not sure about this, need to revisit
// let sessionRefreshChain = null
// const SESSION_REFRESH_PERIOD_SECONDS = 300

router.beforeEach((to, from, next) => {
  document.title = `${process.env.VUE_APP_TITLE + ' | ' + to.name || ''}`

  // redirect to login page if not logged in and trying to access a restricted page
  const { authorize } = to.meta
  const currentUser = authenticationService.currentUserValue

  console.debug('currentUser:', currentUser)

  if (authorize) {
    if (!currentUser) {
      // not logged in so redirect to login page with the return url
      return next({ path: '/login', query: { returnUrl: to.path } })
    }
  }

  return next()
})

export default router
