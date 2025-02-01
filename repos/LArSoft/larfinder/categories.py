from repo_config import GH_CMSSW_REPO as gh_repo
from repo_config import GH_REPO_ORGANIZATION as gh_user
from repo_config import CMSBUILD_USER
from categories_map import CMSSW_CATEGORIES

CMSSW_L1 = [ 'FNALbuild' ]
APPROVE_BUILD_RELEASE =  list(set([  ] + CMSSW_L1))
REQUEST_BUILD_RELEASE = APPROVE_BUILD_RELEASE
TRIGGER_PR_TESTS = list(set([] + REQUEST_BUILD_RELEASE))
PR_HOLD_MANAGERS = [ ]

COMMON_CATEGORIES = [ "L1", "code-checks" ]
EXTERNAL_CATEGORIES = [ "externals" ]
EXTERNAL_REPOS =  [
                  "LArSoft/larana",
                  "LArSoft/larbatch",
                  "LArSoft/larcore",
                  "LArSoft/larcorealg",
                  "LArSoft/larcoreobj",
                  "LArSoft/lardata",
                  "LArSoft/lardataalg",
                  "LArSoft/lardataobj",
                  "LArSoft/larevt",
                  "LArSoft/larexamples",
                  "LArSoft/lareventdisplay",
                  "LArSoft/larg4",
                  "LArSoft/larpandora",
                  "LArSoft/larsim",
                  "LArSoft/larreco",
                  "LArSoft/larwirecell",
                  "LArSoft/larsoft",
                  "LArSoft/larsoftobj",
                  "LArSoft/larutils",
                  "LArSoft/larfinder",
                  "LArSoft/larvecutils",
                  ]

EXTERNAL_REPOS.remove( gh_user+"/"+gh_repo )

CMSSW_REPOS = [ gh_user+"/"+gh_repo ]
CMSDIST_REPOS = [ ]
CMSSW_ISSUES_TRACKERS = list(set(CMSSW_L1))
COMPARISON_MISSING_MAP = []

#github_user:[list of categories]
CMSSW_L2 = {
  CMSBUILD_USER : ["tests", "code-checks" ],
  'LArSoft/level-1-managers': ['L1'],
  'LArSoft/level-2-managers': ['L2'],
}

USERS_TO_TRIGGER_HOOKS = set(TRIGGER_PR_TESTS + CMSSW_ISSUES_TRACKERS + list(CMSSW_L2.keys()))
CMS_REPOS = set(CMSDIST_REPOS + CMSSW_REPOS + EXTERNAL_REPOS)
def external_to_package(repo_fullname): return ''

