require("dotenv").config();
const express = require("express");
const axios = require("axios");
const path = require("path");
const fs = require("fs");

const app = express();
const cacheFolder = path.join(__dirname, "cache");

if (!fs.existsSync(cacheFolder)) {
    fs.mkdirSync(cacheFolder);
}

app.get("/v1/asset/", async (req, res) => {
    try {
        const id = req.query.id;
        if (!id) return res.status(400).send("Missing id");

        const filePath = path.join(cacheFolder, id);

        if (fs.existsSync(filePath)) {
            console.log(`Serving cached: ${id}`);
            return res.download(filePath, "asset");
        }

        const assetDeliveryApis = [
            "https://assetdelivery.synt2x.xyz/v1/asset", // might require a cookie as danyal wants syntax 2 to be a wannabe roblox. lol..
            "https://assetdelivery.pekora.zip/v1/asset", // ok
            "https://assetdelivery.cartii.fit/v1/asset", // ok
            "https://bt.zawg.ca/v1/asset", // ok
            "https://assetdelivery.roblox.com/v1/asset" // ok
        ];

        const headers = {
            "Cookie": `.ROBLOSECURITY=_|WARNING:-DO-NOT-SHARE-THIS.--Sharing-this-will-allow-someone-to-log-in-as-you-and-to-steal-your-ROBUX-and-items.|_CAEaAhADIhsKBGR1aWQSEzYzMjc5OTc4MzM3NTg2MjM0MDkoAw.Lj69ZYPBgSfH_ONbg2Lscyk24b2qti3xUkrs3XtMTWB9HzeCY27O3CuEyT7eA0BAmJx_OtwZGbz9FMnN853tSc2iW1o5wCPaR7xAold0tLvynvHnvbaL8XjcjdjFDAJVbI9F-0pVe8rcVopdI6XrZtGNxQA8qkoI4ArDXtcQFJY9W6vMOyI1Uhk5NbsnFQq-lJHIe8oiATnHgKTXIRq-BlgnnDl0ZmTFlfSXDgEUG5er1jYHl7Bb0tNSW8LuQEcVTab5ZtyC6NFj_AN60euUWOOeY8KhdTRmT_2IVnx5yZ_wrakDYXGtgFv8FKn_qCaItrVs87-df5RiaW8PDRPs47TAzExWeQ368D72LrsCKSUHJmaWmiC13Dos6KIhyffC0Ow-h9ZLTTOQK-2i-DgV9aE6FfpNDrqcQ3JRmlKolWReP4tNxL4eZ2kzXqFUKVvtjoITMaD1UYzM8OHTB_IhTx66lNNVske98Yl43K0hgfQrA5SG4dbfXNANorL0ZDr6AwejuSXqnCjbxt4uCawObRnES5irEOWb42lobCeiWnCqMHl4hbKTR4PNaCm_kPNs9x84jO0PGXqS1yRbq_GUc1NGaKR-YV1YcAaXHvd3JnwgLok-16y5d4P-aLC67nfxCANlW-QZ2Qy1ZhMcd5st1oF5HG4PbKLdVsxf9W7Vj2CE9IKdSI7f-cJU9_XSjSTW2R4ltPAxeYWXozdXEqxYlawhN1x4JW83kKl_zFGCPmy5Q63BLYRxzWkmGpzbH3Ac7-OFEQ`,
            // "Accept-Encoding": "gzip,deflate,br",
            "Accept": "*/*",
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36" //"Roblox/WinInet"
        };

        let successfulResponse = null;
        let finalurl = null;

        if (process.env.useMultiFetch) {
            const shuffled = assetDeliveryApis.sort(() => 0.5 - Math.random());

            for (const baseUrl of shuffled) {
                try {
                    const check = await axios.get(`${baseUrl}/?id=7702904`, { headers, timeout: 2500 });
                    if (check.status === 200) {
                        successfulResponse = await axios.get(`${baseUrl}/?id=${id}`, {
                            headers,
                            responseType: "stream",
                            timeout: 10000
                        });
                        finalurl = baseUrl
                        break;
                    }
                    console.log(`this fuckin failed by ${baseUrl} with id of ${id}`);
                } catch (err) {
                    continue;
                }
            }
        } else {
            const robloxUrl = `http://assetdelivery.roblox.com/v1/asset/?id=${id}`;
            successfulResponse = await axios.get(robloxUrl, {
                headers,
                responseType: "stream",
                timeout: 10000
            });
            console.log("yay got response i think idk rolox");
        }

        if (!successfulResponse) {
            console.log(successfulResponse);
            console.log("failed 502");
            return res.status(502).send("No asset for u");
        }

        res.setHeader("Content-Disposition", `attachment; filename="asset"`);

        if (process.env.cacheAssets) {
            const writer = fs.createWriteStream(filePath);
            successfulResponse.data.pipe(writer);
        }

        successfulResponse.data.pipe(res);
        console.log(`Serving asset: ${id} from ${finalurl}`);
    } catch (e) {
        console.error(e.message);
        if (!res.headersSent) {
            res.status(500).send("Error fetching asset");
        }
    }
});

app.listen(process.env.Port, () => console.log("Started on Port " + process.env.Port));