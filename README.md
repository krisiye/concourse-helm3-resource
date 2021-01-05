# Helm Resource for Concourse

Deploy [Helm Charts](https://github.com/helm/helm) from [Concourse](https://concourse-ci.org/).

Heavily based on the work of [`linkyard/concourse-helm-resource`][linkyard].

[linkyard]: https://github.com/linkyard/concourse-helm-resource

## Docker Image

You can pull the resource image from [`typositoire/concourse-helm3-resource`][dockerhub]. !["Dockerhub Pull Badge"](https://img.shields.io/docker/pulls/typositoire/concourse-helm3-resource.svg "Dockerhub Pull Badge")


[dockerhub]: https://hub.docker.com/repository/docker/typositoire/concourse-helm3-resource

## Usage

```yaml
resource_types:
- name: helm
  type: docker-image
  source:
    repository: typositoire/concourse-helm3-resource
```

## Source Configuration

* `cluster_url`: *Optional.* URL to Kubernetes Master API service. Do not set when using the `kubeconfig_path` parameter, otherwise required.
* `cluster_ca`: *Optional.* Cluster CA certificate PEM, optionally Base64 encoded. (Required if `insecure_cluster` == false)
* `insecure_cluster`: *Optional.* Skip TLS verification for cluster API. (Required if `cluster_ca` is nil)
* `token`: *Optional.* Bearer token for Kubernetes.  This, 'token_path' or `admin_key`/`admin_cert` are required if `cluster_url` is https.
* `token_path`: *Optional.* Path to file containing the bearer token for Kubernetes.  This, 'token' or `admin_key`/`admin_cert` are required if `cluster_url` is https.
* `admin_key`: *Optional.* Base64 encoded PEM. Required if `cluster_url` is https and no `token` or 'token_path' is provided.
* `admin_cert`: *Optional.* Base64 encoded PEM. Required if `cluster_url` is https and no `token` or 'token_path' is provided.
* `release`: *Optional.* Name of the release (not a file, a string). (Default: autogenerated by helm)
* `namespace`: *Optional.* Kubernetes namespace the chart will be installed into. (Default: default)
* `helm_history_max`: *Optional.* Limits the maximum number of revisions. (Default: 0 = no limit)
* `repos`: *Optional.* Array of Helm repositories to initialize, each repository is defined as an object with properties `name`, `url` (required) username and password (optional).
* `plugins`: *Optional.* Array of Helm plugins to install, each defined as an object with properties `url` (required), `version` (optional).
* `stable_repo`: *Optional* A `false` value will disable using a default Helm stable repo. Any other value will be used to Override default Helm stable repo URL <https://charts.helm.sh/stable>. Useful if running helm deploys without internet access.
* `tracing_enabled`: *Optional.* Enable extremely verbose tracing for this resource. Useful when developing the resource itself. May allow secrets to be displayed. (Default: false)
* `helm_setup_purge_all`: *Optional.* Delete and purge every helm release. Use with extreme caution. (Default: false)

## Behavior

### `check`: Check the release, not happy with dynamic releases.

### `in`: Not Supported

### `out`: Deploy a helm chart (V3 only)

Deploy an helm chart

#### Parameters

* `chart`: *Required.* Either the file containing the helm chart to deploy (ends with .tgz), the path to a local directory containing the chart or the name of the chart from a repo (e.g. `stable/mysql`).
* `namespace`: *Optional.* Either a file containing the name of the namespace or the name of the namespace. (Default: taken from source configuration).
* `create_namespace`: *Optional.* Create the namespace if it doesn't exist (Default: false).
* `release`: *Optional.* Either a file containing the name of the release or the name of the release. (Default: taken from source configuration).
* `values`: *Optional.* File containing the values.yaml for the deployment. Supports setting multiple value files using an array.
* `override_values`: *Optional.* Array of values that can override those defined in values.yaml. Each entry in
  the array is a map containing a key and a value or path. Value is set directly while path reads the contents of
  the file in that path. A `hide: true` parameter ensures that the value is not logged and instead replaced with `***HIDDEN***`.
  A `type: string` parameter makes sure Helm always treats the value as a string (uses the `--set-string` option to Helm; useful if the value varies
  and may look like a number, eg. if it's a Git commit hash).
  A `verbatim: true` parameter escapes backslashes so the value is passed as-is to the Helm chart (useful for `((credentials))`).
  The default behaviour of backslashes in `--set` is to quote the next character so `val\ue` is treated as `value` by Helm.
* `token_path`: *Optional.* Path to file containing the bearer token for Kubernetes.  This, 'token' or `admin_key`/`admin_cert` are required if `cluster_url` is https.
* `version`: *Optional* Chart version to deploy, can be a file or a value. Only applies if `chart` is not a file.
* `test`: *Optional.* Test the release instead of installing it. Requires the `release`. (Default: false)
* `test_logs`: *Optional.* Display pod logs when running `test`. (Default: false)
* `delete`: *Optional.* Deletes the release instead of installing it. Requires the `release`. (Default: false)
* `replace`: *Optional.* Replace deleted release with same name. (Default: false)
* `force`: *Optional.* Force resource update through delete/recreate if needed. (Default: false)
* `devel`: *Optional.* Allow development versions of chart to be installed. This is useful when wanting to install pre-release
  charts (i.e. 1.0.2-rc1) without having to specify a version. (Default: false)
* `debug`: *Optional.* Dry run the helm install with the debug flag which logs interpolated chart templates. (Default: false)
* `check_is_ready`: *Optional.* Requires that `wait` is set to Default. Applies --wait without timeout. (Default: false)
* `atomic`: *Optional.* This flag will cause failed installs to purge the release, and failed upgrades to rollback to the previous release. (Default: false)
* `reuse_values`: *Optional.* When upgrading, reuse the last release's values. (Default: false)
* `reset_values`: *Optional.* When upgrading, reset the values to the ones built into the chart. (Default: false)
* `timeout`: *Optional.* This flag sets the max time to wait for any individual Kubernetes operation. (Default: 5m0s)
* `wait`: *Optional.* Allows deploy task to sleep for X seconds before continuing to next task. Allows pods to restart and become stable, useful where dependency between pods exists. (Default: 0)
* `kubeconfig_path`: *Optional.* File containing a kubeconfig. Overrides source configuration for cluster, token, and admin config.
* `show_diff`: *Optional.* Show the diff that is applied if upgrading an existing successful release. Will not be used when `devel` is set. (Default: false)
* `aws_access_key_id`: *Optional.* Access Key ID for the AWS IAM Authenticator
* `aws_secret_access_key`: *Optional.* Secret Access Key for the AWS IAM Authenticator

## Example

### Out

Define the resource:

```yaml
resources:
- name: myapp-helm
  type: helm
  source:
    cluster_url: https://kube-master.domain.example
    cluster_ca: _base64 encoded CA pem_
    admin_key: _base64 encoded key pem_
    admin_cert: _base64 encoded certificate pem_
    repos:
      - name: some_repo
        url: https://somerepo.github.io/charts
```

Add to job:

```yaml
jobs:
  # ...
  plan:
  - put: myapp-helm
    params:
      chart: source-repo/chart-0.0.1.tgz
      values: source-repo/values.yaml
      override_values:
      - key: replicas
        value: 2
      - key: version
        path: version/number # Read value from version/number
      - key: secret
        value: ((my-top-secret-value)) # Pulled from a credentials backend like Vault
        hide: true # Hides value in output
      - key: image.tag
        path: version/image_tag # Read value from version/number
        type: string            # Make sure it's interpreted as a string by Helm (not a number)
```
