init:
	terraform -chdir=./terraform/ init -backend-config=secrets.backend.tfvars

reconfigure:
	terraform -chdir=./terraform/ init -migrate-state -backend-config=secrets.backend.tfvars

apply:
	terraform -chdir=./terraform/ apply

destroy:
	terraform -chdir=./terraform/ destroy

install:
	ansible-galaxy install -r ./ansible/requirements.yml
	ansible-playbook ansible/playbook.yml -i ansible/inventory.ini -t update --vault-password-file vault_pass
	ansible-playbook ansible/playbook.yml -i ansible/inventory.ini -t install --vault-password-file vault_pass

deploy:
	ansible-playbook ansible/playbook.yml -i ansible/inventory.ini -t deploy --vault-password-file vault_pass