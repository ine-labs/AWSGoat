import React, { useEffect, useState } from 'react';
import { Link as RouterLink } from 'react-router-dom';
import { Grid, Container, Button, Stack, Typography, Popper, Grow, Paper, MenuList, MenuItem } from '@mui/material';
import ButtonGroup from '@mui/material/ButtonGroup';
import { ArrowDropDownSharp } from '@mui/icons-material';
import ClickAwayListener from '@mui/material/ClickAwayListener';
import Page from '../components/Page';
import Iconify from '../components/Iconify';
import { BlogPostCard } from '../sections/@dashboard/blog';
import { getUser } from '../sections/auth/AuthService';
import httpService from '../common/httpService';

const options = ['All Posts', 'Accepted Posts', 'Rejected Posts', 'Pending Posts'];

export default function Blog() {
  const [POSTS, setddbposts] = useState([]);

  const [open, setOpen] = React.useState(false);
  const anchorRef = React.useRef(null);
  const [selectedIndex, setSelectedIndex] = React.useState(1);

  const user = getUser();
  const authLevel = user !== 'undefined' && user ? user.authLevel : '';
  const email = user !== 'undefined' && user ? user.email : '';

  const handleClick = () => {
    let postStatus;
    if (options[selectedIndex] === "All Posts") {
      postStatus = "all";
    } else if (options[selectedIndex] === "Accepted Posts") {
      postStatus = "approved";
    } else if (options[selectedIndex] === "Rejected Posts") {
      postStatus = "rejected";
    } else {
      postStatus = "pending";
    }

    const requestBody = {
      authLevel, postStatus, email
    }
    httpService
      .post('/list-posts', requestBody)
      .then((response) => {
        setddbposts(response.data.body);
      })
      .catch((error) => {
        console.error(error);
      });
  };

  const handleMenuItemClick = (event, index) => {
    setSelectedIndex(index);
    setOpen(false);
  };

  const handleToggle = () => {
    setOpen((prevOpen) => !prevOpen);
  };

  const handleClose = (event) => {
    if (anchorRef.current && anchorRef.current.contains(event.target)) {
      return;
    }

    setOpen(false);
  };

  useEffect(
    () => {
      const requestBody = {
        authLevel, 
        email,
        postStatus: "approved"
      }
      httpService
        .post('/list-posts', requestBody)
        .then((response) => {
          setddbposts(response.data.body);
        })
        .catch((error) => {
          console.error(error);
        });
    }, [authLevel, email]
  );


  return (
    <Page title="Posts">
      <Container>
        <Stack direction="row" alignItems="center" justifyContent="space-between" mb={5}>
          <Typography variant="h4" gutterBottom>
            Posts
          </Typography>
          <ButtonGroup variant="contained" color='secondary' ref={anchorRef} aria-label="split button">
            <Button onClick={handleClick}>{options[selectedIndex]}</Button>
            <Button
              size="small"
              aria-controls={open ? 'split-button-menu' : undefined}
              aria-expanded={open ? 'true' : undefined}
              aria-label="select merge strategy"
              aria-haspopup="menu"
              onClick={handleToggle}
            >
              <ArrowDropDownSharp />
            </Button>
          </ButtonGroup>
          <Popper
            open={open}
            anchorEl={anchorRef.current}
            role={undefined}
            transition
            sx={{ zIndex: 1 }}
            disablePortal
          >
            {({ TransitionProps, placement }) => (
              <Grow
                {...TransitionProps}
                style={{
                  transformOrigin:
                    placement === 'bottom' ? 'center top' : 'center bottom',
                }}
              >
                <Paper>
                  <ClickAwayListener onClickAway={handleClose}>
                    <MenuList id="split-button-menu" autoFocusItem>
                      {options.map((option, index) => (
                        <MenuItem
                          key={option}
                          // disabled={index === 2}
                          selected={index === selectedIndex}
                          onClick={(event) => handleMenuItemClick(event, index)}
                        >
                          {option}
                        </MenuItem>
                      ))}
                    </MenuList>
                  </ClickAwayListener>
                </Paper>
              </Grow>
            )}
          </Popper>
          <Button variant="contained" component={RouterLink} to="/dashboard/newpost" startIcon={<Iconify icon="eva:plus-fill" />}>
            New Post
          </Button>
        </Stack>

        <Grid container spacing={3}>
          {POSTS.map((post, index) => (
            <BlogPostCard key={post.id} post={post} index={index} />
          ))}
        </Grid>
      </Container>
    </Page>
  );
}
