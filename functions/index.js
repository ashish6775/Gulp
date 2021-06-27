const https = require("https");
const functions = require("firebase-functions");
const express = require("express");
const cors = require("cors");

const app = express();
app.use(cors({
  origin: true,
}));
/*
* import checksum generation utility
* You can get this utility from https://developer.paytm.com/docs/checksum/
*/
const PaytmChecksum = require("paytmchecksum");

app.post("/", (req, res) => {
  const paymentData = req.body;
  const paytmParams = {};

  paytmParams.body = {
    "requestType": "Payment",
    "mid": "KGeIop74079861754179",
    "websiteName": "DEFAULT",
    "callbackUrl": "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID="+paymentData.orderId,
    "channelId": "WAP",
    "isStaging": "False",
    "orderId": paymentData.orderId,
    "txnAmount": {
      "value": paymentData.value,
      "currency": "INR",
    },
    "userInfo": {
      "custId": paymentData.custId,
    },
  };

  /*
  * Generate checksum by parameters we have in body
  * Find your Merchant Key in your Paytm Dashboard at https://dashboard.paytm.com/next/apikeys
  */
  PaytmChecksum.generateSignature(JSON
      .stringify(paytmParams.body), "KxhnwLJlR5m&EfRb")
      .then(function(checksum) {
        paytmParams.head = {
          "signature": checksum,
        };

        const postData = JSON.stringify(paytmParams);
        const options = {

          /* for Staging */
          // hostname: "securegw-stage.paytm.in",

          /* for Production */
          hostname: "securegw.paytm.in",

          port: 443,
          path: "/theia/api/v1/initiateTransaction?mid="+
           paytmParams.body.mid + "&orderId=" + paytmParams.body.orderId,
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Content-Length": postData.length,
          },
        };

        let response = "";
        const postReq = https.request(options, function(postRes) {
          postRes.on("data", function(chunk) {
            response += chunk;
          });

          postRes.on("end", function() {
            console.log("Response: ", response);
            res.send(response);
          });
        });
        postReq.write(postData);
        postReq.end();
      });
});

exports.paymentFunction = functions.https.onRequest(app);
