Init:
	@echo "hi this is init"
	terraform init

Validate: Init
	@echo "hey, this is validate "
	terraform validate

Plan: Validate
	@echo "this is terraform plan, before plan applying terraform init and validate,"
	terraform plan -auto-approve

Apply: Plan
	@echo "this is terraform apply, beofre apply applying init, validate and plan"
	terraform apply -auto-approve

Destroy: Plan
	@echo "this is terraform destroy, before destroy applying validate and plan"
	terraform destroy -auto-approve