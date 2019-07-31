GITHUB_HOOKS = {}
GITHUB_HOOKS["Jenkins_Github_Hook"] = {
  "active":True,
  "events":  ["issues","pull_request","issue_comment"],
  "config": {
    "url": "https://scd-ci.fnal.gov/cgi-bin/github_webhook",
    "content_type":"json"
  }
}

GITHUB_HOOKS["Jenkins_Github_Hook_Push"] = {
  "active":True,
  "events":  ["push"],
  "config": {
    "url": "https://scd-ci.fnal.gov/cgi-bin/github_webhook?push",
    "content_type":"json"
  }
}

#First repository name matches wins
REPO_HOOK_MAP = []
REPO_HOOK_MAP.append(["LArSoft/github-bot", ["Jenkins_Github_Hook_Push"]])
REPO_HOOK_MAP.append(["LArSoft/lar*", ["Jenkins_Github_Hook","Jenkins_Github_Hook_Push"]])

def is_valid_gh_repo(repo_name):
  import re
  for r in REPO_HOOK_MAP:
    if re.match("^"+r[0]+"$",repo_name): return True
  return False

def get_repository_hooks(repo_name, hook=""):
  import re
  hooks = {}
  for r in REPO_HOOK_MAP:
    if re.match("^"+r[0]+"$",repo_name):
      if not hook:
        for h in r[1]: hooks[h]=GITHUB_HOOKS[h]
      elif hook in r[1]:
        hooks[hook] = GITHUB_HOOKS[hook]
      break
  return hooks

def get_event_hooks(events):
  hooks = {}
  for ev in events:
    hook = None
    if ev in ["push"]: hook="Jenkins_Github_Hook_Push"
    elif ev in ["issues","pull_request","issue_comment"]: hook="Jenkins_Github_Hook"
    if hook: hooks[hook] = GITHUB_HOOKS[hook]
  return hooks
