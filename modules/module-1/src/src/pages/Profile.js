import { useState, useRef } from 'react';
import Select from '@mui/material/Select';
import MenuItem from '@mui/material/MenuItem';
import { Container, Typography, Stack, IconButton, InputAdornment, Button, TextField, Snackbar, Avatar } from '@mui/material';
import { Link as RouterLink } from 'react-router-dom';
import Page from '../components/Page';
import { getUser } from '../sections/auth/AuthService';
import Iconify from '../components/Iconify';
import avatarUrl from '../images/avatar.jpg';
import httpService from '../common/httpService';

export default function Profile() {
  const [showPassword, setShowPassword] = useState(false);
  const [newPassword, setNewPassword] = useState('');
  const [confirmNewPassword, setConfirmNewPassword] = useState('');
  const [message, setMessage] = useState('');
  const [success, setSuccess] = useState(false);
  const newAnchorRef = useRef(null);

  const user = getUser();

  const name = user !== 'undefined' && user ? user.name : '';
  const id = user !== 'undefined' && user ? user.id : '';
  const username = user !== 'undefined' && user ? user.username : '';
  const phone = user !== 'undefined' && user ? user.phone : '';
  const email = user !== 'undefined' && user ? user.email : '';
  const country = user !== 'undefined' && user ? user.country : '';
  const address = user !== 'undefined' && user ? user.address : '';
  const secretQuestion = user !== 'undefined' && user ? user.secretQuestion : '';
  const secretAnswer = user !== 'undefined' && user ? user.secretAnswer : '';

  const [editName, setEditName] = useState(name);
  const [editUsername, setEditUsername] = useState(username);
  const [editPhone, setEditPhone] = useState(phone);
  const [editCountry, setEditCountry] = useState(country);
  const [editAddress, setEditAddress] = useState(address);
  const [editSecretQuestion, setEditSecretQuestion] = useState(secretQuestion);
  const [editSecretAnswer, setEditSecretAnswer] = useState(secretAnswer);

  const handleOpen = (event) => {
    console.log("Click", event);
  }
  
  const handleClose = (event, reason) => {
    if (reason === 'clickaway') {
      setSuccess(false);
      return;
    }

    setSuccess(false);
  };

  function changePasswordSubmit(id, newPassword, confirmNewPassword) {
    const requestBody = {
      id,
      newPassword,
      confirmNewPassword,
    };
    setMessage(null);
    httpService
      .post('/change-password', requestBody)
      .then((response) => {
        setMessage(response.data.body);
        setSuccess(true);
      })
      .catch((error) => {
        if (error.response.status === 401 || error.response.status === 403) {
          setMessage(error.response.data.body);
          setSuccess(true);
        } else {
          setMessage('There is something wrong in the backend server');
          setSuccess(true);
        }
      });
  }

  function saveEditChanges(editName, editUsername, editPhone, editCountry, editAddress, editSecretQuestion, editSecretAnswer, email) {
    const requestBody = {
      name: editName,
      username: editUsername,
      phone: editPhone,
      country: editCountry,
      address: editAddress,
      secretQuestion: editSecretQuestion,
      secretAnswer: editSecretAnswer,
      email
    };
    setMessage(null);
    httpService
    .post('/change-profile', requestBody)
    .then(() => {
      setMessage("User details updated");
      setSuccess(true);
      })
      .catch((error) => {
        if (error.response.status === 401 || error.response.status === 403) {
          setMessage(error.response.data.body);
          setSuccess(true);
        } else {
          setMessage('There is something wrong in the backend server');
          setSuccess(true);
        }
      });
  }

  const handleShowPassword = () => {
    setShowPassword((show) => !show);
  };

  return (
    <Page title="Profile">
      <Container maxWidth="xl">
        <Stack direction="row" alignItems="center" justifyContent="space-between" mb={0}>
          <Typography variant="h4" gutterBottom>
            Profile
          </Typography>
          <Button variant="contained" component={RouterLink} to="#" onClick={() => saveEditChanges(editName, editUsername, editPhone, editCountry, editAddress, editSecretQuestion, editSecretAnswer, email)}>
            Save
          </Button>
        </Stack>

        <Stack spacing={3} sx={{ padding: 2 }}>
          <Stack direction={{ xs: 'column', sm: 'row' }} justifyContent="center" spacing={2}>
            <IconButton ref={newAnchorRef} onClick={(e) => handleOpen(e)}>
              <Avatar alt={name} src={avatarUrl} sx={{ width: 100, height: 100 }} />
            </IconButton>
          </Stack>
          <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2}>
            <TextField fullWidth label="Name" defaultValue={editName} onChange={(event) => setEditName(event.target.value)} />
            <TextField fullWidth autoComplete="username" type="text" label="Username" defaultValue={editUsername} onChange={(event) => setEditUsername(event.target.value)} />
          </Stack>
          <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2}>
            <TextField fullWidth autoComplete="email" type="email" label="Email address" defaultValue={email} disabled />
            <TextField fullWidth label="Phone Number" defaultValue={editPhone} onChange={(event) => setEditPhone(event.target.value)} />
            <TextField fullWidth label="Country" defaultValue={editCountry} onChange={(event) => setEditCountry(event.target.value)} />
          </Stack>
          <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2}>
            <TextField fullWidth label="Address" defaultValue={editAddress} onChange={(event) => setEditAddress(event.target.value)} />
          </Stack>
          <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2}>
            <Select
              fullWidth
              label="Question"
              defaultValue={editSecretQuestion}
              onChange={(event) => setEditSecretQuestion(event.target.value)}
            >
              <MenuItem value="What is your favourite sport?">What is your favourite sport?</MenuItem>
              <MenuItem value="Where is your hometown?">Where is your hometown?</MenuItem>
              <MenuItem value="What is your first pet's name?">What is your first pet's name?</MenuItem>
              <MenuItem value="What is your favourite colour?">What is your favourite colour?</MenuItem>
              <MenuItem value="At what age did you first interacted with a computer?">
                At what age did you first interacted with a computer?
              </MenuItem>
            </Select>

            <TextField fullWidth label="Answer" defaultValue={editSecretAnswer} onChange={(event) => setEditSecretAnswer(event.target.value)} />
          </Stack>
        </Stack>
        <hr />

        <Stack spacing={3} sx={{ padding: 2 }}>
          <Typography variant="h4" gutterBottom>
            Change Password
          </Typography>
          <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2}>
            <TextField
              fullWidth
              label="New Password"
              type={showPassword ? 'text' : 'password'}
              value={newPassword}
              InputProps={{
                endAdornment: (
                  <InputAdornment position="end">
                    <IconButton onClick={handleShowPassword} edge="end">
                      <Iconify icon={showPassword ? 'eva:eye-fill' : 'eva:eye-off-fill'} />
                    </IconButton>
                  </InputAdornment>
                ),
              }}
              onChange={(event) => setNewPassword(event.target.value)}
            />
            <TextField
              fullWidth
              label="Confirm New Password"
              type={showPassword ? 'text' : 'password'}
              value={confirmNewPassword}
              InputProps={{
                endAdornment: (
                  <InputAdornment position="end">
                    <IconButton onClick={handleShowPassword} edge="end">
                      <Iconify icon={showPassword ? 'eva:eye-fill' : 'eva:eye-off-fill'} />
                    </IconButton>
                  </InputAdornment>
                ),
              }}
              onChange={(event) => setConfirmNewPassword(event.target.value)}
            />
          </Stack>
          <Stack direction="row" alignItems="center" justifyContent="center" mb={5}>
            <Button
              color="info"
              size="large"
              type="submit"
              variant="contained"
              component={RouterLink}
              to="#"
              onClick={() => changePasswordSubmit(id, newPassword, confirmNewPassword)}
            >
              Change Password
            </Button>
            <Snackbar open={success} autoHideDuration={4000} onClose={handleClose} message={message} />
          </Stack>
        </Stack>
      </Container>
    </Page>
  );
}
