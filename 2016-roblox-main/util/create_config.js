const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const configPath = path.join(__dirname, '../config.json');

const main = () => {
  if (fs.existsSync(configPath)) {
    console.error('config.json already exists at this path:', configPath, '\n\nIf you want to create a fresh config, manually delete or move this file first, then run this script again.');
    return
  }
  fs.writeFileSync(configPath, JSON.stringify({
    "serverRuntimeConfig": {
      backend: {
        csrfKey: crypto.randomBytes(64).toString('base64'),
      }
    },
    "publicRuntimeConfig": {
      "backend": {
      "proxyEnabled": true,
      "flags": {
        "myAccountPage2016Enabled": true,
        "catalogGenreFilterSupported": true,
        "catalogPageLimit": 28,
        "catalogSaleCountVisibleFromDetailsEndpoint": true,
        "commentsEndpointHasAreCommentsDisabledProp": true,
        "catalogDetailsPageResellerLimit": 10,
        "avatarPageInventoryLimit": 10,
        "friendsPageLimit": 25,
        "settingsPageThemeSelectorEnabled": true,
        "tradeWindowInventoryCollectibleLimit": 10,
        "moneyPagePromotionTabVisible": false,
        "gameGenreFilterSupported": true,
        "avatarPageOutfitCreatedAtAvailable": true,
        "catalogDetailsPageOwnersTabEnabled": true,
        "launchUsingEsURI": true,
        "downloadPageEnabled": true,
        "downloadGameClients": [
          {
            "title": "Windows Kornet Launcher",
            "url": "https://cdn.kornet.lat/KornetLauncher.exe",
            "imageUrl": "/korcdns/windows.png"
          },
          {
            "title": "Linux {SOON}",
            "url": "/download",
            "imageUrl": "/korcdns/Linux.png"
          },
          {
            "title": "Kornet FPS Unlocker",
            "url": "https://github.com/unknownluau/kornetfpsunlocker/releases/latest",
            "imageUrl": "/korcdns/fpsunlocker.png"
          }
        ]
      },
      "baseUrl": "https://kornet.lat/",
      "apiFormat": "https://kornet.lat/apisite/{0}{1}"
    }
    },
  }));
  console.log('config.json created at this path:', configPath);
  return 0
}

main();