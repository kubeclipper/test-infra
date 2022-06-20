# KubeSphere Prow Job Configs
All prow job configs for [prow.kubesphere.io](https://prow.kubesphere.io) live here.

## Job Cookbook

This document attempts to be a step-by-step, copy-pastable guide to the use
of prow jobs for the Kubernetes project. It may fall out of date. For more
info, it was sourced from the following:

- [ProwJob docs](/prow/jobs.md)
- [Life of a Prow Job](/prow/life_of_a_prow_job.md)
- [Pod Utilities](/prow/pod-utilities.md)
- [How to Test a Prow Job](/prow/build_test_update.md#How-to-test-a-ProwJob)

### Job Types

There are three types of prow jobs:

- **Presubmits** run against code in PRs
- **Postsubmits** run after merging code
- **Periodics** run on a periodic basis

Please see [ProwJob docs](https://github.com/kubernetes/test-infra/blob/master/prow/jobs.md) for more info.

### Job Images

Where possible, we prefer that jobs use images that are pinned to a specific version, containing only what is needed.

Now, we only have one job image [build-tools](https://github.com/kubesphere/test-infra/blob/main/images/build-tools/Dockerfile). There are several images from Kubernetes community we can leverage.

## Job Presets

Prow supports [Presets](/prow/jobs.md#presets) to define and patch in common
env vars and volumes used for credentials or common job config. Some are
defined centrally in [`config/prow/config.yaml`], while others can be defined in
files here. eg:

- [`preset-docker-sock: "true"`] ensures the prowjob which requires dind can access `docker.sock`.
- [`preset-go-build-cache: "true"`] mount build cache directory

## Job Examples

A presubmit job named "pull-kubesphere-verify" that will run against all PRs to
kubesphere/kubesphere's master branch. It will run `make verify-all` in a checkout
of kubesphere/kubesphere at the PR's HEAD. It will report back to the PR via a
status context named `pull-kubesphere-verify`. Its logs and results are going
to end up in qingstor under `prow-logs/pr-logs/pull/community`. 

```yaml
presubmits:
  - name: pull-kubesphere-verify
    always_run: true
    branches:
    - ^master$
    decorate: true
    path_alias: kubesphere.io/kubesphere
    spec:
      containers:
      - command:
        - entrypoint
        - bash
        - -e
        - -c
        - "make verify-all"
        image: kubesphere/build-tools:master-latest
```

A periodic job named "periodic-kubesphere-build-image" that will
run every 24 hours against kubesphere/kubesphere's master
branch. It will run `make container-cross-push` in a checkout of the repo
located at `kubesphere.io/kubesphere`. The presets it's using will
ensure it has dockerhub secret and docker sock in well known locations. 

```yaml
periodics:
- interval: 24h
  decorate: true
  branches: master
  extra_refs:
  - org: kubesphere
    repo: kubesphere
    base_ref: master
    path_alias: kubesphere.io/kubesphere
  name: periodic-kubesphere-build-image
  labels:
    preset-go-build-cache: "true"
    preset-docker-sock: "true"
    preset-docker-credential: "true"
  spec:
    containers:
    - image: kubesphere/build-tools:master-latest
      command:
      - entrypoint
      - bash
      - -e
      - -c
      - "make container-cross-push"
      # docker-in-docker needs privileged mode
      securityContext:
        priviledged: true
      resources:
        requests:
          cpu: 2
          memory: "2Gi"
  annotations:
    description: "Periodic builds and pushs"
```

## Adding or Updating Jobs
1. Find or create the prowjob config file in this directory
    - In general jobs for github.com/org/repo use org/repo/filename.yaml
    - Ensure filename.yaml is unique across the config subdir; prow uses this as a key in its configmap

2. Ensure an OWNERS file exists in the directory for job, and has appropriate approvers/reviewers
Write or edit the job config (please see [how-to-add-new-jobs](https://github.com/kubernetes/test-infra/blob/master/prow/jobs.md#how-to-configure-new-jobs))

3. Open a PR with the changes; when it merges [@ks-ci-robot](https://github.com/ks-ci-bot) will deploy the changes automatically

## Testing Jobs Locally
Please try using [phaino](https://github.com/kubernetes/test-infra/blob/master/prow/cmd/phaino/README.md), it will interactively help you run a docker command that approximates the pod that would be scheduled on behalf of an actual prow job.

To create a ProwJob, which is a CRD that defines a job, you can use [mkpj](https://github.com/kubernetes/test-infra/tree/master/prow/cmd/mkpj). This can be installed with `go get k8s.io/test-infra/prow/cmd/mkpj`. To use, run a command like:

```shell
mkpj --github-token-path=./path/to/oauth/token --config-path config/prow/config.yaml --job-config-path config/jobs/ --job pull-kubesphere-verify > prowjob.yaml
```
(this assumes your working directory is https://github.com/kubesphere/test-infra). For presubmit jobs, you will need to enter a PR number to run against, and for postsubmit jobs a branch. `--github-token-path` is a path to a file containing a GitHub [personal access token](https://github.com/settings/tokens) with [repo](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/#available-scopes) scope. For most jobs, you don't need pass `--github-token-path`.

Next, the job can be run locally using phaino, which can be installed with `go get k8s.io/test-infra/prow/cmd/phaino`. To run the job we just created, you can run:

```shell
phaino --privileged prowjob.yaml
```
Additionally, all test results will have a link to a ProwJob YAML. This can be used to directly rerun a test, for example phaino https://prow.kubesphere.io/prowjob?prowjob=my-test-id-here.

Alternatively, the test can be run in a Kubernetes cluster, just like the are in Prow, by converting the ProwJob into a Pod definition. This can be done with mkpod, installed with `go get k8s.io/test-infra/prow/cmd/mkpod`. To create a Pod from the ProwJob we created above, run:
```
mkpod --local --prow-job prowjob.yaml
```
This can be applied into any cluster. Note: some tests rely on secrets mounted in the cluster to do things like upload to qingstor. If you do not have these secrets, the tests may fail. If you do, please use caution.
