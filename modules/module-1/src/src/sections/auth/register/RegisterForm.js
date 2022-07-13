import * as Yup from 'yup';
import { useState } from 'react';
import Select from '@mui/material/Select';
import MenuItem from '@mui/material/MenuItem';
import { useFormik, Form, FormikProvider } from 'formik';
import { useNavigate } from 'react-router-dom';
import { Stack, TextField, IconButton, InputAdornment, Button, Snackbar } from '@mui/material';
import httpService from '../../../common/httpService';
import Iconify from '../../../components/Iconify';

export default function RegisterForm() {
  const navigate = useNavigate();

  const [showPassword, setShowPassword] = useState(false);
  const [message, setMessage] = useState(null);
  const [success, setSuccess] = useState(false);
  const [questionValue, setQuestionValue] = useState('What is your favourite sport?');

  const handleClose = (event, reason) => {
    if (reason === 'clickaway') {
      setSuccess(false);
      return;
    }

    setSuccess(false);
  };

  const RegisterSchema = Yup.object().shape({
    name: Yup.string().min(2, 'Too Short!').max(50, 'Too Long!').required('Name is required'),
    username: Yup.string().min(2, 'Too Short!').max(50, 'Too Long!').required('Username is required'),
    email: Yup.string().email('Email must be a valid email address').required('Email is required'),
    address: Yup.string().min(10, 'Too Short!').max(100, 'Too Long!').required('Address is required'),
    country: Yup.string().min(2, 'Too Short!').max(50, 'Too Long!').required('Country is required'),
    phone: Yup.string().min(9, 'Too Short!').max(50, 'Too Long!').required('Phone number is required'),
    secretQuestion: Yup.string().required('Question is required'),
    secretAnswer: Yup.string().required('Answer is required'),
    password: Yup.string().required('Password is required'),
  });

  const formik = useFormik({
    initialValues: {
      name: '',
      username: '',
      email: '',
      address: '',
      country: '',
      phone: '',
      secretQuestion: '',
      secretAnswer: '',
      password: '',
    },
    validationSchema: RegisterSchema,
    onSubmit: () => {
      setMessage(null);

      setQuestionValue(getFieldProps('secretQuestion').value);
      const date = new Date();

      const requestBody = {
        name: getFieldProps('name').value,
        username: getFieldProps('username').value,
        email: getFieldProps('email').value,
        address: getFieldProps('address').value,
        country: getFieldProps('country').value,
        phone: getFieldProps('phone').value,
        secretQuestion: getFieldProps('secretQuestion').value,
        secretAnswer: getFieldProps('secretAnswer').value,
        password: getFieldProps('password').value,
        creationDate: date.toISOString(),
      };

      httpService
        .post('/register', requestBody)
        .then(() => {
          setMessage('Registration Successful');
          setSuccess(true);
          navigate('/login', { replace: true });
        })
        .catch((error) => {
          if (error.response.status === 401 || error.response.status === 403) {
            setMessage(error.response.data.message);
            setSuccess(true);
          } else {
            setMessage('There is something wrong in the backend server');
            setSuccess(true);
          }
        });
    },
  });

  const { errors, touched, handleSubmit, getFieldProps } = formik;

  return (
    <FormikProvider value={formik}>
      <Form autoComplete="off" noValidate onSubmit={handleSubmit}>
        <Stack spacing={3}>
          <TextField
            fullWidth
            label="Name"
            {...getFieldProps('name')}
            error={Boolean(touched.name && errors.name)}
            helperText={touched.name && errors.name}
          />

          <TextField
            fullWidth
            autoComplete="username"
            type="text"
            label="Username"
            {...getFieldProps('username')}
            error={Boolean(touched.username && errors.username)}
            helperText={touched.username && errors.username}
          />

          <TextField
            fullWidth
            autoComplete="email"
            type="email"
            label="Email address"
            {...getFieldProps('email')}
            error={Boolean(touched.email && errors.email)}
            helperText={touched.email && errors.email}
          />

          <TextField
            fullWidth
            label="Address"
            {...getFieldProps('address')}
            error={Boolean(touched.address && errors.address)}
            helperText={touched.address && errors.address}
          />
          <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2}>
            <TextField
              fullWidth
              label="Country"
              {...getFieldProps('country')}
              error={Boolean(touched.country && errors.country)}
              helperText={touched.country && errors.country}
            />

            <TextField
              fullWidth
              label="Phone Number"
              {...getFieldProps('phone')}
              error={Boolean(touched.phone && errors.phone)}
              helperText={touched.phone && errors.phone}
            />
          </Stack>

          <Select
            fullWidth
            label="Question"
            // labelId="demo-simple-select-helper-label"
            // id="demo-simple-select-helper"
            value={questionValue}
            onChange={(event) => setQuestionValue(event.target.value)}
            {...getFieldProps('secretQuestion')}
          >
            <MenuItem value="What is your favourite sport?">What is your favourite sport?</MenuItem>
            <MenuItem value="Where is your hometown?">Where is your hometown?</MenuItem>
            <MenuItem value="What is your first pet's name?">What is your first pet's name?</MenuItem>
            <MenuItem value="What is your favourite colour?">What is your favourite colour?</MenuItem>
            <MenuItem value="At what age did you first interacted with a computer?">
              At what age did you first interacted with a computer?
            </MenuItem>
          </Select>

          <TextField
            fullWidth
            label="Answer"
            {...getFieldProps('secretAnswer')}
            error={Boolean(touched.answer && errors.answer)}
            helperText={touched.answer && errors.answer}
          />

          <TextField
            fullWidth
            autoComplete="current-password"
            type={showPassword ? 'text' : 'password'}
            label="Password"
            {...getFieldProps('password')}
            InputProps={{
              endAdornment: (
                <InputAdornment position="end">
                  <IconButton edge="end" onClick={() => setShowPassword((prev) => !prev)}>
                    <Iconify icon={showPassword ? 'eva:eye-fill' : 'eva:eye-off-fill'} />
                  </IconButton>
                </InputAdornment>
              ),
            }}
            error={Boolean(touched.password && errors.password)}
            helperText={touched.password && errors.password}
          />

          <Button fullWidth size="large" type="submit" variant="contained">
            Register
          </Button>

          <Snackbar open={success} autoHideDuration={4000} onClose={handleClose} message={message} />
        </Stack>
      </Form>
    </FormikProvider>
  );
}
