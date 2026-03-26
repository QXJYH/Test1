import { useEffect, useState } from "react";
import { createContainer } from "unstated-next";
import getFlag from "../lib/getFlag";
import { getItemDetails, searchCatalog } from "../services/catalog";
import {useRouter} from "next/dist/client/router";
import { isLibraryItem } from "../services/games";

const stringToCategory = str => {
  return str;
}

const stringToAssetType = str => {
  if (typeof str === 'number') return str;
  switch (str.toLowerCase().trim()) {
    case 'models':
      return 10;
    case 'audio':
      return 3;
    case 'decals':
      return 13;
    case 'plugins':
      return 38;
    case 'meshes':
      return 4;
    case 'videos':
      return 62;
  }
  return 10; // Default to Models
}

const stringToSubCategory = str => {
  return str;
}

const LibraryStore = createContainer(() => {
  const router = useRouter();
  const [query, setQuery] = useState(router.query.keyword || '');
  const [page, setPage] = useState(1);
  const [limit, setLimit] = useState(getFlag('catalogPageLimit', 28));
  const [category, setCategory] = useState("Models");
  const [subCategory, setSubCategory] = useState('');
  const [locked, setLocked] = useState(false);
  const [results, setResults] = useState(null);
  const [total, setTotal] = useState(null);
  const [nextCursor, setNextCursor] = useState(null);
  const [previousCursor, setPreviousCursor] = useState(null);
  const [cursor, setCursor] = useState(null);
  const [sort, setSort] = useState(0);
  const [genres, setGenres] = useState([]);
  const [creatorName, setCreatorName] = useState(null);
  const [includeOffsale, setIncludeOffsale] = useState(null);


  useEffect(() => {
    setLocked(true);
    let response = null;
    searchCatalog({
      category: stringToCategory(category),
      assetType: stringToAssetType(category),
      subCategory: stringToSubCategory(category),
      query,
      limit,
      cursor,
      sort,
      creatorName,
      includeNotForSale: includeOffsale,
      genres,
    })
      .then(result => {
        response = result;
        if (response.data.length === 0) {
          return [];
        }
        return getItemDetails(result.data.map(v => v.id));
      })
      .then(assetDetails => {
        let arr = [];
        const targetedAssetType = stringToAssetType(category);
        // do it this way to preserve sort
        for (const item of response.data) {
          let details = assetDetails.data.data.find(v => v.id === item.id);
          if (details && details.assetType === targetedAssetType) arr.push(details);
        }
        response.data = arr;
        setResults(response);
        setNextCursor(response.nextPageCursor);
        setPreviousCursor(response.previousPageCursor);
        let total = response._total;
        setTotal(typeof total === 'number' ? total : null);
      })
      .finally(() => {
        setLocked(false);
      })
  }, [cursor, sort, category, subCategory, genres, query, limit, includeOffsale, creatorName]);

  const clearStatesForNewQuery = () => {
    setCursor(null);
    setPage(1);
  }

  return {
    locked,
    results,
    total,

    nextCursor,
    previousCursor,
    setCursor,

    sort,
    setSort,

    category,
    setCategory: (newCat) => {
      clearStatesForNewQuery();
      setCategory(newCat);
    },
    stringToCategory,

    subCategory,
    setSubCategory: (newSubCat) => {
      clearStatesForNewQuery();
      setSubCategory(newSubCat);
    },
    stringToSubCategory,

    genres,
    setGenres: (newGenres) => {
      clearStatesForNewQuery();
      setGenres(newGenres);
    },

    query,
    setQuery: (newQuery) => {
      clearStatesForNewQuery();
      setQuery(newQuery);
    },

    limit,
    setLimit: (newLimit) => {
      clearStatesForNewQuery();
      setLimit(newLimit);
    },

    page,
    setPage,

    creatorName,
    setCreatorName,

    includeOffsale,
    setIncludeOffsale
  }
});

export default LibraryStore;