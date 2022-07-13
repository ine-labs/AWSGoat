import React, { useState } from 'react';
import ReactQuill from 'react-quill';
import 'react-quill/dist/quill.snow.css';
import { DesktopDatePicker } from '@mui/x-date-pickers/DesktopDatePicker';
import { AdapterDateFns } from '@mui/x-date-pickers/AdapterDateFns';
import { LocalizationProvider } from '@mui/x-date-pickers/LocalizationProvider';
import { Link as RouterLink } from 'react-router-dom';
import { Grid, Button, Container, Stack, Typography, TextField, Snackbar } from '@mui/material';
import Page from '../components/Page';
import placeholder from '../placeholder.png';
import { getUser } from '../sections/auth/AuthService';
import httpService from '../common/httpService';

export default function NewPost() {
  const [value, setValue] = useState('');
  const [thumbnail, setThumbnail] = useState([placeholder]);
  const [postingDate, setPostingDate] = React.useState(new Date('2022-01-01'));
  const [postTitle, setPostTitle] = useState('');
  const [imageData, setImageData] = useState(null);
  const [getRequestImageData, setGetRequestImageData] = useState('');
  const [urlValue, setUrlValue] = useState('');
  const [message, setMessage] = useState('');
  const [success, setSuccess] = useState(false);

  const user = getUser();

  const authorName = user !== 'undefined' && user ? user.name : '';
  const email = user !== 'undefined' && user ? user.email : '';

  const handleClose = (event, reason) => {
    if (reason === 'clickaway') {
      setSuccess(false);
      return;
    }

    setSuccess(false);
  };

  function getBase64(file) {
    return new Promise((resolve) => {
      let baseURL = '';
      const reader = new FileReader();
      reader.readAsDataURL(file);
      reader.onload = () => {
        if (reader.readyState === 2) {
          setThumbnail([reader.result]);
          baseURL = reader.result;
          resolve(baseURL);
        }
      };
    });
  }

  const imageHandler = (e) => {
    const file = e.target.files[0];
    getBase64(file)
      .then((result) => {
        setImageData(result.split('base64,')[1]);
      })
      .catch((err) => {
        console.log(err);
      });
    
    httpService
      .post('/save-content', {"value": imageData})
      .then((response) => {
        setGetRequestImageData(response.data.body);
        setSuccess(true);
        setMessage('Local File uploaded successfully');
      })
      .catch(() => {

      });
  };

  function uploadClick(urlValue) {
    httpService
      .get(`/save-content?value=${urlValue}`)
      .then((response) => {
        setGetRequestImageData(response.data.body);
        setSuccess(true);
        setMessage('URL File uploaded successfully');
      })
      .catch(() => {});
  }

  function handleClick(postTitle, postingDate, value) {
    const requestBody = {
      postTitle,
      authorName,
      postingDate,
      email,
      postContent: value,
      getRequestImageData,
    };

    httpService
      .post('/save-post', requestBody)
      .then(() => {
        setMessage('Blog post successfully');
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
  }

  return (
    <Page title="New Post">
      <Container>
        <Stack direction="row" alignItems="center" justifyContent="space-between" mb={5}>
          <Typography variant="h4" gutterBottom>
            New Post
          </Typography>
          <Button
            variant="contained"
            component={RouterLink}
            to="#"
            onClick={() => handleClick(postTitle, postingDate, value)}
          >
            Submit
          </Button>
        </Stack>

        <Grid container spacing={3}>
          <Grid item xs={12} sm={12} md={12}>
            <TextField
              fullWidth
              label="Enter your post headline here"
              id="fullWidth"
              value={postTitle}
              onChange={(event) => setPostTitle(event.target.value)}
            />
          </Grid>

          <Grid item xs={6} sm={6} md={6}>
            <TextField fullWidth label="Author Name" id="fullWidth" value={authorName} disabled />
          </Grid>

          <Grid item xs={6} sm={6} md={6}>
            <LocalizationProvider dateAdapter={AdapterDateFns}>
              <DesktopDatePicker
                label="Posting Date"
                inputFormat="dd/MM/yyyy"
                value={postingDate}
                onChange={(newValue) => setPostingDate(newValue)}
                renderInput={(params) => <TextField {...params} />}
              />
            </LocalizationProvider>
          </Grid>

          <Grid item xs={12} sm={12} md={12}>
            <Typography variant="h6" gutterBottom>
              Please choose any one image upload request, either from pasting URL or uploading image locally.
            </Typography>
          </Grid>

          <Grid item xs={12} sm={12} md={6}>
            <TextField
              fullWidth
              label="Enter URL of image"
              id="fullWidth"
              value={urlValue}
              onChange={(e) => setUrlValue(e.target.value)}
            />

            <Typography variant="h6" style={{ textAlign: "center" }}>OR</Typography>

            <input
              type="file"
              name="image-upload"
              id="input"
              accept="image/*"
              onChange={imageHandler}
              style={{ backgroundColor: 'lightblue', marginTop: 10, borderRadius: 5, padding: 40, width: 530 }}
            />
          </Grid>

          <Grid item xs={6} sm={6} md={2}>
            <Button variant="contained" component={RouterLink} to="#" onClick={() => uploadClick(urlValue)}>
              Upload
            </Button>
          </Grid>

          <Grid item xs={6} sm={6} md={4}>
            {thumbnail.map((image, id) => (
              <img key={id} src={image} alt="thumbnail" style={{ border: '0.1px solid grey', borderRadius: 10 }} />
            ))}
            
          </Grid>

          <Grid item xs={6} sm={12} md={12}>
            <ReactQuill
              theme="snow"
              value={value}
              onChange={(value) => setValue(value)}
              placeholder={
                'Please write your post content here. You are free to choose whichever style you want to use from the above toolbar.'
              }
              style={{ height: 400 }}
            />
          </Grid>
        </Grid>
      </Container>
      <Snackbar open={success} autoHideDuration={4000} onClose={handleClose} message={message} />
    </Page>
  );
}
