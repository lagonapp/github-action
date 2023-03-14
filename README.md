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
      - uses: lagonapp/github-action@main
        with:
          lagon_token: ${{ secrets.LAGON_API_TOKEN }}
```

This will deploy your source code to the specified function after a commit is pushed into main.

_NOTE: Make sure the repository that gets checked out contains a `.lagon/config.json` file that specifies information such as the function_id and organization_id!_

#### Other commands

If you want to run a different command just specify it with the `command` input:

```bash
        with:
          lagon_token: ${{ secrets.LAGON_API_TOKEN }}
          command: "promote claxnlc230738q5pa7iximskm ./my-project"
```

See [CLI](https://docs.lagon.app/cli) docs for more commands.

## Inputs

Inputs are provided using the `with:` section of your workflow YML file.

| key         | Description                  | Required | Default                |
| ----------- | ---------------------------- | -------- | ---------------------- |
| lagon_token | Your Lagon API token         | true     |                        |
| command     | The Lagon CLI command to run | false    | deploy --prod          |
| site_url    | Specify Lagon API domain     | false    | https://dash.lagon.app |

`site_url` is used to specify a custom endpoint if you are using a self-hosted instance of Lagon.

## Outputs

| key | Description | Nullable |
| --- | ----------- | -------- |
|     |             |          |

No outputs for now... not sure what the CLI can output, function hash ?

## Developing

Install [act](https://github.com/nektos/act) then push your action changes to a branch on Github if you want to test the changes you made. Unfortunately, you have to push your changes to Github for this test runner to work.

**Make sure to export `LAGON_API_TOKEN` so the action can configure the CLI! This is normally populated by Github.**

Once you have pushed the changes you want to test you can now run it locally with the provided [test.sh](/test.sh) script like so:

```bash
# Usage: ./test.sh -f path_to_function [-r repo, -c command, -s site_url]

# Test the main branch with a local function project
./test.sh -f ~/Projects/lagon-function

# Test a development branch
./test.sh -r lagonapp/github-action@my-dev-branch -f ~/Projects/lagon-function

# You can also specify the command and site_url
# See the inputs table for more info on the commands
./test.sh -r lagonapp/github-action@my-dev-branch \
  -f ~/Projects/lagon-function \
  -c "ls" \
  -s "https://lagon.mysite.io"
```
