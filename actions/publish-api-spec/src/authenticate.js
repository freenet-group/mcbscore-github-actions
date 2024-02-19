const core = require('@actions/core');
const superagent = require('superagent');

const STS_TOKEN_URL = 'https://sts.md.de/v1/oidc/token';

let authenticate = function () {
    console.info('Starting authentication.');

    const clientId = core.getInput('clientId', { required: true });
    const clientSecret = core.getInput('clientSecret', { required: true });

    return superagent
        .post(STS_TOKEN_URL)
        .set('Content-Type', 'application/x-www-form-urlencoded')
        .set('User-Agent', 'freenet-group/gh-actions')
        .send({
            client_id: clientId,
            client_secret: clientSecret,
            grant_type: 'client_credentials',
        })
        .then((tokenResponse) => {
            if (tokenResponse.status !== 200) {
                console.error('Authentication failed.');
                console.error(tokenResponse.body);
                return Promise.reject(tokenResponse.body);
            }

            if (!tokenResponse.body || !tokenResponse.body.access_token) {
                console.error('No access token recieved!');
                console.error(tokenResponse.body);
                return Promise.reject(
                    'No access token received! See logs for details.'
                );
            }
            console.info('Successfully fetched access token.');

            return Promise.resolve(tokenResponse.body.access_token);
        })
        .catch((error) => {
            console.error('Authentication failed.');
            console.error(JSON.stringify(error));
            return Promise.reject(error);
        });
};

module.exports = authenticate;
