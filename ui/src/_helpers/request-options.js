import { authenticationService } from '@/_services'

export const requestOptions = {
  get (url) {
    return {
      url: url,
      method: 'GET',
      ...headers()
    }
  },
  post (url, body) {
    return {
      url: url,
      method: 'POST',
      ...headers(),
      data: JSON.stringify(body)
    }
  },
  patch (url, body) {
    return {
      url: url,
      method: 'PATCH',
      ...headers(),
      data: JSON.stringify(body)
    }
  },
  put (url, body) {
    return {
      url: url,
      method: 'PUT',
      ...headers(),
      data: JSON.stringify(body)
    }
  },
  delete (url) {
    return {
      url: url,
      method: 'DELETE',
      ...headers()
    }
  }
}

function headers () {
  const currentUser = authenticationService.currentUserValue || {}
  const authHeader = currentUser.token ? { Authorization: 'Bearer ' + currentUser.token } : {}
  console.log('headers function; currentUser, authHeader:', currentUser, authHeader)
  return {
    headers: {
      'Content-Type': 'application/json',
      ...authHeader
    }
  }
}
