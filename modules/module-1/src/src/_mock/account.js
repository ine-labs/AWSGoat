// ----------------------------------------------------------------------

import { getUser } from '../sections/auth/AuthService';
import popOverLogo from '../images/avatar-2.jpg';

const user = getUser();

const displayName = user !== 'undefined' && user ? user.name : '';
const email = user !== 'undefined' && user ? user.email : '';
const account = {
  displayName,
  email,
  photoURL: popOverLogo,
};

export default account;
