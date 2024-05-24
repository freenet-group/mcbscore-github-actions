# Publish API Specification to MD Developer Portal

This action is used to publish Swagger 2.0 or OpenAPI 3.x.x Specifications to the MD Developer Portal.

By default, authentication is handled by the action itself. It can be safely used from github public runners.

## Usage

```yaml
name: Publish API Specification

# Controls when the action will run.
on:
    # Triggers the workflow on push or pull request events but only for the main branch
    release:
        - published

# A workflow run is made up of one or more jobs that can run sequentially or in parallel
steps:
    # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it
    - name: Checkout
      uses: actions/checkout@v2
    - name: Checkout Github Action
      uses: actions/checkout@v2
      with:
          # For accessing to this Action a service account with a personal access token in this repo is necessary.
          token: ${{ secrets.SERVICE_ACCOUNT_TOKEN }}
          repository: freenet-group/developer-portal-actions
          ref: refs/heads/main
          persistent-credentials: false
          path: ./.github/actions/developer-portal-actions
    - uses: ./.github/actions/developer-portal-actions/publish-api-spec
      with:
          portalUrl: 'https://developer-portal-api.prod.developers.md.de/v2/specifications'
          documentPath: ./testdata/petstore.yaml
          stage: 'dev'
          maturityLevel: idea-api
          apiId: '9e950a2b-efbe-4db9-b500-8c9cedc98f1f'
          version: '1.0.0'
          clientId: ${{ secrets.CLIENT_ID }}
          clientSecret: ${{ secrets.CLIENT_SECRET }}
```

### Configuration

| Parameter     | Description                                                                                                                 | Required | Default Value                                                                                                                                 |
| ------------- | --------------------------------------------------------------------------------------------------------------------------- | -------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| portalUrl     | The portal upload url. There is no need to change this except for testing purposes.                                         | true     | Ein Upload der API-Spezifikation kann gegen folgende Endpunkte erfolgen: https://developer-portal-api.prod.developers.md.de/v2/specifications |
| documentPath  | The path to the specification document on the local filesystem.                                                             | true     | swagger.yaml                                                                                                                                  |
| stage         | The environment the API is being deployed to. Must be one of `DEV`, `GIT`, `PET`, `PROD`                                    | false    | -                                                                                                                                             |
| maturityLevel | Must be one of: `open-api` for public APIs, `system-api` for internal APIs, `idea-api` for development and design previews. | false    | system                                                                                                                                        |
| apiId         | The unique ID of this API. This is used to correlate different Deployments of the same API.                                 | true     | -                                                                                                                                             |
| version       | The version of the current deployment.                                                                                      | true     | -                                                                                                                                             |
| clientId      | OIDC client_id it which needs to be allowed to perform client_credential flow.                                              | true     | -                                                                                                                                             |
| clientSecret  | OIDC client_secret which must be valid for the given client_id                                                              | true     | -                                                                                                                                             |

### Developing this action

Be aware. The action is executed from the `index.js` file in the `dist` directory.

The dist directory is compiled by [vercel](https://github.com/vercel/ncc). This makes it unnecessary to install node_modules upon cloning the repository.

Before each commit the dist folder needs to be updated! So run `npm run publish:build` in the action directory.
