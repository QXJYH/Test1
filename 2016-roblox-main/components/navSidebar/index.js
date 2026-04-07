import React, { useEffect, useState } from "react";
import { createUseStyles } from "react-jss";
import AuthenticationStore from "../../stores/authentication";
import NavigationStore from "../../stores/navigation";
import LinkEntry from "./components/linkEntry";
import request, { getFullUrl } from "../../lib/request";

const useNavSideBarStyles = createUseStyles({
  container: {
    position: 'fixed',
    top: 0,
    left: 0,
    zIndex: 999,
  },
  card: {
    width: '175px',
    background: '#252525',
    height: '100vh',
    paddingLeft: '10px',
    paddingRight: '10px',
    color: '#ffffff',
  },
  userWrapper: {
    display: 'flex',
    alignItems: 'center',
    paddingTop: '8px',
    paddingBottom: '5px',
    textDecoration: 'none',
    '&:hover': {
      opacity: 0.8,
    }
  },
  headshot: {
    width: '32px',
    height: '32px',
    marginRight: '8px',
    borderRadius: '50%',
    backgroundColor: '#3d3d3d',
    flexShrink: 0,
    objectFit: 'cover',
    boxShadow: 'rgba(25, 25, 25, 0.3) 0px 1px 4px 0px',
  },
  username: {
    fontSize: '16px',
    fontWeight: 'bold',
    color: '#ffffff',
    margin: 0,
    overflow: 'hidden',
    textOverflow: 'ellipsis',
    whiteSpace: 'nowrap',
  },
  divider: {
    borderBottom: '2px solid #c3c3c3',
    height: '2px',
    width: '100%',
    marginBottom: '5px',
  },
  upgradeNowButton: {
    marginTop: '10px',
    background: '#01a2fd',
    fontSize: '15px',
    fontWeight: 500,
    width: '100%',
    paddingTop: '8px',
    paddingBottom: '8px',
    textAlign: 'center',
    color: 'white',
    borderRadius: '4px',
    textDecoration: 'none',
    display: 'block',
    '&:hover': {
      background: '#3ab8ff',
    },
  },
});

const NavSideBar = props => {
  const authStore = AuthenticationStore.useContainer();
  const navStore = NavigationStore.useContainer();
  const mainNavBarRef = props.mainNavBarRef;
  const [dimensions, setDimensions] = useState({
    height: typeof window !== 'undefined' ? window.innerHeight : 0,
    width: typeof window !== 'undefined' ? window.innerWidth : 0
  });
  const [userData, setUserData] = useState(null);
  const [pendingCount, setPendingCount] = useState(0);
  const s = useNavSideBarStyles();

  useEffect(() => {
    const handleResize = () => {
      setDimensions({
        height: window.innerHeight,
        width: window.innerWidth
      });
    };

    window.addEventListener('resize', handleResize);

    const getStaffData = async () => {
      try {
        const response = await request('GET', getFullUrl('users', '/v1/users/authenticated'));
        setUserData(response.data);

        if (response.data.isStaff) {
          const [pendingIcons, pendingAssets, pendingGroupIcons] = await Promise.all([
            request('GET', `/admin-api/api/icons/pending-assets`),
            request('GET', `/admin-api/api/assets/pending-assets`),
            request('GET', `/admin-api/api/groups/pending-icons`)
          ]);

          let count = 0;
          if (pendingIcons.data) count += pendingIcons.data.length;
          if (pendingAssets.data) count += pendingAssets.data.length;
          if (pendingGroupIcons.data) count += pendingGroupIcons.data.length;

          setPendingCount(count);
        }
      } catch (error) { }
    };

    getStaffData();
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  const paddingTop = (mainNavBarRef?.current && mainNavBarRef.current.clientHeight + 'px') || '40px';

  const isDesktop = false; //dimensions.width > 1300;

  if (!isDesktop && navStore.isSidebarOpen === false) {
    return null;
  }

  return (
    <div className={s.container}>
      <div className={s.card} style={{ paddingTop: paddingTop }}>
        <a href={'/users/' + authStore.userId + '/profile'} className={s.userWrapper}>
          <img
            className={s.headshot}
            src={`/thumbs/avatar-headshot.ashx?userId=${authStore.userId}&width=48&height=48&v=${Date.now()}`}
            alt="User"
          />
          <p className={s.username}>{authStore.username}</p>
        </a>
        <div className={s.divider} />
        <LinkEntry name='Home' url='/home' icon='icon-nav-home' />
        <LinkEntry name='Profile' url={'/users/' + authStore.userId + '/profile'} icon='icon-nav-profile' />
        <LinkEntry name='Messages' url='/My/Messages' icon='icon-nav-message' count={authStore.notificationCount.messages} />
        <LinkEntry name='Friends' url={'/users/' + authStore.userId + '/friends'} icon='icon-nav-friends' count={authStore.notificationCount.friendRequests} />
        <LinkEntry name='Avatar' url='/My/Avatar' icon='icon-nav-charactercustomizer' />
        <LinkEntry name='Inventory' url={'/users/' + authStore.userId + '/inventory'} icon='icon-nav-inventory' />
        <LinkEntry name='Trade' url='/My/Trades.aspx' icon='icon-nav-trade' count={authStore.notificationCount.trades} />
        <LinkEntry name='Groups' url='/My/Groups.aspx' icon='icon-nav-group' />
        {userData?.isStaff && <LinkEntry name='Control Panel' url='/admin' icon='icon-nav-settings' count={pendingCount} />}
        <LinkEntry name='Promocodes' url='/promocodes' icon='icon-nav-forum' />
        <a href='/BuildersClub/Upgrade.ashx' className={s.upgradeNowButton}>Upgrade Now</a>
      </div>
    </div>
  );
}

export default NavSideBar;