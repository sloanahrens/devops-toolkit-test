<template>
  <div>
    <b-alert
      variant="danger"
      :show="showErrorAlert"
    >ERROR: {{ this.error }}</b-alert>
    <b-row class="mb-2">
      <b-col class="text-sm-center">
        <b-card>
          <h4>
            <b>Strategy:</b>
          </h4>
          <h4>
            <b>Strict-Send--></b>: ({{app_data.target_tx_in_xlm}}) XLM --&gt; ... --&gt; ... Bridge-Asset,
          </h4>
          <h4>
            <b>Strict-Receive-></b>: Bridge-Asset --&gt; ... --&gt; ... ({{app_data.target_tx_in_xlm}}) XLM,
          </h4>
          <h4>
            get the ({{app_data.target_tx_in_xlm}}) XLM back,
          </h4>
          <h4>
            accumulate some Bridge-Asset in the process.
          </h4>
          <hr>
          <h5>
            -- Considering Asset-Tuples of order 1 to {{app_data.n}} --
          </h5>
          <h5>
            -- Current whitelisted Asset count: {{app_data.wl_assets_count}} --
          </h5>
          <h5>
            [Error count: {{app_data.error_count}}]
          </h5>
        </b-card>
      </b-col>
    </b-row>
    <b-card no-body>
      <b-tabs pills card>
        <b-tab :title="latestTimestmp" active>
          <b-card-text>
            <b-card>
              <b-row class="mb-2">
                <b-col class="text-sm-left">
                  <div>
                    <h6>
                      Event-Logs (latest: {{app_data.latest_log}})
                    </h6>
                  </div>
                  <div>
                    <textarea
                      class="form-control really-big-textarea"
                      disabled aria-label="With textarea"
                      v-model="logsData">
                    </textarea>
                 </div>
                </b-col>
                <b-col class="text-sm-left">
                  <div>
                    <h6>
                      {{app_data.asset_tuples_total_count}} Tuples in DB,
                      {{app_data.asset_tuples_returned}} displayed
                    </h6>
                  </div>
                  <div>
                    <textarea
                      class="form-control really-big-textarea"
                      disabled aria-label="With textarea"
                      v-model="assetTuples">
                    </textarea>
                 </div>
                </b-col>
                <b-col class="text-sm-left">
                  <div>
                    <h6>
                      {{app_data.accumlations_count}} Accumlations, totaling {{app_data.accumlations_sum}} XLM
                    </h6>
                  </div>
                  <div>
                    <textarea
                      class="form-control really-big-textarea"
                      disabled aria-label="With textarea"
                      v-model="accumlations">
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

import { apiService } from '@/_services'

export default {
  name: 'DataList',
  components: {
  },
  data () {
    return {
      app_data: {},
      error: null
    }
  },
  computed: {
    latestTimestmp () {
      return 'Data updated: ' + this.app_data.timestamp
    },
    logsData () {
      return JSON.stringify(this.app_data.logs, null, 2)
    },
    assetTuples () {
      return JSON.stringify(this.app_data.asset_tuples, null, 2)
    },
    accumlations () {
      return JSON.stringify(this.app_data.accumlations, null, 2)
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
      console.debug(this.error)
    },
    loadData () {
      apiService.get('ledgers')
        .then(response => {
          this.app_data = response.data
          this.setLoadDataTimeout()
        }, this.handleError)
    },
    setLoadDataTimeout () {
      this.timerId = setTimeout(() => {
        this.loadData()
      }, 5000)
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
