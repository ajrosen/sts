# sts

An Alfred workflow to configure an AWS profile using credentials found in the clipboard.  You can use this without Alfred by copying [configure_profile.sh](https://github.com/ajrosen/sts/blob/main/configure-profile.sh) to any directory in `$PATH`.  See [Other Platforms](#other-platforms) below.

Credentials may be obtained from the AWS access portal or CLI.  From the **AWS access portal**, choose _Option 1_ or _Option 2_.

---
<img width="796" height="171" alt="access-portal-1" src="https://github.com/user-attachments/assets/594155d0-32df-405b-8163-c6974cd554a2" />

---

<img width="796" height="194" alt="access-portal-2" src="https://github.com/user-attachments/assets/d2ea2efa-163d-4b78-a731-ce78f77a982e" />

---

Using the **AWS CLI**, run **_aws sts get-session-token_** and copy the output to the clipboard.  You can use any output format supported by the CLI: json, text, table, yaml, or yaml-stream.

## Other Platforms

This uses **/usr/bin/pbpaste**, which is a standard command on macOS, to retrieve the contents of the clipboard.

### Linux

You can use either **xsel** or **xclip** on Linux.

### Windows

If you are using WSL, **powershell.exe -c Get-Clipboard** will work.

### Other Commands

The other commands used in the script are:

- /bin/bash
- /usr/bin/awk
- /usr/bin/grep
- /usr/bin/jq
- /usr/bin/tr
- aws (the [AWS CLI](https://aws.amazon.com/cli/), anywhere in your path)
