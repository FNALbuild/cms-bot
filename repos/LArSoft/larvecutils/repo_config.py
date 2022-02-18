from os.path import basename,dirname,abspath
GH_CMSSW_ORGANIZATION="LArSoft"
CMSBUILD_GH_USER="FNALbuild"
#This is overridden by GITHUBTOKEN env var
GH_TOKEN="~/.github-token-FNALbuild"
#This is overridden by GITHUBTOKEN env var
GH_TOKEN_READONLY="~/.github-token-readonly"
CONFIG_DIR=dirname(abspath(__file__))
#GH bot user: Use default FNALbuild
CMSBUILD_USER="FNALbuild"
GH_REPO_ORGANIZATION=basename(dirname(CONFIG_DIR))
GH_CMSSW_REPO=basename(CONFIG_DIR)
GH_REPO_FULLNAME="%s/%s" % (GH_REPO_ORGANIZATION, GH_CMSSW_REPO)
CREATE_EXTERNAL_ISSUE=False
#Jenkins CI server: User default http://cmsjenkins05.cern.ch:8080/cms-jenkins
JENKINS_SERVER="https://buildmaster.fnal.gov/buildmaster"
#GH Web hook pass phrase. This is encrypeted used bot keys.
GITHUB_WEBHOOK_TOKEN="""U2FsdGVkX19akbUO9GV/sfW46u9HUcJxcJtAo1oHRWOzTjeib95IvymrqUUcxCrv
+C0TsoP8i5gHZ3gq/g9bVQ=="""
#Set to True if you want bot to add build/test labels to your repo
ADD_LABELS=True
#Set to True if you want bot to add GH webhooks. FNALbuild needs admin rights
ADD_WEB_HOOK=True
#List of issues/pr which bot should ignore
IGNORE_ISSUES = [0]
#Set the Jenkins slave label is your tests needs special machines to run.
JENKINS_SLAVE_LABEL=""
#For cmsdist/cmssw repos , set it to False if you do not want to run standard cms pr tests
CMS_STANDARD_TESTS=False
#Map your branches with cmssw branches for tests
#User Branch => CMSSW/CMSDIST Branch
CMS_BRANCH_MAP={
}
VALID_WEB_HOOKS=["issues","pull_request","issue_comment"]
OPEN_ISSUE_FOR_PUSH_TESTS=True
def file2Package(filename): return GH_CMSSW_REPO
