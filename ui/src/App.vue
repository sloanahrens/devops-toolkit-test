<template>
  <div id="app">
    <b-navbar>
      <b-navbar-brand>
        <b-link to="/">
          <img class="site-logo" src="@/assets/logo.png" alt="Vue.js">
        </b-link>
        </b-navbar-brand>
        <div id="nav">
          <b-link to="/">Home</b-link> |
          <b-link to="/login" v-if="!currentUser">Log In</b-link>
          <b-link to="/logout" v-if="currentUser">Log Out ({{this.currentUser.username}})</b-link>
        </div>
    </b-navbar>
    <router-view/>
  </div>
</template>

<style>
html, body {
  width: 100%;
  height: 100%;
  margin: 0px;
  padding: 0px;
}
#app {
  width: 100%;
  height: 100%;
  font-family: Calibri, Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: left;
  color: #2c3e50;
  padding-left: 5%;
  padding-right: 5%;
}
 #main-container {
  width: 100%;
  height: calc(100% - 75px)
 }
#nav {
  padding: 30px;
}

#nav a {
  font-weight: bold;
  color: #2c3e50;
}

#nav a.router-link-exact-active {
  color: #42b983;
}

.bg-info {
  background-color: #375bae !important;
}

textarea.form-control.big-textarea {
  height: 10em;
}

textarea.form-control.really-big-textarea {
  height: 60em;
  font-size: 70%;
}

.site-logo {
    display: block;
    float: left;
    text-align: left;
    width: 120px;
}

.navbar-expand {
  justify-content: center;
}

</style>

<script>
import { authenticationService } from '@/_services'

export default {
  name: 'app',
  data () {
    return {
      currentUser: null
    }
  },
  created () {
    authenticationService.currentUser.subscribe(x => { this.currentUser = x })
  }
}
</script>
