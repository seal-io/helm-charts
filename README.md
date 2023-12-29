# Seal Helm Charts

[![](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/seal-io)](https://artifacthub.io/packages/search?org=seal-io)
[![](https://img.shields.io/github/actions/workflow/status/seal-io/helm-charts/ci.yml?label=ci)](https://github.com/seal-io/helm-charts/actions)
[![](https://img.shields.io/github/license/seal-io/helm-charts?label=license)](https://github.com/seal-io/helm-charts#license)
[![](https://img.shields.io/github/downloads/seal-io/helm-charts/total)](https://github.com/seal-io/helm-charts/releases)

Seal Helm is a collection of charts for https://github.com/seal-io projects. The charts can be added using following command.

```shell
helm repo add seal-io https://seal-io.github.io/helm-charts
```

Or install a specific chart from OCI registry as below.

```shell
# latest version
helm install my-release oci://ghcr.io/seal-io/helm-charts/<CHART>
# with specific version
helm install my-release oci://ghcr.io/seal-io/helm-charts/<CHART> --version <VERSION>
```

# License

Copyright (c) 2023 [Seal, Inc.](https://seal.io)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at [LICENSE](./LICENSE) file for details.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
