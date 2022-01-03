<template>
  <div>
    <b-alert
      variant="danger"
      :show="showErrorAlert"
    >ERROR: {{ this.error }}</b-alert>
    <b-card no-body>
      <b-tabs pills card>
        <b-tab :title="latestTimestmp" active>
          <b-card-text>
            <b-card>
              <b-row class="mb-2">
                <b-col class="text-sm-left">
                  <div>
                    <h4>
                      {{this.ledger_object.positive_cycle_asset_pairs_count}} Positive-cycle Pairs
                    </h4>
                  </div>
                  <div>
                    <textarea
                      class="form-control really-big-textarea"
                      disabled aria-label="With textarea"
                      v-model="pcAssetPairsData">
                    </textarea>
                 </div>
                </b-col>
                <b-col class="text-sm-left">
                  <div>
                    <h4>
                      {{this.ledger_object.wl_asset_pairs_count}} Whitelisted Asset-Pairs
                      ({{this.ledger_object.wl_assets_count}} WL Assets)
                    </h4>
                  </div>
                  <div>
                    <textarea
                      class="form-control really-big-textarea"
                      disabled aria-label="With textarea"
                      v-model="wlAssetPairsData">
                    </textarea>
                 </div>
                </b-col>
                <b-col class="text-sm-left">
                  <div><h4>Event-Logs (latest: {{this.ledger_object.latest_log}})</h4></div>
                  <div>
                    <textarea
                      class="form-control really-big-textarea"
                      disabled aria-label="With textarea"
                      v-model="logsData">
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
      ledger_object: {},
      error: null
    }
  },
  computed: {
    latestTimestmp () {
      return 'Data updated: ' + this.ledger_object.timestamp
    },
    logsData () {
      return JSON.stringify(this.ledger_object.logs, null, 2)
    },
    wlAssetPairsData () {
      return JSON.stringify(this.ledger_object.wl_asset_pairs, null, 2)
    },
    pcAssetPairsData () {
      return JSON.stringify(this.ledger_object.positive_cycle_asset_pairs, null, 2)
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
      apiService.get('ledgers')
        .then(response => {
          this.ledger_object = response.data
          this.setLoadDataTimeout()
        }, this.handleError)
    },
    setLoadDataTimeout () {
      this.timerId = setTimeout(() => {
        this.loadData()
      }, 1000)
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
