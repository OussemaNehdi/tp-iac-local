# TP3 — Infrastructure as Code (Terraform + Docker) & CI/CD (GitHub Actions)

Terraform deploys a small "cloud" on the local Docker engine:

```
                Terraform (main.tf + variables.tf)
                         │  provider kreuzwerker/docker
                         ▼
   ┌──────────── Docker engine ─────────────┐
   │  tp-app-web  (Nginx on Alpine)  80 ──► host 8080   http://localhost:8080
   │  tp-db-postgres (PostgreSQL)  5432 ──► host 5432
   └────────────────────────────────────────┘
```

| File | Role |
|---|---|
| `main.tf` | provider + 4 resources (2 images, 2 containers) |
| `variables.tf` | DB name / user / password, ports |
| `outputs.tf` | DB container name + app URL |
| `Dockerfile_app` + `app/default.conf` | Nginx web app image |
| `.github/workflows/main.yml` | pipeline: Setup → Init → Plan → Apply (+ validation) |

## Run it locally (the 5 DLC steps)
```bash
terraform init                    # 1. download the Docker provider
terraform plan                    # 2. dry run: what will be created?
terraform apply -auto-approve     # 3. build + create the containers
curl http://localhost:8080/       # 4. "Application Deployed via Terraform IaC!"
terraform destroy -auto-approve   # 5. remove everything
```
Port 5432 already used on your machine (local PostgreSQL)? → `export TF_VAR_db_port_external=5433`

## CI/CD
Every push to `main` runs the pipeline in GitHub Actions. The **Apply** job has
`needs: plan`, so it only runs if the **Plan** job succeeded, and it applies exactly the
saved plan (`tfplan`) that was reviewed.

Team: Oussema Nehdi · Oussema Ghazouani · Ahmed Limam · Joumana Fradi — Module DevOps, INSAT.
