#!/bin/bash
set -euo pipefail

function cleanup {
	if [[ -n "${test_dir+x}" ]]; then
		rm -rf "$test_dir"
	fi
}

# Register the cleanup function to run on exit or interrupt
trap cleanup EXIT INT

command="deploy --prod"
site_url="https://dash.lagon.app"
action_repo="lagonapp/github-action@main"
function_path=

# Parse inputs
while getopts ":c:s:r:f:" opt; do
	case $opt in
	c)
		# Optional set the `command` input
		command="$OPTARG"
		;;
	s)
		# Optionally set the `site_url` input
		site_url="$OPTARG"
		;;
	r)
		# This tells act which lagon-action to run
		action_repo="$OPTARG"
		;;
	f)
		# This is the folder that the action will run with (build and deploy)
		function_path="$OPTARG"
		;;
	\?)
		echo "Invalid option -$OPTARG" >&2
		;;
	esac
done

# Check that required options are set
if [ -z "$function_path" ]; then
	echo "Usage: $0 -f path_to_function [-r repo, -c command, -s site_url]" >&2
	exit 1
fi

if ! [ -v LAGON_API_TOKEN ]; then
	echo "You need to export LAGON_API_TOKEN so the action can authenticate the CLI!" >&2
	exit 1
fi
#
# Make sure the specified directory exists
if [ ! -d "$function_path" ]; then
	echo "Directory '$function_path' does not exist" >&2
	exit 1
fi

# Make sure the project is a git repo since act will fail
if [ ! -d "$function_path/.git" ]; then
	echo "Project '$function_path' must be a git initialized repository" >&2
	exit 1
fi

# Create test directory to simulate a repository
test_dir="/tmp/lagon-action-tester"
mkdir -p "$test_dir"
# Create a modified copy of the workflow_test.yml file using the provided repo url
sed "s!_ACTION_REPO_!$action_repo!g" "$(pwd)/workflow_test.yml" >"$test_dir/test.yml"
# Symlink project's .git folder so the checkout step works
ln -sn "$function_path/.git" "$test_dir/.git"

# Clear action cache so new changes are always picked up
rm -r ~/.cache/act/"$(echo "$action_repo" | sed 's/\//-/g')"

printf "Config: {\n action: \"%s\",\n function_source: \"%s\",\n command: \"%s\",\n site_url: \"%s\"\n}\n" "$action_repo" "$function_path" "$command" "$site_url"
# run the test workflow with the workflow_dispatch event in the simulated repo (test_dir) and specify a lagon secret.
# The secret is otherwise set by github when the workflow runs.
if ! act --input COMMAND="$command" --input SITE_URL="$site_url" workflow_dispatch -C "$test_dir" -W test.yml -s "LAGON_API_TOKEN=$LAGON_API_TOKEN"; then
	exit $?
fi

# Clean up the test directory
cleanup
