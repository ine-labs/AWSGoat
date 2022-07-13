import { sentenceCase } from 'change-case';
import React, { useState, useEffect, useRef } from 'react';
import { Link as RouterLink } from 'react-router-dom';
import {
  Card,
  Table,
  Stack,
  Avatar,
  Button,
  Checkbox,
  TableRow,
  TableBody,
  TableCell,
  Container,
  Typography,
  TableContainer,
  TablePagination,
  Snackbar,
  IconButton,
  Box,
  Grid,
  Grow,
  Paper,
  Popper,
  MenuItem,
  MenuList
} from '@mui/material';
import ButtonGroup from '@mui/material/ButtonGroup';
import { ArrowDropDownSharp } from '@mui/icons-material';
import ClickAwayListener from '@mui/material/ClickAwayListener';
import Page from '../components/Page';
import Label from '../components/Label';
import Scrollbar from '../components/Scrollbar';
import Iconify from '../components/Iconify';
import SearchNotFound from '../components/SearchNotFound';
import UserDetailsPopOver from '../components/UserDetailsPopOver';
import { UserListHead, UserListToolbar } from '../sections/@dashboard/user';
import { BlogPostCard } from '../sections/@dashboard/blog';
import { getUser } from '../sections/auth/AuthService';
import avatarUrl from '../images/avatar.jpg'
import noPostsFound from '../images/no-posts-found.jpg'
import httpService from '../common/httpService';

