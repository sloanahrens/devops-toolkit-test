<template>
  <div>
    <b-alert
      variant="danger"
      :show="showErrorAlert"
    >ERROR: {{ this.error }}</b-alert>
    <b-card no-body>
      <b-tabs pills card>
        <b-tab title="Stellar Ledgers" active>
          <b-card-text>
            <b-card>
              <b-row class="mb-2">
                <b-col class="text-sm-left">
                  <h4>{{ this.ledger_object.timestamp }}</h4>
                  <div><b>JSON:</b></div>
                  <div>
                      <textarea
                        class="form-control really-big-textarea"
                        disabled aria-label="With textarea"
                        v-model="ledgerDataJson">
                     </textarea>
                 </div>
                </b-col>
              </b-row>
            </b-card>
          </b-card-text>
        </b-tab>
      </b-tabs>
    </b-card>
  </div>
</template>

<script>

const axios = require('axios').default
axios.defaults.headers.common['Content-Type'] = 'application/json'

export default {
  name: 'DataList',
  components: {
  },
  data () {
    return {
      ledger_object: { raw_json: '', timestamp: '' },
      error: null
    }
  },
  computed: {
    ledgerDataJson () {
      return JSON.stringify(this.ledger_object.data, null, 2)
    },
    showErrorAlert () {
      if (this.error) {
        return true
      }
      return false
    }
  },
  methods: {
    handleError (error) {
      this.error = JSON.stringify(error.response.data)
    },
    loadData () {
      axios({ method: 'GET', url: '/api/v0.1/ledgers' })
        .then(response => {
          this.ledger_object = response.data
          this.setLoadDataTimeout()
        }, this.handleError)
    },
    setLoadDataTimeout () {
      this.timerId = setTimeout(() => {
        this.loadData()
      }, 3000)
    },
    resetAlerts () {
      this.error = null
    }
  },
  mounted () {
    this.loadData()
  },
  watch: {
    $route (to, from) {
      this.loadData()
    }
  }
}
</script>
