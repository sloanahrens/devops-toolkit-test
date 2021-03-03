<template>
  <div id="app">
    <div id="nav">
      <router-link to="/">Home</router-link>
    </div>
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
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
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
}

.site-logo {
    display: block;
    float: left;
    height: 32px;
    margin-right: 20px;
    overflow: hidden;
    padding: 20px 0 10px;
    text-align: left;
    text-indent: -5000px;
    width: 90px;
}
</style>
