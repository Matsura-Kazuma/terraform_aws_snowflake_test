# 日本語コメント: Terraform 実行の安全ラッパ
TF?=terraform
ENV?=dev
REGION?=ap-northeast-1
TARGET?=foundation
STACK=stacks/$(ENV)/$(REGION)/$(TARGET)

.PHONY: init plan apply destroy drift show-json opa-test fmt validate pre-commit

init:
	$(TF) -chdir=$(STACK) init -backend-config=$(STACK)/backend.hcl

plan:
	$(TF) -chdir=$(STACK) plan -input=false -lock=true -out=$(STACK)/tfplan.bin

apply:
	$(TF) -chdir=$(STACK) apply -input=false -lock=true -auto-approve $(STACK)/tfplan.bin

destroy:
	$(TF) -chdir=$(STACK) destroy -auto-approve

drift:
	$(TF) -chdir=$(STACK) plan -refresh-only -detailed-exitcode || test $$? -eq 0 -o $$? -eq 2

show-json:
	$(TF) -chdir=$(STACK) show -json $(STACK)/tfplan.bin > $(STACK)/plan.json

opa-test: show-json
	conftest test --policy policy/opa $(STACK)/plan.json

fmt:
	$(TF) fmt -recursive

validate:
	$(TF) validate

pre-commit:
	pre-commit run --all-files
