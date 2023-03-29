# Lagon Action

Easily integrate [Lagon](https://lagon.dev) CLI into your Github workflows. Deploy new functions, retrieve a list of existing functions, promote functions, etc. This action supports any [arbitrary input](#other-commands) of what to do!

## Usage

Create the following workflow in your function's repository:

_./github/workflows/lagon.yml_

```yml
name: Lagon

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    name: Deploy
    steps:
      - uses: actions/checkout@v2
      - uses: lagonapp/github-action@latest
        with:
          lagon_token: ${{ secrets.LAGON_API_TOKEN }}
      - name: Log Function URL
        run: |
          url=$(grep -o 'https://[^[:space:]]*' lagon.output)
          echo "Function available at: $url"
```

This will deploy your source code to the specified function after a commit is pushed into main.

_NOTE: Make sure the repository that gets checked out contains a `.lagon/config.json` file that specifies information such as the function_id and organization_id or pass in a config via the config input value mentioned below!_

#### Other commands

If you want to run a different command just specify it with the `command` input:

```bash
        with:
          lagon_token: ${{ secrets.LAGON_API_TOKEN }}
          command: ls
```

See [CLI](https://docs.lagon.app/cli) docs for more commands.

## Inputs

Inputs are provided using the `with:` section of your workflow YML file.

| key         | Description                  | Required | Default                |
| ----------- | ---------------------------- | -------- | ---------------------- |
| lagon_token | Your Lagon API token         | true     |                        |
| command     | The Lagon CLI command to run | false    | deploy --prod          |
| site_url    | Specify Lagon API domain     | false    | https://dash.lagon.app |
| config      | Config file for function     | false    |                        |

`site_url` is used to specify a custom endpoint if you are using a self-hosted instance of Lagon.

`config` allows you to override a repositories existing config or maybe it never existed because you didn't want to commit it:

```bash
        with:
          lagon_token: ${{ secrets.LAGON_API_TOKEN }}
          config: |
            {
              "function_id": "${{ vars.lagon_function_id }}",
              "organization_id": "${{ vars.lagon_org_id }}",
              "index": "hello.ts",
              "client": null,
              "assets": null
            }
```

This example is setting the function and org ID with [variables](https://docs.github.com/en/actions/learn-github-actions/variables#creating-configuration-variables-for-a-repository).

## Outputs

Since the action allows you to run any command, there are no outputs. Instead, the CLI stdout will be saved to a local file called `lagon.output`.
