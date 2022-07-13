export function getUser() {
  const user = sessionStorage.getItem("user");
  if (user === "undefined" || !user) {
    return null;
  }
  return JSON.parse(user);
}
export function getToken() {
  return sessionStorage.getItem("token");
}
export function setUserSession(user, token) {
  sessionStorage.setItem("user", JSON.stringify(user));
  sessionStorage.setItem("token", token);
}
export function resetUserSession() {
  sessionStorage.removeItem("user");
  sessionStorage.removeItem("token");
}
