<template>
  <div>
    <b-row class="mb-2">
      <b-col sm="3"></b-col>
      <b-col sm="6">
        <b-alert
          variant="success"
          :show="logged_out"
        >Logged out
        </b-alert>
        <span class="spinner-border spinner-border-sm" v-show="loading"></span>
      </b-col>
      <b-col sm="3"></b-col>
    </b-row>
  </div>
</template>

<script>
import { authenticationService } from '@/_services'
import router from '@/router'

export default {
  name: 'logout',
  data () {
    return {
      logged_out: false,
      loading: false
    }
  },
  created () {
    this.loading = true
    authenticationService.logout()
      .then(
        () => {
          this.loading = false
          this.logged_out = true
          setTimeout(() => {
            router.push('/login')
          }, 3 * 1000)
        }
      )
  }
}
</script>
