#!/bin/bash -

# Configure an AWS profile using credentials found in the clipboard.
# Credentials may be obtained from the AWS access portal or CLI.

PROFILE="${1:-${profile_name}}"

# Configure profile and exit
configure_profile() {
    [ "${AWS_ACCESS_KEY_ID}"     != "" ] && aws --profile "${PROFILE}" configure set aws_access_key_id "${AWS_ACCESS_KEY_ID}"
    [ "${AWS_SECRET_ACCESS_KEY}" != "" ] && aws --profile "${PROFILE}" configure set aws_secret_access_key "${AWS_SECRET_ACCESS_KEY}"
    [ "${AWS_SESSION_TOKEN}"     != "" ] && aws --profile "${PROFILE}" configure set aws_session_token "${AWS_SESSION_TOKEN}"

    echo "Saved AWS profile \"${PROFILE}\""
    exit 0
}

# Get clipboard
CLIPBOARD=$(/usr/bin/pbpaste | /usr/bin/tr -d '\r')

# Option 1: Set AWS environment variables
if [[ "${CLIPBOARD}" =~ ^export\ AWS_ACCESS_KEY_ID= ]]; then
    eval "${CLIPBOARD}"

    configure_profile
fi

# Option 2: Add a profile to your AWS credentials file
if $(/usr/bin/grep -q '^aws_' <<< "$CLIPBOARD}"); then
    eval $(/usr/bin/awk -F= '/^aws_.*=/ { printf("export %s=%s\n", toupper($1), $2) }' <<< "${CLIPBOARD}")

    configure_profile
fi

# aws --output json sts get-session-token
2>&1 /usr/bin/jq '.Credentials' <<< "${CLIPBOARD}" > /dev/null
if [ $? == 0 ]; then
    eval $(/usr/bin/jq -r '"export AWS_ACCESS_KEY_ID=\(.Credentials.AccessKeyId)"' <<< "${CLIPBOARD}")
    eval $(/usr/bin/jq -r '"export AWS_SECRET_ACCESS_KEY=\(.Credentials.SecretAccessKey)"' <<< "${CLIPBOARD}")
    eval $(/usr/bin/jq -r '"export AWS_SESSION_TOKEN=\(.Credentials.SessionToken)"' <<< "${CLIPBOARD}")

    configure_profile
fi

# aws --output text sts get-session-token
if $(/usr/bin/grep -q '^CREDENTIALS' <<< "${CLIPBOARD}"); then
    eval $(/usr/bin/awk '{ printf("export AWS_ACCESS_KEY_ID=%s\n", $2) }' <<< "${CLIPBOARD}")
    eval $(/usr/bin/awk '{ printf("export AWS_SECRET_ACCESS_KEY=%s\n", $4) }' <<< "${CLIPBOARD}")
    eval $(/usr/bin/awk '{ printf("export AWS_SESSION_TOKEN=%s\n", $5) }' <<< "${CLIPBOARD}")

    configure_profile
fi

# aws --output table sts-get-session-token
if $(/usr/bin/grep -q '^||  AccessKeyId' <<< "${CLIPBOARD}"); then
    eval $(/usr/bin/awk '/^\|\|  AccessKeyId/ { printf("export AWS_ACCESS_KEY_ID=%s\n", $4) }' <<< "${CLIPBOARD}")
    eval $(/usr/bin/awk '/^\|\|  SecretAccessKey/ { printf("export AWS_SECRET_ACCESS_KEY=%s\n", $3) }' <<< "${CLIPBOARD}")
    eval $(/usr/bin/awk '/^\|\|  SessionToken/ { printf("export AWS_SESSION_TOKEN=%s\n", $4) }' <<< "${CLIPBOARD}")

    configure_profile
fi

# aws --output yaml sts-get-session-token yaml
# aws --output yaml-stream sts-get-session-token
if $(/usr/bin/grep -q 'Credentials:$' <<< "${CLIPBOARD}"); then
    eval $(/usr/bin/awk '/AccessKeyId:/ { printf("export AWS_ACCESS_KEY_ID=%s\n", $2) }' <<< "${CLIPBOARD}")
    eval $(/usr/bin/awk '/SecretAccessKey:/ { printf("export AWS_SECRET_ACCESS_KEY=%s\n", $2) }' <<< "${CLIPBOARD}")
    eval $(/usr/bin/awk '/SessionToken:/ { printf("export AWS_SESSION_TOKEN=%s\n", $2) }' <<< "${CLIPBOARD}")

    configure_profile
fi

# No credentials
echo 'No credentials found in clipboard'
