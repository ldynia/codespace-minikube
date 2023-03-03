# Decription

This repository is a playground for working with minikube and GitHub actions. All actions are executed inside codespace that runs self-hosted agent that is 
launched on codespaces startup together with minikube.

# Setup

1. In [Settings > Developer settings](https://github.com/settings/tokens/new)
   - create `personal access token (classic)` with `repo` scope
1. In [Settings > Codespaces](https://github.com/settings/codespaces/secrets/new)
   - create `Codespaces secrets` named `PAT`
   - bind it to this repository
1. In repository [Settings > Actions > Runners](https://github.com/ldynia/codespace-minikube/settings/actions/runners)
   - Verify that self-hosted runner is in `Active` or `Idle` state

# Minikube

```bash
kubectl apply -f devops/k8s/manifests
kubectl port-forward service/nginx 8080:80
```

# TODO

[start a background server process in a job github self hosted runner](https://stackoverflow.com/questions/68439803/self-hosted-github-runner-start-a-background-server-process-in-a-job-and-let-it)

# Troubleshoot Self Hosted Runner

1. Test Connectivity

    ```bash
    GH_ACTION_DIR=/usr/src/actions-runner

    SELF_HOSTED_RUNNER_PAT_TOKEN=$(curl -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $PAT_TOKEN" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/$GITHUB_REPOSITORY/actions/runners/registration-token | jq --raw-output .token)

    $GH_ACTION_DIR/run.sh --check --url https://github.com/$GITHUB_REPOSITORY --pat $SELF_HOSTED_RUNNER_PAT_TOKEN
    ```

1. Remove Runner

    ```bash
    $GH_ACTION_DIR/config.sh remove --token $SELF_HOSTED_RUNNER_PAT_TOKEN
    ```

