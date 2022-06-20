# Working with Prow

[Prow](https://github.com/kubernetes/test-infra/tree/master/prow) provides CI features as well as a set of tools to improve developers productivity. Prow was developed by the Kubernetes community.

Prow runs pre-submit, post-submit and periodic jobs, but also comes with a set of productivity tools:

- Tide: Automatically merges PRs
- hold: Hold a PR such that it is not merged
- needs-rebase: Alert used that PR needs rebase

Prow is available at https://prow.kubeclipper.top and more details about the plugins can be found on [Prow Command Help](https://prow.kubeclipper.top/command-help?repo=kubesphere%2Fkubesphere) section.

# Prow Configuration
There are 2 main configurations:
* [config.yaml](https://github.com/kubesphere/test-infra/blob/main/config/prow/config.yaml): Defines jobs, general settings
* [plugins.yaml](https://github.com/kubesphere/test-infra/blob/main/config/prow/plugins.yaml): Plugins configuration

All deployment information can be found [here](https://github.com/kubesphere/test-infra/tree/main/config/prow/cluster).
Prow configuration can be updated via PR on `kubesphere/test-infra`. Once the PR is merged, Prow will update its configuration.

# ProwJobs
[ProwJobs](https://github.com/kubernetes/test-infra/blob/master/prow/jobs.md) is how we define the actual work with PRs, how they get tested, merged, and deployed. There are three kinds of ProwJobs, `presubmit`, `postsubmit`, `periodic`.
- **presubmits** run against code in PRs
- **postsubmits** run after merging code
- **periodics** run on a periodic basis

All KubeSphere prowjobs can be found [here](https://github.com/kubesphere/test-infra/tree/main/config/jobs). Please make sure each yaml name is unique, cause its name will be used as key in configmap.

# Test ProwJobs locally

By referring to [using-pj-on-kindsh](https://github.com/kubernetes/test-infra/blob/master/prow/build_test_update.md#using-pj-on-kindsh),

```
Note: Test containers designed for decorated jobs (configured with decorate: true) may behave incorrectly or fail entirely without the environment the pod utilities provide. Similarly jobs that mount volumes or use extra_refs likely won't work properly. These jobs are best run locally as decorated pods inside a Kind cluster Using pj-on-kind.sh.
```

We recommend you to test prowjobs with `/pj-on-kind.sh`.
