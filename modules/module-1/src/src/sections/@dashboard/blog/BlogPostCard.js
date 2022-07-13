import PropTypes from 'prop-types';
import { Link as RouterLink } from 'react-router-dom';
// material
import { alpha, styled } from '@mui/material/styles';
import { Link, Card, Grid, Typography, CardContent } from '@mui/material';
// utils
import { fDate } from '../../../utils/formatTime';
//
import SvgIconStyle from '../../../components/SvgIconStyle';

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
};

export default function BlogPostCard({ post }) {
  const { getRequestImageData, postTitle, postingDate } = post;

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

          <CoverImgStyle alt={postTitle} src={getRequestImageData} />
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
            {fDate(postingDate)}
          </Typography>

          <Typography gutterBottom variant="caption" sx={{ color: 'common.white', display: 'block' }}>
            {post.authorName}
          </Typography>

          <TitleStyle
            to={`/blogpost/${post.id}`}
            state={{ authorName: post.authorName, getRequestImageData: post.getRequestImageData, postContent: post.postContent, postTitle: post.postTitle, postingDate: post.postingDate }}
            color="inherit"
            variant="subtitle2"
            underline="hover"
            component={RouterLink}
            sx={{
                color: 'common.white',
                typography: 'h5', height: 60
              // }),
            }}
          >
            {postTitle}
          </TitleStyle>

        </CardContent>
      </Card>
    </Grid>
  );
}
