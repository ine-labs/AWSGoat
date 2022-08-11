import axios from "axios";
import { getToken } from '../sections/auth/AuthService';

const httpService = axios.create({
  baseURL: "https://o4bffq87bl.execute-api.us-east-1.amazonaws.com/v1",
  headers: {
    "Content-type": "application/json",
    "JWT_TOKEN": getToken(),
  }
});

httpService.interceptors.request.use(async req => {
  console.log("Hello world")
  req.headers.JWT_TOKEN = getToken();
  return req;
})

export default httpService;