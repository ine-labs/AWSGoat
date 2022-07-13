import { useRef, useState } from 'react';
import { Link as RouterLink } from 'react-router-dom';
import { alpha } from '@mui/material/styles';
import { Box, Divider, Typography, Stack, MenuItem, Avatar, IconButton } from '@mui/material';
import MenuPopover from '../../components/MenuPopover';
import account from '../../_mock/account';
import { resetUserSession, getUser, getToken } from '../../sections/auth/AuthService';


// ----------------------------------------------------------------------

const MENU_OPTIONS = [
  {
    label: 'Login',
    icon: 'eva:home-fill',
    linkTo: '/login',
  },
];

const LOGIN_MENU_OPTIONS = [
  {
    label: 'Logout',
    icon: 'eva:home-fill',
    linkTo: '/login',
  },
  {
    label: 'Dashboard',
    icon: 'eva:person-fill',
    linkTo: '/dashboard/app',
  },
];

  export default function HomepageAccountPopover() {
    
    const user = getUser();
    
    const displayName = user !== 'undefined' && user ? user.name : '';
    const email = user !== 'undefined' && user ? user.email : '';
    
    const anchorRef = useRef(null);
    
    const [open, setOpen] = useState(null);
    
    const handleOpen = (event) => {
      setOpen(event.currentTarget);
    };

  const handleClose = (event) => {
    if(event.target.innerText === "Logout") {
      resetUserSession();
    }
    setOpen(null);
  };

  return (
    <>
      <IconButton
        ref={anchorRef}
        onClick={handleOpen}
        sx={{
          p: 0,
          ...(open && {
            '&:before': {
              zIndex: 1,
              content: "''",
              borderRadius: '50%',
              position: 'absolute',
              bgcolor: (theme) => alpha(theme.palette.grey[900], 0.8),
            },
          }),
        }}
      >
        <Avatar src={account.photoURL} alt="photoURL" />
      </IconButton>

      <MenuPopover
        open={Boolean(open)}
        anchorEl={open}
        onClose={handleClose}
        sx={{
          p: 0,
          mt: 1.5,
          ml: 0.75,
          '& .MuiMenuItem-root': {
            typography: 'body2',
            borderRadius: 0.75,
          },
        }}
      >
        <Box sx={{ my: 1.5, px: 2.5 }}>
          <Typography variant="subtitle2" noWrap>
            {displayName}
          </Typography>
          <Typography variant="body2" sx={{ color: 'text.secondary' }} noWrap>
            {email}
          </Typography>
        </Box>

        <Divider sx={{ borderStyle: 'dashed' }} />

        {getToken() && (<Stack sx={{ p: 1 }}>
          {LOGIN_MENU_OPTIONS.map((option) => (
            <MenuItem key={option.label} to={option.linkTo} component={RouterLink} onClick={handleClose}>
              {option.label}
            </MenuItem>
          ))}
        </Stack>)
        }

        {!getToken() && (<Stack sx={{ p: 1 }}>
          {MENU_OPTIONS.map((option) => (
            <MenuItem key={option.label} to={option.linkTo} component={RouterLink} onClick={(e) => handleClose(e)}>
              {option.label}
            </MenuItem>
          ))}
        </Stack>)}
      </MenuPopover>
    </>
  );
}
