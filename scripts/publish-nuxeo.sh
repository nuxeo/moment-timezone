#!/usr/bin/env bash
#
# Publish @nuxeo/moment-timezone to packages.nuxeo.com
# Mirrors the publishing setup used for @nuxeo/moment.
#
# One-time authentication (Nuxeo SSO -> Nexus User Token):
#   1. Sign in to https://packages.nuxeo.com via Nuxeo SSO.
#   2. Open your username menu -> "User Token" and copy the Name Code / Pass Code.
#   3. Add the credentials to your USER-GLOBAL ~/.npmrc (never commit them):
#        //packages.nuxeo.com/repository/npm-public/:_auth=$(echo -n 'NAME_CODE:PASS_CODE' | base64)
#        always-auth=true
#
# The repo-level .npmrc already maps the @nuxeo scope to the registry, so this
# script only verifies auth and publishes the current version in package.json.
#
# Usage:
#   scripts/publish-nuxeo.sh            # publish current version
#   npm version patch --no-git-tag-version && scripts/publish-nuxeo.sh   # bump then publish
#
set -euo pipefail

cd "$(dirname "$0")/.."

REGISTRY="https://packages.nuxeo.com/repository/npm-public/"
NAME="$(node -p "require('./package.json').name")"
VERSION="$(node -p "require('./package.json').version")"

echo "Verifying authentication to ${REGISTRY} ..."
if ! npm whoami --registry="${REGISTRY}"; then
  echo "ERROR: not authenticated. See the header of this script for the User Token setup." >&2
  exit 1
fi

if npm view "${NAME}@${VERSION}" version --registry="${REGISTRY}" >/dev/null 2>&1; then
  echo "ERROR: ${NAME}@${VERSION} already exists on the registry. Bump the version first." >&2
  exit 1
fi

echo "Publishing ${NAME}@${VERSION} ..."
npm publish

echo "Verifying published version ..."
npm view "${NAME}" version --registry="${REGISTRY}"
echo "Done."
