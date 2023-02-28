FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu

ARG GITHUB_RUNNER_DIR=/usr/src/actions-runner \
    GITHUB_RUNNER_VERSION=2.301.1 \
    GROUP=vscode \
    USER=vscode

ENV GITHUB_RUNNER_DIR=$GITHUB_RUNNER_DIR

# Install selfhosted runner
RUN mkdir -p $GITHUB_RUNNER_DIR
ADD --chown=$USER:$GROUP https://github.com/actions/runner/releases/download/v$GITHUB_RUNNER_VERSION/actions-runner-linux-x64-$GITHUB_RUNNER_VERSION.tar.gz $GITHUB_RUNNER_DIR
RUN tar zxf $GITHUB_RUNNER_DIR/actions-runner-linux-x64-$GITHUB_RUNNER_VERSION.tar.gz -C $GITHUB_RUNNER_DIR \
    && rm $GITHUB_RUNNER_DIR/actions-runner-linux-x64-$GITHUB_RUNNER_VERSION.tar.gz
RUN chown $USER:$GROUP -R $GITHUB_RUNNER_DIR
