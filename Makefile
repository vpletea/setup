ansible:
	sudo apt update && sudo apt install ansible -y
setup:
	ansible-playbook main.yaml --ask-become-pass
