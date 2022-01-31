import { BehaviorSubject } from 'rxjs'
// import { Role } from '@/_helpers'
import { apiService } from '@/_services'

// const jwtDecode = require('jwt-decode')

const currentUserSubject = new BehaviorSubject(JSON.parse(localStorage.getItem('currentUser')))

const sessionActiveSubject = new BehaviorSubject(false)

// TODO: make sure this is correct usage of rxjs.BehaviorSubject
export const authenticationService = {
  login,
  logout,
  refreshSession,
  setUserToken,
  currentUser: currentUserSubject.asObservable(),
  get currentUserValue () { return currentUserSubject.value },
  sessionActive: sessionActiveSubject.asObservable(),
  get sessionActiveValue () { return sessionActiveSubject.value }
}

function removeUser () {
  localStorage.removeItem('currentUser')
  currentUserSubject.next(null)
  sessionActiveSubject.next(false)
}

function setUser (username, token) {
  // const roleIDs = jwtDecode(token).roles
  // const theMostPermissiveRole = getTheMostPermissiveRole(roleIDs)
  const user = {
    token: token,
    username: username
  }
  // store user details and jwt token in local storage to keep user logged in between page refreshes
  localStorage.setItem('currentUser', JSON.stringify(user))
  currentUserSubject.next(user)
  sessionActiveSubject.next(true)
  return user
}

function setUserToken (token) {
  const currentUser = authenticationService.currentUserValue || {}
  return setUser(currentUser.email, currentUser.userID, currentUser.accountID, currentUser.role, token)
}

function refreshSession () {
  return apiService.noAuth.post('api/token/refresh')
    .then(response => {
      if ([401, 403].indexOf(response.status) !== -1) {
        // auto logout if 401 Unauthorized or 403 Forbidden response returned from api
        removeUser()
        return Promise.reject(response.data)
        // location.reload(true)
      }
      return Promise.resolve(setUserToken(response.data.token))
    },
    error => {
      // this handles authorization error
      removeUser()
      return Promise.reject(error)
    })
}

function login (username, password) {
  return apiService.noAuth.post('api/token', { username, password }).then((resp) => {
    const token = resp.data.access
    this.setUserToken(token)
    // return apiService.get('user/my').then((response2) => {
    //   return setUser(
    //     response2.data.email,
    //     response2.data.userID,
    //     response2.data.accountID,
    //     response2.data.role,
    //     token)
    // })
    return setUser(
      username,
      token)
  })
}

function logout () {
  if (authenticationService.currentUserValue) {
    return apiService.delete('sessions')
      .then(removeUser, removeUser)
  }
  return Promise.resolve()
}

// function getTheMostPermissiveRole (roles) {
//   return Role.AccountAdmin
// }
