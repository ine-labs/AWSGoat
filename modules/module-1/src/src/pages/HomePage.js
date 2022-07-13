import React, { useState, useEffect } from 'react';
import { styled, alpha } from '@mui/material/styles';
import { Link } from 'react-router-dom';
import { Stack, InputBase } from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';
import SearchNotFound from '../components/SearchNotFound';
import HomepageAccountPopover from '../layouts/dashboard/HomepageAccountPopover';
import Page from '../components/Page';
import awsLogo from '../images/AWScloudtitle.jpg';
import awsLogoNew from '../images/aws.jpg';
import awsLogoWithName from '../images/aws-wname.jpg';

import './App.css';
import httpService from '../common/httpService';

const getDate = (isoStr) => {
  const date = new Date(isoStr);
  return `${date.getDate()}/${date.getMonth() + 1}/${date.getFullYear()} `
}


const Search = styled('div')(({ theme }) => ({
  position: 'relative',
  borderRadius: theme.shape.borderRadius,
  backgroundColor: alpha(theme.palette.common.white, 0.15),
  '&:hover': {
    backgroundColor: alpha(theme.palette.common.white, 0.25),
  },
  marginLeft: 0,
  width: '100%',
  [theme.breakpoints.up('sm')]: {
    marginLeft: theme.spacing(1),
    width: 'auto',
  },
}));

const SearchIconWrapper = styled('div')(({ theme }) => ({
  padding: theme.spacing(0, 2),
  height: '100%',
  position: 'absolute',
  pointerEvents: 'none',
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'center',
}));

const StyledInputBase = styled(InputBase)(({ theme }) => ({
  color: 'inherit',
  '& .MuiInputBase-input': {
    padding: theme.spacing(1, 1, 1, 0),
    paddingLeft: `calc(1em + ${theme.spacing(4)})`,
    transition: theme.transitions.create('width'),
    width: '100%',
    [theme.breakpoints.up('sm')]: {
      width: '12ch',
      '&:focus': {
        width: '40ch',
      },
    },
  },
}));

function HomePage() {
  const [scriptValue, setScriptValue] = useState('');
  const [POSTS, setddbposts] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  let notFoundValue = false

  const handleChange = (event) => {
    setScriptValue(event.target.value);
    setSearchTerm(event.target.value);
  };

  useEffect(() => {
    httpService
      .post('/list-posts')
      .then((response) => {
        setddbposts(response.data.body);
      })
      .catch((error) => {
        console.error(error);
      });
  }, []);

  return (
    <>
      <Page title="Homepage">
        <Stack direction="row" justifyContent="space-between" sx={{ backgroundColor: 'black' }}>
          <Stack direction="row" justifyContent="flex-start">
            <img src={awsLogoNew} alt="" width="150px" />
          </Stack>
          <Stack direction="row" justifyContent="center" alignItems="center" sx={{ marginLeft: 25 }}>
            {/* <Typography variant="h2" color="white">AWS Goat</Typography> */}
            <img src={awsLogo} alt="" width="300px" />
          </Stack>
          <Stack direction="row" justifyContent="flex-end" alignItems="center" sx={{ paddingRight: 2 }}>
            <Search sx={{ height: '40px', marginRight: 10 }}>
              <SearchIconWrapper>
                <SearchIcon sx={{ color: "white" }} />
              </SearchIconWrapper>
              <StyledInputBase
                placeholder="Search…"
                inputProps={{ 'aria-label': 'search' }}
                value={scriptValue}
                onChange={handleChange}
                sx={{ color: "white" }}
              />
            </Search>
            <HomepageAccountPopover />
          </Stack>
        </Stack>

        {(searchTerm !== '' || notFoundValue) && (<Stack direction="column" justifyContent="center" spacing={{ xs: 0.5, sm: 1.5 }} sx={{ my: 5, px: 3 }}>
          <SearchNotFound searchQuery={searchTerm} />
        </Stack>)}

        <div className="body-card">
          {POSTS.filter((post) => {
            if (post.postTitle.toLowerCase().includes(searchTerm.toLowerCase())) {
              return post;
            }
            notFoundValue = 1
            return 0;
          }).map((post, index) => (
            <>
              <div className="card" key={index}>
                <Link to={`/blogpost/${post.id}`} state={{ authorName: post.authorName, getRequestImageData: post.getRequestImageData, postContent: post.postContent, postTitle: post.postTitle, postingDate: post.postingDate, id: post.id }}>
                  <img src={post.getRequestImageData} alt="post" />
                </Link>
                <div className="post-type-link">
                  <a href="#">Security</a>
                </div>
                <div className="card-title">{post.postTitle}</div>
                <div className="card-details">
                  <ul>
                    <li>By</li>
                    <li>
                      <a href="#">{post.authorName}</a>
                    </li>
                    <li>{getDate(post.postingDate)}</li>
                  </ul>
                </div>
            {// eslint-disable-next-line
                <div className="card-content" dangerouslySetInnerHTML={{ __html: post.postContent }} />}
              </div>
            </>
          ))}
        </div>
        <Stack direction="column" alignSelf="flex-end">
          <Stack direction="row" justifyContent="center" sx={{ backgroundColor: 'black' }}>
            <img src={awsLogoWithName} alt="" width="200px" />
          </Stack>
        </Stack>
      </Page>
    </>
  );
}

export default HomePage;
