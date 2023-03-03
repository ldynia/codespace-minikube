#!/usr/bin/env bash

function setup_vscode() {
  echo "Configuring vscode"
  cp /workspaces/codespace-minikube/.devcontainer/config/vscode/settings.json /home/vscode/.vscode-remote/data/Machine/
}

function start_minikube() {
  echo "Start minikube"
  minikube start --wait "apiserver,system_pods,node_ready,kubelet"
  sudo -- bash -c "echo '$(minikube ip) minikube' >> /etc/hosts"
}

function start_github_runner() {
  echo "Setup github runner folders"
  GITHUB_ACTION_DIR=/usr/src/actions-runner
  sudo chown $USER:$USER /usr/src
  mkdir -p $GITHUB_ACTION_DIR

  cd $GITHUB_ACTION_DIR
  GITHUB_RUNNER_VERSION=2.301.1
  if [ ! -f $GITHUB_ACTION_DIR/actions-runner-linux-x64-$GITHUB_RUNNER_VERSION.tar.gz ]; then
      echo "Downloading Runner And Install Dependencies"
      curl -o actions-runner-linux-x64-$GITHUB_RUNNER_VERSION.tar.gz -L https://github.com/actions/runner/releases/download/v$GITHUB_RUNNER_VERSION/actions-runner-linux-x64-$GITHUB_RUNNER_VERSION.tar.gz
      tar xzf ./actions-runner-linux-x64-$GITHUB_RUNNER_VERSION.tar.gz
  fi

  # https://docs.github.com/en/rest/actions/self-hosted-runners?apiVersion=2022-11-28#create-a-registration-token-for-an-organization
  echo "Obtaining codespaces secrets PAT"
  GITHUB_RUNNER_PAT=$(curl -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $PAT" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/$GITHUB_REPOSITORY/actions/runners/registration-token | jq --raw-output .token);

  echo "Remove github runner"
  $GITHUB_ACTION_DIR/config.sh remove --token $GITHUB_RUNNER_PAT

  echo "Configure github runner"
  $GITHUB_ACTION_DIR/config.sh \
    --labels "self-hosted,Linux,X64,$RepositoryName" \
    --name $RepositoryName \
    --replace \
    --token $GITHUB_RUNNER_PAT \
    --unattended \
    --url https://github.com/$GITHUB_REPOSITORY \
    --work $GITHUB_ACTION_DIR/_work

  echo "Start github runner in foreground"
  $GITHUB_ACTION_DIR/run.sh > _diag/runner.log
}

# Execute functions
setup_vscode
start_minikube
start_github_runner
