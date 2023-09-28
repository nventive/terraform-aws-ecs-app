SHELL:=/bin/sh
.SILENT:

.PHONY: docs hooks
docs:
	curl -sLo .docs/footer.md https://gist.githubusercontent.com/nventive-devops/7892a2ac9a2cc2ea219dd81796b6ce8b/raw/readme-footer.md
	terraform-docs markdown --config .docs/terraform-docs.yaml .

hooks:
	cp .githooks/pre-commit .git/hooks/pre-commit
	chmod +x .git/hooks/pre-commit
