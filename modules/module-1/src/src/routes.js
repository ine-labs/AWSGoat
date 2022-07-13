import { Navigate, useRoutes } from 'react-router-dom';
import DashboardLayout from './layouts/dashboard';
import Blog from './pages/Blog';
import User from './pages/User';
import Login from './pages/Login';
import NotFound from './pages/Page404';
import Register from './pages/Register';
import ResetPassword from './pages/ResetPassword';
import NewPost from './pages/NewPost';
import DashboardApp from './pages/DashboardApp';
import Profile from './pages/Profile';
import HomePage from './pages/HomePage';
import Blogpost from './pages/blogpost';

import { getToken } from './sections/auth/AuthService';

// ----------------------------------------------------------------------

export default function Router() {
  return useRoutes([
    {
      path: '/dashboard',
      element: getToken()? <DashboardLayout />:<Navigate to='/home'/>,
      children: [
        { path: '/dashboard', element: <Navigate to="/dashboard/app" /> },
        { path: 'app', element: <DashboardApp /> },
        { path: 'user', element: <User /> },
        { path: 'posts', element: <Blog /> },
        { path: 'newpost', element: <NewPost /> },
        { path: 'profile', element: <Profile /> },
      ],
    },
    {
      path: '/',
      children: [
        { path: '/', element: <Navigate to="/home" /> },
        { path: '/home', element: <HomePage /> },
        { path: 'login', element: <Login /> },
        { path: 'reset-password', element: <ResetPassword /> },
        { path: 'register', element: <Register /> },
        { path: '404', element: <NotFound /> },
        { path: '/blogpost/:id', element: <Blogpost /> },
        { path: '*', element: <Navigate to="/404" /> },
      ],
    },
    { path: '*', element: <Navigate to="/404" replace /> },
  ]);
}
