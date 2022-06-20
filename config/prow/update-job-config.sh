#!/usr/bin/env bash
# Copyright 2021 The KubeSphere Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -eu
set -o pipefail

JOB_CONFIG_PATH=${1:-}

if [[ -z "${JOB_CONFIG_PATH}" ]]; then
    echo "No job configs path provided, exiting..."
    exit 1
fi

find "${JOB_CONFIG_PATH}" -name "*.yaml" | \
    xargs -n1 -I {} sh -c 'echo --from-file=$(basename {})={}' | \
    tr '\n' ' ' | \
    cat <(echo -n "kubectl -n default create cm job-config --dry-run -o yaml ") - | \
    sh | \
    kubectl -n default replace -f - 
