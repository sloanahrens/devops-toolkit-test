import { requestOptions } from '@/_helpers'

const axios = require('axios').default
axios.defaults.headers.common['Content-Type'] = 'application/json'

// in the api-gateway all back-end routes start with /api/v1
window.API_ENDPOINT = '/api/v0.1'

export const apiService = {
  get (path) {
    return axios(requestOptions.get(`${window.API_ENDPOINT}/${path}`))
  },
  post (path, body) {
    return axios(requestOptions.post(`${window.API_ENDPOINT}/${path}`, body))
  },
  patch (path, body) {
    return axios(requestOptions.patch(`${window.API_ENDPOINT}/${path}`, body))
  },
  put (path, body) {
    return axios(requestOptions.put(`${window.API_ENDPOINT}/${path}`, body))
  },
  delete (path) {
    return axios(requestOptions.delete(`${window.API_ENDPOINT}/${path}`))
  },
  noAuth: {
    post (path, body) {
      return axios(requestOptions.post(`${window.API_ENDPOINT}/${path}`, body))
    }
  }
}
