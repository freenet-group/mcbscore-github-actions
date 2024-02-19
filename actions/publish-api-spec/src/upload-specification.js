const core = require('@actions/core');
const superagent = require('superagent');

let uploadSpecification = function (token) {
    if (!token) {
        throw new Error('No access token provided! Sign in first!');
    }

    const portalUrl = core.getInput('portalUrl', { required: true });
    const documentPath = core.getInput('documentPath', { required: true });

    console.info('Starting upload.');

    const uploadMetadata = {
        backendVersion: core.getInput('version', { required: true }),
        apiId: core.getInput('apiId', { required: true }),
        categories: [core.getInput('maturityLevel', { required: true })],
        environment: core.getInput('stage', { required: true }),
    };

    return superagent
        .post(portalUrl)
        .set('Authorization', `Bearer ${token}`)
        .set('Content-Type', 'multipart/form-data')
        .set('User-Agent', 'freenet-group/gh-actions')
        .field('metadata', JSON.stringify(uploadMetadata))
        .attach('content', documentPath)

        .then((response) => {
            if (response.status !== 200) {
                console.error(`Upload failed. Status was ${response.status}`);
                console.error(JSON.stringify(response.body));
                return Promise.reject(response.body);
            }

            const body = JSON.parse(response.text);

            if (!body || !body.messageId) {
                console.error(`Upload failed. Status was ${response.status}`);
                console.error(JSON.stringify(response.body));
                return Promise.reject('Upload failed. See logs for details.');
            }

            console.info('Upload succeeded.');

            return Promise.resolve(body.messageId);
        })
        .catch((error) => {
            console.error('Upload request failed.');
            console.error(error);
            return Promise.reject(error);
        });
};

module.exports = uploadSpecification;
