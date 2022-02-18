from github import Github

def comment_gh_pr(gh, repo, pr, msg):
      repo = gh.get_repo(repo)
      pr   = repo.get_issue(pr)
      pr.create_comment(msg)
