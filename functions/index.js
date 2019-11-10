const functions = require('firebase-functions');
const cors = require('cors')({origin: true});
const Busboy = require('busboy');
const os = require('os');
const path = require('path');
const fs = require('fs');
const fbAdmin = require('firebase-admin');
const uuid = require('uuid/v4');
const spawn = require('child-process-promise').spawn;

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

const storageBucket = 'simple-order-manager-dev.appspot.com';
// const storageBucket = 'simple-order-manager.appspot.com';
const firebaseAdminSdk = './simple-order-manager-dev-firebase-adminsdk.json';
// const firebaseAdminSdk = './simple-order-manager-firebase-adminsdk.json';

const serviceAccount = require(firebaseAdminSdk);
fbAdmin.initializeApp({
    credential: fbAdmin.credential.cert(serviceAccount),
    storageBucket: storageBucket
});

const bucket = fbAdmin.storage().bucket();

exports.storeImage = functions.https.onRequest((req, res) => {
    return cors(req, res, () => {
        if (req.method !== 'POST') {
            return res.status(500).json({message: 'Not allowed.'});
        }

        if (
            !req.headers.authorization ||
            !req.headers.authorization.startsWith('Bearer ')
        ) {
            return res.status(401).json({error: 'Unauthorized.'});
        }

        let idToken;
        idToken = req.headers.authorization.split('Bearer ')[1];

        const busboy = new Busboy({headers: req.headers});
        let uploadData;
        let oldImagePath;

        busboy.on('file', (fieldname, file, filename, encoding, mimetype) => {
            const filePath = path.join(os.tmpdir(), filename);
            uploadData = {filePath: filePath, type: mimetype, name: filename};
            console.log('uploadData: ', uploadData);
            // write file to the file system
            file.pipe(fs.createWriteStream(filePath));
        });

        // listen to other incoming data than files
        busboy.on('field', (fieldname, value) => {
            // when updating an image
            console.log('fieldname: ', fieldname, ', value: ', value);
            oldImagePath = decodeURIComponent(value);
            console.log('oldImagePath: ', oldImagePath)
        });

        busboy.on('finish', () => {
            const id = uuid();
            let imagePath = 'images/' + id + '-' + uploadData.name;
            if (oldImagePath) {
                imagePath = oldImagePath;
            }

            return fbAdmin
                .auth()
                .verifyIdToken(idToken)
                .then(decodedToken => {
                    console.log('upload to bucket - decodedToken: ', decodedToken);
                    return bucket.upload(uploadData.filePath, {
                        uploadType: 'media',
                        destination: imagePath,
                        metadata: {
                            metadata: {
                                contentType: uploadData.type,
                                firebaseStorageDownloadTokens: id
                            }
                        }
                    });
                })
                .then(() => {
                    console.log('send response - imagePath: ', imagePath);
                    return res.status(201).json({
                        imageUrl:
                            'https://firebasestorage.googleapis.com/v0/b/' +
                            bucket.name +
                            '/o/' +
                            encodeURIComponent(imagePath) +
                            '?alt=media&token=' +
                            id,
                        imagePath: imagePath
                    });
                })
                .catch(error => {
                    console.log('error: ', error);
                    return res.status(401).json({error: 'Unauthorized!'});
                });
        });
        return busboy.end(req.rawBody);
    });
});

//  listener on firebase db
exports.deleteImage = functions.database
    .ref('/products/{productId}')
    .onDelete(snapshot => {
        const productData = snapshot.val();
        const imagePath = productData.imagePath;

        console.log('deleting: ', imagePath);
        return bucket.file(imagePath).delete();
    });

// resize image after upload
// exports.resizeImage = functions.storage.bucket(storageBucket).object().onFinalize(event => {
//     const myBucket = event.bucket;
//     const contentType = event.contentType;
//     const filePath = event.name;
//     console.log('File upload detected, function execution started: ' + filePath);
//
//     if (path.basename(filePath).startsWith('resized-')) {
//         console.log('We already renamed that file!');
//         return false;
//     }
//
//     console.log('bucket: ' + myBucket)
//     // const destBucket = bucket(myBucket);
//     const tmpFilePath = path.join(os.tmpdir(), path.basename(filePath));
//     const metadata = {contentType: contentType};
//     return bucket.file(filePath).download({
//         destination: tmpFilePath
//     }).then(() => {
//         return spawn('convert', [tmpFilePath, '-resize', '500x500', tmpFilePath]);
//     }).then(() => {
//         return bucket.upload(tmpFilePath, {
//             destination: 'images/resized-' + path.basename(filePath),
//             metadata: metadata
//         })
//     });
// });
