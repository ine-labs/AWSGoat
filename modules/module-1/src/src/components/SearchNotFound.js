import PropTypes from 'prop-types';
// material
import { Paper } from '@mui/material';

// ----------------------------------------------------------------------

SearchNotFound.propTypes = {
  searchQuery: PropTypes.string,
};

export default function SearchNotFound({ searchQuery = '', ...other }) {
  return (
    <Paper {...other}>
      {// eslint-disable-next-line
      <p style={{ textAlign: 'center' }}>Results for <strong dangerouslySetInnerHTML={{ __html: searchQuery }}/></p>}
    </Paper>
  );
}
