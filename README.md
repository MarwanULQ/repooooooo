# Repooooooo lab

Small Flask app deployed to EC2 with Docker Compose, Ansible, Terraform, and SonarQube.

## Runtime

- App listens on container port `5000`.
- Compose binds app port to `127.0.0.1` only.
- Container uses Gunicorn, read-only root filesystem, dropped Linux capabilities, and `no-new-privileges`.
- `/health` is the rollout gate.
- Public TLS should terminate at an ALB or reverse proxy. Forward only to the instance's loopback app port. Keep certificates and private keys outside this repository.

## Deploy

Build and publish an immutable image, then deploy its digest:

```sh
export APP_IMAGE=ghcr.io/ORG/repooooooo@sha256:...
ansible-playbook -i ansible/inventory.ini ansible/deploy.yml
```

Deployment pulls the image, recreates the service, and checks `/health`. A bad image fails the play and prints recent container logs.

## Failure drill and rollback

Use a deliberately broken image digest for a controlled failure:

```sh
APP_IMAGE=ghcr.io/ORG/repooooooo@sha256:<bad-digest> \
  ansible-playbook -i ansible/inventory.ini ansible/deploy.yml
```

Expected result: health retries exhaust, rescue prints logs, and the play fails.

Restore the last known-good digest:

```sh
ansible-playbook -i ansible/inventory.ini ansible/rollback.yml \
  -e rollback_image=ghcr.io/ORG/repooooooo@sha256:<known-good-digest>
```

Record that digest with each release. Do not use mutable tags for rollback.

## Validation

```sh
pytest -q
terraform -chdir=infra fmt -check -recursive
terraform -chdir=infra validate
ansible-playbook --syntax-check -i ansible/inventory.ini ansible/deploy.yml
ansible-playbook --syntax-check -i ansible/inventory.ini ansible/rollback.yml
docker compose config
```
