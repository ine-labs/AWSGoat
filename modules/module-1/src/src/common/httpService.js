import axios from "axios";
import { getToken } from '../sections/auth/AuthService';

export default axios.create({
  baseURL: "API_GATEWAY_URL",
  headers: {
    "Content-type": "application/json",
    "JWT_TOKEN": getToken(),
  }
});