export default function User() {
  const [USERLIST, setUserList] = useState([]);
  const [page, setPage] = useState(0);
  const [order, setOrder] = useState('asc');
  const [selected, setSelected] = useState([]);
  const [orderBy, setOrderBy] = useState('name');
  const [filterName, setFilterName] = useState('');
  const [rowsPerPage, setRowsPerPage] = useState(5);
  const [message, setMessage] = useState('');
  const [success, setSuccess] = useState(false);
  const newAnchorRef = useRef(null);
  const [open, setOpen] = useState(null);
  const [popOverName, setPopOverName] = useState('');
  const [popOverUserName, setPopOverUserName] = useState('');
  const [POSTS, setUbPosts] = useState([]);
  const [selectedName, setSelectedName] = useState('');
  const [selectedEmail, setSelectedEmail] = useState('');

  const [openButtonGroup, setOpenButtonGroup] = React.useState(false);
  const anchorRef = React.useRef(null);
  const [selectedIndex, setSelectedIndex] = React.useState(1);

  const user = getUser();

  const authLevel = user !== 'undefined' && user ? user.authLevel : '';
  const loggedInAuthLevel = authLevel;

  const options = ['Reassign as User', 'Reassign as Author', 'Reassign as Editor', 'Reassign as Admin'];

  const TABLE_HEAD = [
    { id: 'name', label: 'Name', alignRight: false },
    { id: 'username', label: 'Username', alignRight: false },
    { id: 'authLevel', label: 'Designation', alignRight: false },
    { id: 'userStatus', label: 'Status', alignRight: false },
    { id: 'email', label: 'Email', alignRight: false },
    loggedInAuthLevel === "0" && { id: 'phone', label: 'Phone', alignRight: false },
    loggedInAuthLevel === "0" && { id: 'country', label: 'Country', alignRight: false },
    loggedInAuthLevel === "0" && { id: 'address', label: 'Address', alignRight: false },
    { id: '' },
  ];

  const handleClickButtonGroup = () => {
    console.info(`You clicked ${options[selectedIndex]}`);
    const requestBody = {
      authLevel,
      email: selectedEmail,
      userAuthLevel: options[selectedIndex]
    };
    httpService
      .post('/change-auth', requestBody)
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
  };

  const handleMenuItemClick = (event, index) => {
    setSelectedIndex(index);
    setOpenButtonGroup(false);
  };

  const handleToggle = () => {
    setOpenButtonGroup((prevOpen) => !prevOpen);
  };

  const handleCloseButtonGroup = (event) => {
    if (anchorRef.current && anchorRef.current.contains(event.target)) {
      return;
    }

    setOpenButtonGroup(false);
  };




  const handleOpen = (event, row) => {
    setPopOverName(row.name);
    setPopOverUserName(row.username);
    setOpen(event.currentTarget);
    const userBlogsBody = {
      email: row.email
    }
    httpService
      .post('/user-details-modal', userBlogsBody)
      .then((response) => {
        setUbPosts(response.data.body.Items);
      })
      .catch((error) => {
        console.error(error);
      });
  };

  const handleClosePopver = () => {
    setOpen(null);
  };

  const handleRequestSort = (event, property) => {
    const isAsc = orderBy === property && order === 'asc';
    setOrder(isAsc ? 'desc' : 'asc');
    setOrderBy(property);
  };

  const handleSelectAllClick = (event) => {
    if (event.target.checked) {
      const newSelecteds = USERLIST.map((n) => n.name);
      setSelected(newSelecteds);
      return;
    }
    setSelected([]);
  };

  const handleClick = (event, name, email) => {
    setSelectedName(name);
    setSelectedEmail(email);
    const selectedIndex = selected.indexOf(name);
    let newSelected = [];
    if (selectedIndex === -1) {
      newSelected = newSelected.concat(selected, name);
    } else if (selectedIndex === 0) {
      newSelected = newSelected.concat(selected.slice(1));
    } else if (selectedIndex === selected.length - 1) {
      newSelected = newSelected.concat(selected.slice(0, -1));
    } else if (selectedIndex > 0) {
      newSelected = newSelected.concat(selected.slice(0, selectedIndex), selected.slice(selectedIndex + 1));
    }
    setSelected(newSelected);
  };

  const handleChangePage = (event, newPage) => {
    setPage(newPage);
  };

  const handleChangeRowsPerPage = (event) => {
    setRowsPerPage(parseInt(event.target.value, 10));
    setPage(0);
  };

  const handleFilterByName = (event) => {
    setFilterName(event.target.value);
  };

  useEffect(
    () => {
      if (filterName.length === 0) {
        httpService
          .post('/get-users', { authLevel })
          .then((response) => {
            setUserList(response.data.body.Items);
          })
          .catch((error) => {
            console.error(error);
          });
      } else {
        httpService
          .post('/search-author', { value: filterName, authLevel })
          .then((response) => {
            setUserList(response.data.body.Items);
          })
          .catch((error) => {
            console.error(error);
          });
      }
    },
    [filterName],
    [USERLIST]
  );

  const emptyRows = page > 0 ? Math.max(0, (1 + page) * rowsPerPage - USERLIST.length) : 0;
  const isUserNotFound = USERLIST.length === 0;

  const handleClose = (event, reason) => {
    if (reason === 'clickaway') {
      setSuccess(false);
      return;
    }

    setSuccess(false);
  };

  function deleteUser() {
    const requestBody = {
      authLevel,
      email: selectedEmail
    }

    httpService
      .post('/delete-user', requestBody)
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
  }

  function banUser() {

    const requestBody = {
      name: selectedName,
      authLevel,
      email: selectedEmail,
    };

    httpService
      .post('/ban-user', requestBody)
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
  }

  function UnbanUser() {
    const requestBody = {
      name: selectedName,
      authLevel,
      email: selectedEmail,
    };
    httpService
      .post('/unban-user', requestBody)
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
  }

  function userDesignation(authLevel) {
    let desig;
    if (authLevel === "0") {
      desig = "Admin";
    } else if (authLevel === "100") {
      desig = "Editor";
    } else if (authLevel === "200") {
      desig = "Author";
    } else {
      desig = "User";
    }
    return desig;
  }

  return (
    <Page title="User">
      <Container>
        {loggedInAuthLevel === "0" && (<Stack direction={{ xs: 'column', sm: 'row' }} spacing={3} alignItems="center" justifyContent="flex-end" mb={6}>
          <ButtonGroup variant="contained" ref={anchorRef} aria-label="split button">
            <Button onClick={handleClickButtonGroup}>{options[selectedIndex]}</Button>
            <Button
              size="small"
              aria-controls={openButtonGroup ? 'split-button-menu' : undefined}
              aria-expanded={openButtonGroup ? 'true' : undefined}
              aria-label="select merge strategy"
              aria-haspopup="menu"
              onClick={handleToggle}
            >
              <ArrowDropDownSharp />
            </Button>
          </ButtonGroup>
          <Popper
            open={openButtonGroup}
            anchorEl={anchorRef.current}
            role={undefined}
            sx={{ zIndex: 1 }}
            transition
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
                  <ClickAwayListener onClickAway={handleCloseButtonGroup}>
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
          <Button
            onClick={() => deleteUser()}
            variant="contained"
            color="error"
            component={RouterLink}
            to="#"
            startIcon={<Iconify icon="eva:person-delete-fill" />}
          >
            Delete User
          </Button>
          <Button
            onClick={() => UnbanUser()}
            variant="contained"
            color="success"
            component={RouterLink}
            to="#"
            startIcon={<Iconify icon="eva:person-done-fill" />}
          >
            Unban User
          </Button>
          <Button
            onClick={() => banUser()}
            variant="contained"
            color="error"
            component={RouterLink}
            to="#"
            startIcon={<Iconify icon="eva:person-delete-fill" />}
          >
            Ban User
          </Button>
        </Stack>
        )}

        <Card>
          <UserListToolbar numSelected={selected.length} filterName={filterName} onFilterName={handleFilterByName} />

          <Scrollbar>
            <TableContainer sx={{ minWidth: 800 }}>
              <Table>
                <UserListHead
                  order={order}
                  orderBy={orderBy}
                  headLabel={TABLE_HEAD}
                  rowCount={USERLIST.length}
                  numSelected={selected.length}
                  onRequestSort={handleRequestSort}
                  onSelectAllClick={handleSelectAllClick}
                />
                <TableBody>
                  {USERLIST.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage).map((row) => {
                    const { id, name, address, userStatus, email, authLevel, phone, country, username } = row;
                    const isItemSelected = selected.indexOf(name) !== -1;
                    return (
                      <TableRow
                        hover
                        key={id}
                        tabIndex={-1}
                        role="checkbox"
                        selected={isItemSelected}
                        aria-checked={isItemSelected}
                      >
                        <TableCell padding="checkbox">
                          <Checkbox checked={isItemSelected} onChange={(event) => handleClick(event, name, email)} />
                        </TableCell>
                        <TableCell component="th" scope="row" padding="none">
                          <Stack direction="row" alignItems="center" spacing={2}>
                            <IconButton ref={newAnchorRef} onClick={(e) => handleOpen(e, row)}>
                              <Avatar alt={name} src={avatarUrl} />
                            </IconButton>
                            <UserDetailsPopOver
                              open={Boolean(open)}
                              anchorEl={open}
                              onClose={handleClosePopver}
                              sx={{
                                overflow: 'auto',
                                p: 0,
                                mt: 1.5,
                                ml: 0.75,
                                '& .MuiMenuItem-root': {
                                  typography: 'body2',
                                  borderRadius: 0.75,
                                },
                              }}
                            >
                              <Box sx={{ my: 5, px: 2.5 }}>
                                <Stack direction="row" justifyContent="center" spacing={{ xs: 0.5, sm: 1.5 }}>
                                  <Avatar alt={name} src={avatarUrl} sx={{ width: 100, height: 100 }} />
                                </Stack>
                                <Stack direction="row" justifyContent="space-around" spacing={{ xs: 0.5, sm: 1.5 }}>
                                  <Typography variant="h4" sx={{ mb: 3, display: 'inline-block' }} noWrap>
                                    Name: {popOverName}
                                  </Typography>
                                  <Typography variant="h4" sx={{ mb: 3, display: 'inline-block' }} noWrap>
                                    Username: {popOverUserName}
                                  </Typography>
                                </Stack>
                                {(POSTS.length === 0) && (<><img src={noPostsFound} alt="posts" style={{ width: '400px', margin: '0 auto' }} />
                                  <Typography variant="h3" sx={{ mb: 3, textAlign: 'center' }}>No posts found for this user</Typography>
                                </>)}
                                <Grid container spacing={1}>
                                  {POSTS.map((post, index) => (
                                    <BlogPostCard key={post.id} post={post} index={index} />
                                  ))}
                                </Grid>
                              </Box>
                            </UserDetailsPopOver>
                            <Typography variant="subtitle2" noWrap>
                              {name}
                            </Typography>
                          </Stack>
                        </TableCell>
                        <TableCell align="left">{username}</TableCell>
                        <TableCell align="left">{userDesignation(authLevel)}</TableCell>
                        <TableCell align="left">
                          <Label variant="ghost" color={(userStatus === 'banned' && 'error') || 'success'}>
                            {sentenceCase(userStatus)}
                          </Label>
                        </TableCell>
                        {loggedInAuthLevel !== "0" && <TableCell align="left" sx={{ filter: 'blur(8px)' }} className="emailUserListClass">{email}</TableCell>}
                        {loggedInAuthLevel === "0" && <TableCell align="left">{email}</TableCell>}
                        {loggedInAuthLevel === "0" && <TableCell align="left">{phone}</TableCell>}
                        {loggedInAuthLevel === "0" && <TableCell align="left">{country}</TableCell>}
                        {loggedInAuthLevel === "0" && <TableCell align="left">{address}</TableCell>}

                      </TableRow>
                    );
                  })}
                  {emptyRows > 0 && (
                    <TableRow style={{ height: 53 * emptyRows }}>
                      <TableCell colSpan={6} />
                    </TableRow>
                  )}
                </TableBody>

                {isUserNotFound && (
                  <TableBody>
                    <TableRow>
                      <TableCell align="center" colSpan={6} sx={{ py: 3 }}>
                        <SearchNotFound searchQuery={filterName} />
                      </TableCell>
                    </TableRow>
                  </TableBody>
                )}
              </Table>
            </TableContainer>
          </Scrollbar>

          <TablePagination
            rowsPerPageOptions={[5, 10, 25]}
            component="div"
            count={USERLIST.length}
            rowsPerPage={rowsPerPage}
            page={page}
            onPageChange={handleChangePage}
            onRowsPerPageChange={handleChangeRowsPerPage}
          />
        </Card>
      </Container>
      <Snackbar open={success} autoHideDuration={4000} onClose={handleClose} message={message} />
    </Page>
  );
}
