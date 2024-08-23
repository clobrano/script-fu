#!/usr/bin/env bash

# main branch (switch to master for old repos)
main="main"

# remotes: the project's repo, and your fork
remoteProject="upstream"
remoteFork="origin" 

git fetch $remoteProject --prune
git fetch $remoteFork --prune

# find release branches
branches=$(git branch -r | grep $remoteProject | grep release- | awk '{split($0,a,"/"); print a[2]}' | tr '\n' ' ')
# prepend main
branches="$main $branches"

echo "Branches: $branches\n\n"

exit 0
for branch in $(echo $branches)
do
    echo "Branch: $branch"
    echo "Deleting local merged branches"
    git branch --merged ${remoteProject}/${branch} | grep -v $branch | xargs -r git branch -d

    echo "Deleting remote merged branches"
    git branch -r --merged ${remoteProject}/${branch} | grep ${remoteFork}/ | grep -v /$branch | grep -v /HEAD | grep -v /$main | awk '{split($0,a,"/"); print a[2]}' | xargs -r git push $remoteFork --delete
    echo
done
