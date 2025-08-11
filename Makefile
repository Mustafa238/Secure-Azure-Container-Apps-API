fmt:
	terraform -chdir=terraform fmt

init:
	terraform -chdir=terraform init

validate:
	terraform -chdir=terraform validate

tfsec:
	tfsec terraform/

plan:
	terraform -chdir=terraform plan

apply:
	terraform -chdir=terraform apply -auto-approve

destroy:
	terraform -chdir=terraform destroy -auto-approve

deploy: fmt init validate tfsec plan apply
