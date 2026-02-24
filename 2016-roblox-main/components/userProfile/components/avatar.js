import { useEffect, useRef, useState } from "react";
import { createUseStyles } from "react-jss"
import { getAvatar } from "../../../services/avatar";
import { getItemUrl, itemNameToEncodedName } from "../../../services/catalog";
import ItemImage from "../../itemImage";
import PlayerImage from "../../playerImage"
import Subtitle from "./subtitle"
import Link from "../../link";
import { Thumbnail3DHandler } from "../../thumbnail3D";
import UserProfileStore from "../stores/UserProfileStore";

const useAvatarStyles = createUseStyles({
  avatarImageWrapper: {
    maxWidth: '300px',
    margin: '0 auto',
    display: 'block',
  },
  assetContainerCard: {
    background: '#3b7599',
    height: '100%',
    borderRadius: 0,
  },
  avatarImageCard: {
    borderRadius: 0,
  },
  pagination: {
    textAlign: 'center',
    marginBottom: 0,
    color: 'white',
    fontSize: '28px',
    fontFamily: 'serif',
    '&>span': {
      cursor: 'pointer',
    }
  },
  disabledPagination: {

  },
  thumbnail3DButtonContainer: {
    display: 'flex',
    position: 'absolute',
    top: 5,
    right: 5,
    zIndex: 3,
  },
  thumbnail3DButton: {
    padding: '4px 8px',
    cursor: 'pointer',
    fontSize: '12px',
    background: '#fff',
    border: '1px solid #777',
    borderRadius: '3px'
  },
  avatarImageSpinner: {
    display: 'flex',
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    top: 0,
    height: '100%',
    width: '100%',
    zIndex: 2,
    alignItems: 'center',
    justifyContent: 'center'
  },
});

const Avatar = props => {
  const s = useAvatarStyles();
  const { userId } = props;
  const assetsLimit = 8;
  const [assets, setAssets] = useState(null);
  const [selectedAssets, setSelectedAssets] = useState(null);
  const [assetPages, setAssetPages] = useState(1);
  const [assetPage, setAssetPage] = useState(1);

  const store = UserProfileStore.useContainer();
  const [thumbType, setThumbType] = useState(0);
  const [is3DReady, set3DReady] = useState(false);
  const canvasParentRef = useRef(null);
  const [thumb3D, setThumb3D] = useState(new Thumbnail3DHandler());

  useEffect(() => {
    getAvatar({ userId }).then(d => {
      if (!d || !d.assets) return;
      setAssets(d.assets);
      setSelectedAssets(d.assets.slice(0, assetsLimit));
      setAssetPage(1);
      setAssetPages(Math.ceil(d.assets.length / assetsLimit));
    })
  }, [userId]);

  useEffect(() => {
    if (thumbType === 1 && (!store || !store.userAv3D || !store.userAv3D.camera)) {
      thumb3D.Stop();
      setThumbType(0);
      return;
    }

    if (thumbType !== 1) {
      thumb3D.Stop();
    } else if (thumbType === 1 && !thumb3D.isLoadingThumbnail) {
      thumb3D.LoadThumbnail(store.userAv3D, canvasParentRef.current, set3DReady);
    }
  }, [thumbType, store.userId, userId, store.userAv3D]);

  useEffect(() => {
    if (typeof window !== "undefined" && typeof window.THREE !== "undefined" && thumb3D.scene === null) {
      thumb3D.Init(300);
    }
    return () => {
      thumb3D.Dispose();
      setThumb3D(new Thumbnail3DHandler());
      setThumbType(0);
    };
  }, [store.userId]);

  return <div className='row'>
    <div className='col-12'>
      <Subtitle>Currently Wearing</Subtitle>
    </div>
    <div className='col-12 col-lg-6 pe-0'>
      <div className={'card ' + s.avatarImageCard} style={{ position: 'relative', minHeight: '300px' }}>
        <div className={s.avatarImageWrapper} ref={canvasParentRef} style={{ minHeight: '300px' }}>
          <div style={{ display: thumbType === 1 ? 'none' : 'block' }}>
            <PlayerImage id={userId} />
          </div>
          {
            thumbType === 1 && !is3DReady ?
              <div className={s.avatarImageSpinner}>
                <span>Loading 3D...</span>
              </div>
              : null
          }
        </div>
        <div className={s.thumbnail3DButtonContainer}>
          <button
            className={s.thumbnail3DButton}
            onClick={() => setThumbType(thumbType === 1 ? 0 : 1)}
          >
            {thumbType === 1 ? "2D" : "3D"}
          </button>
        </div>
      </div>
    </div>
    <div className='col-12 col-lg-6 ps-0'>
      <div className={'card ' + s.assetContainerCard}>
        <div className='row ps-4 pe-4 pt-4 pb-4'>
          {selectedAssets && selectedAssets.map(v => {
            return <div className='col-3 pt-2 ps-1 pe-1' key={v.id}>
              <div className='card' title={v.name}>
                <Link href={getItemUrl({ name: v.name, assetId: v.id })}>
                  <a title={v.name}>
                    <ItemImage id={v.id} className='pt-0' />
                  </a>
                </Link>
              </div>
            </div>
          })}
        </div>
        <div className='row'>
          <div className='col-12'>
            {
              assetPages > 1 && <p className={s.pagination}>
                {
                  [...new Array(assetPages)].map((_, v) => {
                    const disabled = (v + 1) === assetPage;
                    if (disabled) {
                      return <span className={s.disabledPagination}>●</span>
                    }
                    return <span onClick={() => {
                      setAssetPage(v + 1);
                      let offset = (v + 1) * assetsLimit - assetsLimit;
                      setSelectedAssets(assets.slice(offset, offset + assetsLimit));
                    }}>○</span>
                  })
                }
              </p>
            }
          </div>
        </div>
      </div>
    </div>
  </div>
}

export default Avatar;