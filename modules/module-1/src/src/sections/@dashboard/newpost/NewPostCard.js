import PropTypes from 'prop-types';
import { Link as RouterLink } from 'react-router-dom';
// material
import { alpha, styled } from '@mui/material/styles';
// import { Box, Link, Card, Grid, Avatar, Typography, CardContent } from '@mui/material';
import { Link, Card, Grid, Avatar, Typography, CardContent } from '@mui/material';
// utils
import { fDate } from '../../../utils/formatTime';
// import { fShortenNumber } from '../../../utils/formatNumber';
//
import SvgIconStyle from '../../../components/SvgIconStyle';
// import Iconify from '../../../components/Iconify';

// ----------------------------------------------------------------------

const CardMediaStyle = styled('div')({
  position: 'relative',
  paddingTop: 'calc(100% * 3 / 4)',
});

const TitleStyle = styled(Link)({
  height: 484,
  overflow: 'hidden',
  WebkitLineClamp: 2,
  display: '-webkit-box',
  WebkitBoxOrient: 'vertical',
});

const AvatarStyle = styled(Avatar)(({ theme }) => ({
  zIndex: 9,
  width: 32,
  height: 32,
  position: 'absolute',
  left: theme.spacing(3),
  bottom: theme.spacing(-2),
}));

// const InfoStyle = styled('div')(({ theme }) => ({
//   display: 'flex',
//   flexWrap: 'wrap',
//   justifyContent: 'flex-end',
//   marginTop: theme.spacing(3),
//   color: theme.palette.text.disabled,
// }));

const CoverImgStyle = styled('img')({
  top: 0,
  width: '100%',
  height: '100%',
  objectFit: 'cover',
  position: 'absolute',
});

// ----------------------------------------------------------------------

BlogPostCard.propTypes = {
  post: PropTypes.object.isRequired,
  // index: PropTypes.number,
};

export default function BlogPostCard({ post }) {
  const { cover, title, author, createdAt } = post;

  return (
    <Grid item xs={12} sm={12} md={12}>
      <Card sx={{ position: 'relative' }}>
        <CardMediaStyle
          sx={{
              pt: 'calc(100%/4)',
              '&:after': {
                top: 0,
                content: "''",
                width: '100%',
                height: '100%',
                position: 'absolute',
                bgcolor: (theme) => alpha(theme.palette.grey[900], 0.72),
              },
          }}
        >
          <SvgIconStyle
            color="paper"
            src="/static/icons/shape-avatar.svg"
            sx={{
              width: 80,
              height: 36,
              zIndex: 9,
              bottom: -15,
              position: 'absolute',
              color: 'background.paper',
              display: 'none',
            }}
          />
          <AvatarStyle
            alt={author.name}
            src={author.avatarUrl}
            sx={{
                zIndex: 9,
                top: 24,
                left: 24,
                width: 40,
                height: 40,
            }}
          />

          <CoverImgStyle alt={title} src={cover} />
        </CardMediaStyle>

        <CardContent
          sx={{
            pt: 4,
              bottom: 0,
              width: '100%',
              position: 'absolute',
            // }),
          }}
        >
          <Typography gutterBottom variant="caption" sx={{ color: 'text.disabled', display: 'block' }}>
            {fDate(createdAt)}
          </Typography>

          <TitleStyle
            to="#"
            color="inherit"
            variant="subtitle2"
            underline="hover"
            component={RouterLink}
            sx={{
                color: 'common.white',
                typography: 'h5', height: 60
            }}
          >
            {title}
          </TitleStyle>

        </CardContent>
      </Card>
    </Grid>
  );
}
