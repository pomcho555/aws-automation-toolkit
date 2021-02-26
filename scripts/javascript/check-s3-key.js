'use strict';

// Load the AWS SDK for Node.js
const AWS = require('aws-sdk');
// get reference to S3 client
const s3 = new AWS.S3();

/**
 * Check if {key} exsists in S3 bucket
 * @param {key} string
 * @param {bucket} string
 */
const checkObject = async (key, bucket) => {
    listAllKeys({ Bucket: bucket })
        .then((data) => {
            if (data.find((v) => v.Key === key)) {
                console.log("find out")
            } else {
                console.log("not")
            }
        })
        .catch(console.log);
}

const listAllKeys = (params, out = []) => new Promise((resolve, reject) => {
    s3.listObjectsV2(params).promise()
        .then(({ Contents, IsTruncated, NextContinuationToken }) => {
            out.push(...Contents);
            !IsTruncated ? resolve(out) : resolve(listAllKeys(Object.assign(params, { ContinuationToken: NextContinuationToken }), out));
        })
        .catch(reject);
});
