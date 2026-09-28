test:
	./gradlew test

start: run

run:
	./gradlew bootRun

update-gradle:
	./gradlew wrapper --gradle-version 9.2.1

update-deps:
	./gradlew versionCatalogUpdate

install:
	./gradlew dependencies

build:
	./gradlew build

lint:
	./gradlew spotlessCheck

lint-fix:
	./gradlew spotlessApply

.PHONY: build

IMAGE_NAME ?= pahartrahar228/devops-engineer-from-scratch-project-315
IMAGE_TAG ?= latest

.PHONY: docker-build docker-run docker-push

docker-build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

docker-run:
	docker run --rm -p 8080:8080 -p 9090:9090 $(IMAGE_NAME):$(IMAGE_TAG)

docker-push:
	docker push $(IMAGE_NAME):$(IMAGE_TAG)


ANSIBLE_INVENTORY ?= ansible/inventory.ini
VAULT_PASS_FILE ?= .vault_pass

.PHONY: provision deploy rollback

provision:
	ansible-playbook -i $(ANSIBLE_INVENTORY) playbook.yml \
		--vault-password-file $(VAULT_PASS_FILE)

deploy:
	ansible-playbook -i $(ANSIBLE_INVENTORY) deploy.yml \
		--vault-password-file $(VAULT_PASS_FILE)

# Usage: make rollback TAG=<git-sha-tag>
rollback:
	ansible-playbook -i $(ANSIBLE_INVENTORY) deploy.yml \
		--vault-password-file $(VAULT_PASS_FILE) \
		-e docker_image_tag=$(TAG)

