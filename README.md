# Repooooooo

Small Flask application deployed as a hardened Docker container on AWS EC2.
The repository demonstrates a complete delivery path:

```text
Flask app → Docker image → GHCR → Ansible → EC2
                    ↑
        GitHub Actions security and test gates
```

## What it contains

- `app/` — Flask application with `/` and `/health` endpoints.
- `tests/` — pytest tests for both endpoints.
- `dockerfile` and `compose.yaml` — container build and runtime settings.
- `infra/` — Terraform for the application EC2 instance and SonarQube EC2 instance.
- `ansible/` — deployment and rollback playbooks.
- `.github/workflows/` — CI, CD, and rollback automation.
- `sonar-project.properties` — SonarQube project configuration.

## Runtime design

The application runs with Gunicorn on port `5000`. Docker Compose exposes it only on
the server loopback interface (`127.0.0.1:5000`). The container also uses:

- A non-root user.
- A read-only root filesystem.
- Dropped Linux capabilities.
- `no-new-privileges`.
- A health check against `/health`.

## Prerequisites

- Python `3.12`.
- Docker and Docker Compose.
- Terraform `>= 1.5`.
- Ansible with the `community.docker` collection.
- AWS credentials and an AWS profile for Terraform.

## Run locally

Install dependencies and run tests:

```sh
python3.12 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
pytest -q
```

Run the application directly:

```sh
flask --app app.app run --debug
```

Run the containerized application:

```sh
docker build -t repooooooo:local -f dockerfile .
export APP_IMAGE=repooooooo:local
docker compose up --build
```

Open `http://127.0.0.1:5000/` or check `http://127.0.0.1:5000/health`.

## Infrastructure

Terraform creates two EC2-based environments in the default VPC:

- The application server.
- A SonarQube server.

Set required values in a local `infra/terraform.tfvars` file, then run:

```sh
terraform -chdir=infra init
terraform -chdir=infra fmt -check -recursive
terraform -chdir=infra validate
terraform -chdir=infra plan
terraform -chdir=infra apply
```

Outputs include the public IP addresses for both instances.

After creating the infrastructure for the first time, run the bootstrap script:

```sh
./deploy.sh
```

It reads Terraform outputs, writes the Ansible inventory, configures SonarQube,
and prepares the application host. The script expects the SSH key at
`$HOME/.ssh/key.pem` and asks for the Ansible Vault password.

## CI and CD

### Continuous Integration

`Continuous Integration` runs for pull requests and pushes to `main`. Its gates are:

1. Gitleaks scans the full Git history for leaked secrets.
2. Checkov scans Terraform in `infra/`. Findings are reported without failing CI.
3. Pytest runs application tests.
4. SonarQube runs after the other CI jobs complete.

### Continuous Delivery

`Continuous Delivery` starts after successful CI on `main`. It:

1. Checks out the exact commit tested by CI.
2. Runs Trivy against the repository filesystem.
3. Builds and pushes the Docker image to GHCR.
4. Deploys with Ansible after the image is published.

The image receives `latest` and a short commit-SHA tag.

### Security scanning

- **Gitleaks** scans Git history for leaked passwords, tokens, and API keys.
- **Checkov** scans Terraform for infrastructure misconfigurations. Findings are reported without failing CI.
- **Trivy** scans the CD workspace for `HIGH` and `CRITICAL` vulnerabilities. Unfixed findings are ignored.

Required GitHub Actions secrets:

```text
SONAR_TOKEN
SONAR_HOST_URL
EC2_HOST
EC2_USER
EC2_SSH_KEY
GHCR_USERNAME
GHCR_TOKEN
```

## Rollback

Create a commit on `main` with this message format:

```text
rollback <TAG>
```

Example:

```text
rollback a762ece
```

If a commit message contains `skip`, CI, CD, and rollback jobs are skipped.