# Get Application Token
Action, die ein Applikationstoken für Aufrufe gegen unser API-Gateway bereitstellt.<br>Die `tokenUrl` (also die URL des austellenden Identity-Providers) bestimmt Umgebung und Organisation, für die das Token ausgestellt wird (https://sts-git.klarmobil.de/v1/oidc/token gilt z.B. nur für GIT und Klarmobil ).

## Inputs
### clientId
    description: Client-ID für Applikationstoken
    required: true
### clientSecret
    description: Client-Secret für Applikationstoken
    required: true
### tokenUrl
    description: URL für den Token-Aufruf
    required: true

## Outputs
### accessToken
    description: Das Applikationstoken

