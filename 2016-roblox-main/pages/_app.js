import '../styles/globals.css';
import '../styles/helpers/textHelpers.css';
import 'bootstrap/dist/css/bootstrap.min.css';
// Roblox CSS
import '../styles/roblox/icons.css';

import Navbar from '../components/navbar';
import React, { useEffect } from 'react';
import Head from 'next/head';
import Footer from '../components/footer';
import dayjs from '../lib/dayjs';
import NextNProgress from "nextjs-progressbar";

import LoginModalStore from '../stores/loginModal';
import AuthenticationStore from '../stores/authentication';
import NavigationStore from '../stores/navigation';
import { getTheme, themeType } from '../services/theme';
import MainWrapper from '../components/mainWrapper';
import GlobalAlert from '../components/globalAlert';
import ThumbnailStore from "../stores/thumbnailStore";
import getFlag from "../lib/getFlag";
import Chat from "../components/chat";

import { useRouter } from 'next/router';

if (typeof window !== 'undefined') {
  console.log(String.raw`
      _______      _________      _____       ______     _
     / _____ \    |____ ____|    / ___ \     | ____ \   | |
    / /     \_\       | |       / /   \ \    | |   \ \  | |
    | |               | |      / /     \ \   | |   | |  | |
    \ \______         | |      | |     | |   | |___/ /  | |
     \______ \        | |      | |     | |   |  ____/   | |
            \ \       | |      | |     | |   | |        | |
     _      | |       | |      \ \     / /   | |        |_|
    \ \_____/ /       | |       \ \___/ /    | |         _
     \_______/        |_|        \_____/     |_|        |_|

     Keep your account safe! Do not paste any text here.
	`);
}

function RobloxApp({ Component, pageProps }) {
  const router = useRouter();

  useEffect(() => {
    const body = document.body;
    if (!body) return;

    // ✅ FORCE gray background on /catalog (ALL THEMES)
    if (router.pathname.startsWith('/catalog')) {
      body.style.background = '#e3e3e3';
      return;
    }

    // 🔁 Existing theme logic for all other pages
    const theme = getTheme();
    const divBackground =
      theme === themeType.obc2016
        ? 'url(/img/Unofficial/obc_theme_2016_bg.png) repeat-x #222224'
        : document.getElementById('theme-2016-enabled')
          ? '#e3e3e3'
          : '#fff';

    body.style.background = divBackground;
  }, [router.pathname, pageProps]);

  return (
    <div>
      <Head>
        <meta name="google-adsense-account" content="ca-pub-6473896353743849" />
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="" />
        <title>{pageProps.title || 'Kornet'}</title>
        <link rel="icon" type="image/vnd.microsoft.icon" href="/favicon.ico" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </Head>

      <AuthenticationStore.Provider>
        <LoginModalStore.Provider>
          <NavigationStore.Provider>
            <Navbar />
          </NavigationStore.Provider>
        </LoginModalStore.Provider>

        <GlobalAlert />

        <MainWrapper>
          {getFlag('clientSideRenderingEnabled', false) ? (
            <NextNProgress options={{ showSpinner: false }} color="#fff" height={2} />
          ) : null}

          <ThumbnailStore.Provider>
            <Component {...pageProps} />
            <Chat />
          </ThumbnailStore.Provider>
        </MainWrapper>

        <Footer />
      </AuthenticationStore.Provider>
    </div>
  );
}

export default RobloxApp;
