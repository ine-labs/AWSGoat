import * as Yup from 'yup';
import { useState } from 'react';
import Select from '@mui/material/Select';
import MenuItem from '@mui/material/MenuItem';
import { useFormik, Form, FormikProvider } from 'formik';
import { Stack, TextField, IconButton, InputAdornment, Button, Snackbar } from '@mui/material';
import Iconify from '../../../components/Iconify';
import httpService from '../../../common/httpService';

export default function ResetPasswordForm() {
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
    email: Yup.string().email('Email must be a valid email address').required('Email is required'),
    secretQuestion: Yup.string().required('Question is required'),
    secretAnswer: Yup.string().required('Answer is required'),
    password: Yup.string().required('Password is required'),
  });

  const formik = useFormik({
    initialValues: {
      email: '',
      secretQuestion: '',
      secretAnswer: '',
      password: '',
    },
    validationSchema: RegisterSchema,
    onSubmit: () => {
      setMessage(null);

      setQuestionValue(getFieldProps('secretQuestion').value);

      const requestBody = {
        email: getFieldProps('email').value,
        secretQuestion: getFieldProps('secretQuestion').value,
        secretAnswer: getFieldProps('secretAnswer').value,
        password: getFieldProps('password').value,
      };
      httpService
        .post('/reset-password', requestBody)
        .then((response) => {
          setMessage(response.data.body);
          setSuccess(true);
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

  const { errors, touched, handleSubmit, isSubmitting, getFieldProps } = formik;

  return (
    <FormikProvider value={formik}>
      <Form autoComplete="off" noValidate onSubmit={handleSubmit}>
        <Stack spacing={3}>
          <TextField
            fullWidth
            autoComplete="email"
            type="email"
            label="Email address"
            {...getFieldProps('email')}
            error={Boolean(touched.email && errors.email)}
            helperText={touched.email && errors.email}
          />

          <Select
            fullWidth
            label="Question"
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
            label="New Password"
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

          <Button fullWidth size="large" type="submit" variant="contained" loading={isSubmitting}>
            Reset
          </Button>
          <Snackbar open={success} autoHideDuration={4000} onClose={handleClose} message={message} />
        </Stack>
      </Form>
    </FormikProvider>
  );
}
