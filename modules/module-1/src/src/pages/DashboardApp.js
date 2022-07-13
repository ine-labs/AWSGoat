import { useEffect, useState } from 'react';
import { faker } from '@faker-js/faker';
import { Grid, Container, Typography } from '@mui/material';
import { getUser } from '../sections/auth/AuthService';
import Page from '../components/Page';
import {
  AppOrderTimeline,
  AppWebsiteVisits,
  AppWidgetSummary,
} from '../sections/@dashboard/app';
import httpService from '../common/httpService';

export default function DashboardApp() {
  const [newChartLabel, setNewChartLabel] = useState([]);
  const [newChartData, setNewChartData] = useState([]);
  const [newChartRecentUsersName, setNewChartRecentUsersName] = useState('');
  // const [newChartRecentUsersDates, setNewChartRecentUsersDates] = useState([]);
  const [totalPostsTab, setTotalPostsTab] = useState('');
  const [totalUsersTab, setTotalUsersTab] = useState('');
  const [recentPostsTab, setRecentPostsTab] = useState('');
  const user = getUser();
  const name = user !== 'undefined' && user ? user.name : '';
  
  useEffect(() => {
    httpService.post(('/get-dashboard')).then((response) => {
      const d = new Date();
      // setNewChartRecentUsersDates(response.data.body.recentUserDates)
      setRecentPostsTab(response.data.body.chartData[d.getMonth()])
      setNewChartLabel(response.data.body.chartLabel)
      setNewChartData(response.data.body.chartData)
      setTotalPostsTab(response.data.body.totalPosts)
      setTotalUsersTab(response.data.body.totalUsers)
      setNewChartRecentUsersName(response.data.body.recentUserNames)
    }).catch((error) => {
      console.error("Dashboard error", error);
    })
  }, []);
  

  return (
    <Page title="Dashboard">
      <Container maxWidth="xl">
        <Typography variant="h4" sx={{ mb: 5 }}>
          Welcome back, {name}
        </Typography>

        <Grid container spacing={3}>
          <Grid item xs={12} sm={6} md={3}>
            <AppWidgetSummary title="Total Posts" total={Number(totalPostsTab)}  color="success"/>
          </Grid>

          <Grid item xs={12} sm={6} md={3}>
            <AppWidgetSummary title="Total Users" total={Number(totalUsersTab)} color="warning" />
          </Grid>

          <Grid item xs={12} sm={6} md={3}>
            <AppWidgetSummary title="Recent Users" total={Number(newChartRecentUsersName.length)} color="info" />
          </Grid>

          <Grid item xs={12} sm={6} md={3}>
            <AppWidgetSummary title="Recent Posts" total={Number(recentPostsTab)} color="error" />
          </Grid>

          <Grid item xs={12} md={6} lg={8}>
            <AppWebsiteVisits
              title="Post Analytics"
              subheader=""
              chartLabels={newChartLabel}
              chartData={[
                {
                  name: 'Posts',
                  type: 'area',
                  fill: 'solid',
                  data: newChartData,
                },
              ]}
            />
          </Grid>

          <Grid item xs={12} md={6} lg={4}>
            <AppOrderTimeline
              title="Recent Users"
              list={[...Array(5)].map((_, index) => ({
                id: faker.datatype.uuid(),
                title: [newChartRecentUsersName][0][index],
                type: `order${index + 1}`,
              }))}
              />
          </Grid>
        </Grid>
      </Container>
    </Page>
  );
}
