const core = require('@actions/core');
const authenticate = require('./src/authenticate');
const uploadSpecification = require('./src/upload-specification');

const checkInputs = () => {
    core.getInput('portalUrl', { required: true });
    core.getInput('documentPath', { required: true });
    core.getInput('stage', { required: true });
    core.getInput('apiId', { required: true });
    core.getInput('maturityLevel', { required: true });
    core.getInput('version', { required: true });
    core.getInput('clientId', { required: true });
    core.getInput('clientSecret', { required: true });
};

(async () => {
    try {
        // validate inputs
        checkInputs();
        // authenticate
        const token = await authenticate();
        // upload api specification
        const messageId = await uploadSpecification(token);
        core.setOutput('messageId', messageId);
    } catch (error) {
        console.error(JSON.stringify(error));
        core.setFailed(error.message);
    }
})();
