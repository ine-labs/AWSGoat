import PropTypes from 'prop-types';
// material
import { Popover } from '@mui/material';
// import { alpha, styled } from '@mui/material/styles';

// ----------------------------------------------------------------------

UserDetailsPopOver.propTypes = {
    children: PropTypes.node.isRequired,
    sx: PropTypes.object,
};

export default function UserDetailsPopOver({ children, sx, ...other }) {
    return (
        <Popover
            anchorOrigin={{ vertical: 'bottom', horizontal: 'left' }}
            transformOrigin={{ vertical: 'bottom', horizontal: 'left' }}
            PaperProps={{
                sx: {
                    width: 1000,
                    height: 700,
                    overflow: 'inherit',
                    ...sx,
                },
            }}
            {...other}
        >
            {children}
        </Popover>
    );
}
