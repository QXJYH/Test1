import Head from "next/head";
import SharedAssetPage from "../../../components/sharedAssetPage";
import { getProductInfoLegacy } from "../../../services/catalog";

const ItemPage = (props) => {
  return (
    <>
      <Head>
        <title>{props.title}</title>
        <meta property="og:site_name" content="Kornet" />
        <meta property="og:title" content={props.name} />
        <meta property="og:description" content={props.description} />
        <meta property="og:image" content={`https://kornet.lat/Thumbs/Asset.ashx?assetId=${props.assetId}&width=420&height=420`} />
      </Head>
      <SharedAssetPage idParamName='assetId' nameParamName='name' />
    </>
  );
};

export async function getServerSideProps({ query }) {
  const assetId = query.assetId;
  const nameFromUrl = query.name ? query.name.replace(/-/g, ' ') : 'Item';
  const defaultDesc = 'No description available.';

  try {
    const info = await getProductInfoLegacy(assetId);
    return {
      props: {
        assetId,
        name: info.Name || nameFromUrl,
        description: info.Description || defaultDesc,
        title: (info.Name || nameFromUrl) + ' - Kornet'
      }
    };
  } catch (err) {
    // Falls back to URL name so Discord still shows SOMETHING even if API fails
    return {
      props: {
        assetId,
        name: nameFromUrl,
        description: defaultDesc,
        title: nameFromUrl + ' - Kornet'
      }
    };
  }
}

export default ItemPage;