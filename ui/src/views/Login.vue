<template>
  <div>
    <b-alert variant="danger" :show="showErrorAlert">ERROR: {{ this.error }}</b-alert>

    <b-alert variant="warning" :show="showSessionAlert">Session has expired. Please log in again.</b-alert>
    <b-container>
      <b-row class="mb-2 justify-content-sm-center">
        <b-col sm="5" align-self="center">
          <b-card class="mt-5">
            <h3 class="mb-3">Log in</h3>

            <b-form @submit="createSession">
              <b-row class="mb-2">
                <b-col class="text-sm-left">
                  <InputGroup
                    @result="verificationData.username = $event"
                    ref="username"
                    :validators="['required', 'username']"
                    groupID="username-group"
                    inputID="username"
                    icon="envelope"
                    type="text"
                    errorDescribedBy="username-feedback"
                    placeholder="Username"
                  />
                </b-col>
              </b-row>

              <b-row class="mb-2">
                <b-col class="text-sm-left">
                  <b-input-group id="password-group" class="mt-1 mb-2">
                    <b-input-group-prepend is-text>
                      <b-icon icon="shield-lock-fill" variant="primary"></b-icon>
                    </b-input-group-prepend>

                    <b-form-input
                      id="password"
                      name="password"
                      :type="passwordFieldType"
                      v-model="verificationData.password"
                      placeholder="Password"
                    ></b-form-input>

                    <b-input-group-append
                      is-text
                      @click="passwordFieldType = passwordFieldType === 'password' ? 'text' : 'password'"
                    >
                      <b-icon
                        :icon="passwordFieldType === 'password' ? 'eye' : 'eye-slash'"
                        variant="primary"
                      ></b-icon>
                    </b-input-group-append>
                  </b-input-group>
                </b-col>
              </b-row>

              <b-row class="mb-2">
                <b-col class="text-sm-right mt-2">
                  <b-button type="submit" variant="primary">
                    <span class="spinner-border spinner-border-sm mr-1" v-show="loading"></span>
                    <span>Log in</span>
                  </b-button>
                </b-col>
              </b-row>
            </b-form>
          </b-card>
        </b-col>
      </b-row>
    </b-container>
  </div>
</template>

<script>
import { authenticationService } from '@/_services'
import router from '@/router'

import InputGroup from '../components/InputGroup'
export default {
  name: 'logout',
  components: {
    InputGroup
  },
  data () {
    return {
      verificationData: {
        username: '',
        password: ''
      },
      submitted: false,
      loading: false,
      returnUrl: '/',
      error: '',
      passwordFieldType: 'password'
    }
  },
  created () {
    // redirect to home if already logged in
    if (authenticationService.currentUserValue) {
      return router.push(this.returnUrl)
    }
  },
  computed: {
    showErrorAlert () {
      if (this.error) {
        return true
      }
      return false
    },

    showSessionAlert () {
      if (
        !this.error &&
        this.$route.query.message &&
        this.$route.query.message === 'session-expired'
      ) {
        return true
      }
      return false
    }
  },
  methods: {
    createSession (evt) {
      evt.preventDefault()
      for (const children in this.$refs) {
        if (!this.$refs[children].checkForm()) {
          return
        }
      }
      this.submitted = true
      this.loading = true
      authenticationService
        .login(this.verificationData.username, this.verificationData.password)
        .then(
          (user) => router.push(this.returnUrl),
          (error) => {
            authenticationService.logout()
            if (error && error.response) {
              this.error = error.response.data
            } else {
              this.error = 'Unable to contact server.'
            }
            this.loading = false
          }
        )
    },
    resetAlerts () {
      this.error = null
    },

    redirectToSignUpPage () {
      return router.push('/signup')
    }
  }
}
</script>
