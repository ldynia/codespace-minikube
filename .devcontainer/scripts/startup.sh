#!/usr/bin/env bash

function start_minikube() {
  echo "Start minikube"
  minikube start --wait "apiserver,system_pods,node_ready,kubelet"
  sudo -- bash -c "echo '$(minikube ip) minikube' >> /etc/hosts"
}

function start_github_runner() {
  # https://docs.github.com/en/rest/actions/self-hosted-runners?apiVersion=2022-11-28#create-a-registration-token-for-an-organization
  echo "Obtaining codespaces secrets PAT"
  GITHUB_RUNNER_TOKEN=$(curl -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $PAT" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/$GITHUB_REPOSITORY/actions/runners/registration-token | jq --raw-output .token);

  echo "Remove github runner"
  $GITHUB_RUNNER_DIR/config.sh remove --token $GITHUB_RUNNER_TOKEN

  echo "Configure github runner"
  $GITHUB_RUNNER_DIR/config.sh \
    --labels "self-hosted,Linux,X64,$RepositoryName" \
    --name $RepositoryName \
    --replace \
    --token $GITHUB_RUNNER_TOKEN \
    --unattended \
    --url https://github.com/$GITHUB_REPOSITORY \
    --work $GITHUB_RUNNER_DIR/_work

  echo "Start github runner in foreground"
  $GITHUB_RUNNER_DIR/run.sh > $GITHUB_RUNNER_DIR/_diag/runner.log
}

# Execute functions
start_minikube
start_github_runner
