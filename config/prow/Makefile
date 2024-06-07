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

update-config:
	kubectl -n default create configmap config --from-file=config.yaml=config.yaml --dry-run -o yaml | kubectl -n default apply -f -

update-plugins:
	kubectl -n default create configmap plugins --from-file=plugins.yaml=plugins.yaml --dry-run -o yaml | kubectl -n default apply -f -

update-label-config:
	kubectl apply -f cluster/test-pods_namespace.yaml # 单独提前创建 ns，否则批量 apply 可能会报错
	kubectl -n test-pods create configmap label-config --from-file=labels.yaml=labels.yaml --dry-run -o yaml | kubectl -n test-pods apply -f -

deploy:
	kubectl apply -f cluster/ --prune -l app.kubernetes.io/part-of=prow

update-job-config:
	./update-job-config.sh ../jobs/
