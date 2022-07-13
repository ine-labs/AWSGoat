import React, { useState } from 'react';
import { Link as RouterLink, useLocation } from 'react-router-dom';
import { Button, Typography, Container, Box, Card, CardMedia, Divider, Stack, Link, Snackbar } from '@mui/material';
import CardContent from '@mui/material/CardContent';
import Page from '../components/Page';
import Iconify from '../components/Iconify';
import { getUser } from '../sections/auth/AuthService';
import awsLogoNew from '../images/aws.jpg';
import httpService from '../common/httpService';
import awsLogoWithName from '../images/aws-wname.jpg';

const getIcon = (name) => <Iconify icon={name} width={22} height={22} />;

const getDate = (isoStr) => {
  const date = new Date(isoStr);
  return `${date.getDate()}/${date.getMonth() + 1}/${date.getFullYear()} `
}

const styleObj = {
  lineHeight: 1.80
};

export default function Blogpost() {
  const location = useLocation();
  const { authorName, getRequestImageData, postContent, postTitle, postingDate } = location.state || '';

  const [newAuthorName, setNewAuthorName] = useState(authorName)
  const [newGetRequestImageData, setGetRequestImageData] = useState(getRequestImageData)
  const [newPostContent, setNewPostContent] = useState(postContent)
  const [newPostTitle, setNewPostTitle] = useState(postTitle)
  const [newPostingDate, setNewPostDate] = useState(postingDate)
  const [success, setSuccess] = useState(false);
  const [message, setMessage] = useState(null);

  const user = getUser();
  const authLevel = user !== 'undefined' && user ? user.authLevel : '';
  const loggenInAuthLevel = authLevel;

  const handleClose = (event, reason) => {
    if (reason === 'clickaway') {
      return;
    }
    setSuccess(false);
  };

  function modifyPostStatus(event) {
    setNewAuthorName(newAuthorName)
    setGetRequestImageData(newGetRequestImageData)
    setNewPostContent(newPostContent)
    setNewPostTitle(newPostTitle)
    setNewPostDate(newPostingDate)
    let requestBody = {}
    if (event.target.innerText === "Approve Post") {
      requestBody = {
        id: window.location.href.split('/')[window.location.href.split('/').length - 1],
        authLevel,
        postStatus: "approved"
      }
    } else {
      requestBody = {
        id: window.location.href.split('/')[window.location.href.split('/').length - 1],
        authLevel,
        postStatus: "rejected"
      }
    }

    httpService
      .post('/modify-post-status', requestBody)
      .then((response) => {
        setMessage(response.data.body)
        setSuccess(true)
      })
      .catch((error) => {
        console.error(error)
      })

  }

  return (
    <Page title="Blogs">
      <Stack direction="row" justifyContent="space-between" sx={{ backgroundColor: 'black' }}>
        <Stack direction="row" justifyContent="flex-start">
          <Link component={RouterLink} variant="subtitle2" to="/home" underline="hover"><img src={awsLogoNew} alt="" width="150px" /></Link>
        </Stack>
        <Stack direction="row" justifyContent="flex-end" alignItems="center" sx={{ paddingRight: 2 }}>
          {loggenInAuthLevel === "0" && (<><Button
            // onClick={() => UnbanUser()}
            variant="contained"
            color="success"
            component={RouterLink}
            to="#"
            sx={{ marginRight: '20px' }}
            startIcon={<Iconify icon="eva:person-done-fill" />}
            onClick={(e) => modifyPostStatus(e)}
          >
            Approve post
          </Button><Button
            variant="contained"
            color="error"
            component={RouterLink}
            to="#"
            startIcon={<Iconify icon="eva:person-delete-fill" />}
            onClick={(e) => modifyPostStatus(e)}

          >
              Reject post
            </Button></>)}
        </Stack>
      </Stack>
      <Container>
        <Card sx={{ minWidth: 275, mt: 7, mb: 7 }}>
          <CardMedia
            component="img"
            src={newGetRequestImageData}
            alt="Hello"
            sx={{ width: "100%" }}
          />
          <CardContent>
            <Container sx={{ alignItems: "center", justifyContent: "center", display: "flex" }}>
              <Container sx={{ borderRadius: "0%", width: "80%", alignItems: "center", justifyContent: "center", display: "flex", flexDirection: "column" }}>
                <Typography variant="h3" paragraph center>
                  {newPostTitle}
                </Typography>
                <Container sx={{ display: "flex", justifyContent: "center", alignItems: "center", flexDirection: "row" }}>
                  <Typography sx={{ display: "flex", justifyContent: "center", alignItems: "center" }}>
                    <Box component="div" sx={{ p: 0.50 }}>{getIcon('bxs:user')}</Box> <Box component="div" sx={{ p: 1, mt: -0.25 }}>{newAuthorName}</Box>
                  </Typography>
                  <Typography sx={{ display: "flex", justifyContent: "center", alignItems: "center" }}>
                    <Box component="div" display="inline" sx={{ p: 0.50 }}>{getIcon('fontisto:date')}</Box><Box component="div" sx={{ p: 1, mt: -0.25 }}>{getDate(newPostingDate)}</Box>
                  </Typography>
                </Container>
              </Container>
            </Container>
            <Divider sx={{ mt: 5, mb: 5 }} />
            <Container>
              {// eslint-disable-next-line
                <div dangerouslySetInnerHTML={{ __html: newPostContent }} style={styleObj} />}
            </Container>
          </CardContent>
        </Card>
      </Container>
      <Stack direction="row" justifyContent="center" alignContent="center" sx={{ backgroundColor: 'black' }}>
        <img src={awsLogoWithName} alt="" width="200px" />
      </Stack>
      <Snackbar open={success} autoHideDuration={4000} onClose={handleClose} message={message} />
    </Page>
  );
}