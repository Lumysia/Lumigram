"""Waits until App Store Connect has processed an uploaded build, then gives it
to a TestFlight beta group. Groups with access to all builds get every build by
themselves; this is for a group that only gets the builds added to it.

Usage: testflight-add-group.py BUNDLE_ID VERSION BUILD_NUMBER GROUP_ID
Reads the API key from ASC_KEY_ID, ASC_ISSUER_ID and ASC_KEY_P8."""
import json
import os
import sys
import time
import urllib.parse
import urllib.request

import jwt

API = "https://api.appstoreconnect.apple.com/v1"
TIMEOUT = 2 * 60 * 60
POLL = 60


def request(method, path, query=None, body=None):
    token = jwt.encode(
        {"iss": os.environ["ASC_ISSUER_ID"], "aud": "appstoreconnect-v1", "exp": int(time.time()) + 600},
        os.environ["ASC_KEY_P8"],
        algorithm="ES256",
        headers={"kid": os.environ["ASC_KEY_ID"]},
    )
    url = API + path + ("?" + urllib.parse.urlencode(query) if query else "")
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method, headers={
        "Authorization": f"Bearer {token}", "Content-Type": "application/json",
    })
    with urllib.request.urlopen(req) as response:
        payload = response.read()
    return json.loads(payload) if payload else None


def main(bundle_id, version, build_number, group_id):
    apps = request("GET", "/apps", {"filter[bundleId]": bundle_id})["data"]
    if not apps:
        sys.exit(f"No app with bundle id {bundle_id}.")
    query = {
        "filter[app]": apps[0]["id"],
        "filter[version]": build_number,
        "filter[preReleaseVersion.version]": version,
        "fields[builds]": "version,processingState",
    }
    deadline = time.time() + TIMEOUT
    while True:
        builds = request("GET", "/builds", query)["data"]
        state = builds[0]["attributes"]["processingState"] if builds else "NOT_LISTED"
        print(f"Build {version} ({build_number}): {state}", flush=True)
        if state == "VALID":
            break
        if state in ("FAILED", "INVALID"):
            sys.exit(f"App Store Connect could not process build {build_number}.")
        if time.time() > deadline:
            sys.exit(f"Build {build_number} was not processed within {TIMEOUT // 60} minutes.")
        time.sleep(POLL)

    build_id = builds[0]["id"]
    request("POST", f"/betaGroups/{group_id}/relationships/builds", body={"data": [{"type": "builds", "id": build_id}]})
    if not request("GET", "/builds", {"filter[betaGroups]": group_id, "filter[id]": build_id})["data"]:
        sys.exit(f"Build {build_number} is not in group {group_id} after adding it.")
    print(f"Build {version} ({build_number}) is in group {group_id}.")


if __name__ == "__main__":
    if len(sys.argv) != 5:
        sys.exit(__doc__)
    main(*sys.argv[1:])
