import axios from "axios";
import { getToken } from '../sections/auth/AuthService';

const httpService = axios.create({
  baseURL: "API_GATEWAY_URL",
  headers: {
    "Content-type": "application/json",
    "JWT_TOKEN": getToken(),
  }
});

httpService.interceptors.request.use(async req => {
  req.headers.JWT_TOKEN = getToken();
  return req;
})

export default httpService;