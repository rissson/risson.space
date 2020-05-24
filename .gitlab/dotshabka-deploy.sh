#! /usr/bin/env nix-shell
#! nix-shell -i bash -p jq -p git -p curl -p nix-prefetch-scripts

branch="web-1-update-risson.space-${CI_COMMIT_SHORT_SHA}"
commit="web-1: update risson.space to ${CI_COMMIT_SHORT_SHA}"
file_path="hosts/web-1/web/risson.space.nix"
dotshabka_repo="https://gitlab.com/lama-corp/infra/dotshabka.git"

sha256="$(nix-prefetch-git https://gitlab.com/risson/risson.space --leave-dotGit --deepClone --rev "${CI_COMMIT_SHA}" | jq .sha256 | tr -d '"')"

git clone "${dotshabka_repo}" dotshabka
sed -i 's/\(.*rev = "\).*\(";\)/\1'"${CI_COMMIT_SHA}"'\2/' "dotshabka/${file_path}"
sed -i 's/\(.*sha256 = "\).*\(";\)/\1'"${sha256}"'\2/' "dotshabka/${file_path}"

curl --request POST \
    --header "PRIVATE-TOKEN: ${GITLAB_API_TOKEN}" \
    --form "branch=${branch}" \
    --form "start_branch=master" \
    --form "commit_message=${commit}" \
    --form "force=true" \
    --form "actions[][action]=update" \
    --form "actions[][file_path]=${file_path}" \
    --form "actions[][content]=<$(pwd)/dotshabka/${file_path}" \
    "https://gitlab.com/api/v4/projects/15155409/repository/commits"

cat > payload <<EOF
{
  "source_branch": "${branch}",
  "target_branch": "master",
  "title": "${commit} (automatically created)",
  "squash": true,
  "remove_source_branch": true,
  "assignee_id": 568664
}
EOF
payload="$(cat payload)"
curl --request POST --header "PRIVATE-TOKEN: ${GITLAB_API_TOKEN}" --header "Content-Type: application/json" --data "${payload}" https://gitlab.com/api/v4/projects/15155409/merge_requests
