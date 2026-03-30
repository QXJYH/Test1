import React from "react";
import { createUseStyles } from "react-jss";
import LoginModalStore from "../../../stores/loginModal";
import LoginModal from "../../loginModal";
import getFlag from "../../../lib/getFlag";
import { useRouter } from "next/dist/client/router";

const useLoginAreaStyles = createUseStyles({
  text: {
    color: 'white',
    fontWeight: 400,
    fontSize: '16px',
    borderBottom: 0,
    marginTop: '2px',
    marginBottom: 0,
    textAlign: 'right',
    whiteSpace: 'nowrap',
  },
  link: {
    color: 'white',
    textDecoration: 'none',
    padding: '4px 8px',
    '&:hover': {
      color: 'white',
      background: 'rgba(25,25,25,0.1)',
      cursor: 'pointer',
      borderRadius: '4px',
    },
  },
});

const LoginArea = props => {
  const Router = useRouter();
  const s = useLoginAreaStyles();
  const loginModalStore = LoginModalStore.useContainer();

  return <div className='row'>
    <div className='col-6 offset-6' style={{ marginTop: '3px' }}>
      <div className='row'>
        <div className='col-6'>
          <p className={s.text}>
            <a className={s.link} onClick={(e) => {
              e.preventDefault();
              if (getFlag('clientSideRenderingEnabled', false)) {
                Router.push('/');
              } else {
                window.location.href = '/';
              }
              return;
            }}>
              Sign Up
            </a>
          </p>
        </div>
        <div className='col-6'>
          <p className={s.text}>
            <a className={s.link} onClick={(e) => {
              e.preventDefault();
              if (getFlag('clientSideRenderingEnabled', false)) {
                Router.push('/auth');
              } else {
                window.location.href = '/auth';
              }
              return;
            }}>
              Login
            </a>
          </p>
          {loginModalStore.open && <LoginModal></LoginModal>}
        </div>
      </div>
    </div>
  </div>
}

export default LoginArea;