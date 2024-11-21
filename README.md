## Leveranser for Eksamen PGR301

Denne README inneholder en oversikt over leveranser for hver av oppgavene i eksamensprosjektet.

### Oppgave 1: AWS Lambda og GitHub Actions

#### ❣️ 1a

 HTTP Endepunkt:

```
https://a5eifmrpz0.execute-api.eu-west-1.amazonaws.com/Prod/generate
```

EKS for POST-request med JSON-body for å generere et bilde:
```
{
  "prompt": "A happy IT teacher who corrects exams late into the night"
}
```

**S3 Bucket:**

- Genererte bilder blir lagret i S3-bucketen `pgr301-couch-explorers` med kandidatnummer 104 som prefix.


#### ❣️ 1b

GitHub Actions Workflow:

Lenke til vellykket kjøring av GitHub Actions workflow som deployer SAM-applikasjonen

[https://github.com/danaithb/PGR301-DevOps/actions/runs/11860614668](https://github.com/danaithb/PGR301-DevOps/actions/runs/11860614668)

### Oppgave 2: Infrastruktur med Terraform og SQS

#### ❣️ 2b

Lenke til vellykket kjøring av GitHub Actions workflow, `terraform apply` på en push til `main`:

[https://github.com/danaithb/PGR301-DevOps/actions/runs/11921001381/job/33224195509](https://github.com/danaithb/PGR301-DevOps/actions/runs/11921001381/job/33224195509)

Lenke til vellykket kjøring av GitHub Actions workflow, `terraform plan` (ikke `main`):

[https://github.com/danaithb/PGR301-DevOps/actions/runs/11920971971/job/33224104563](https://github.com/danaithb/PGR301-DevOps/actions/runs/11920971971/job/33224104563)

**SQS-Kø URL:**

- Http URL for SQS køen:
  ```
  https://sqs.eu-west-1.amazonaws.com/244530008913/104-image-queue
  ```

### Oppgave 3: Javaklient og Docker

#### ❣️ 3a

**Dockerfile:**

Dockerfilen som brukes til å bygge og kjøre Java-koden finnes her: [Dockerfile](./java_sqs_client/Dockerfile). Dockerfilen bruker en multi-stage build for å minimere størrelsen på imaget og gjøre distribusjon enklere.

#### ❣️ 3b

**Begrunnelse for taggestrategi**
Jeg valgte å bruke både `latest` og commit hash (`sha`) for tagging av Docker images. Denne strategien er inspirert av oppgavene fra følgende GitHub-repositorier: 
[https://github.com/glennbechdevops/terraform-app-runner](https://github.com/glennbechdevops/terraform-app-runner) og [https://github.com/glennbechdevops/spring-docker-dockerhub](https://github.com/glennbechdevops/spring-docker-dockerhub), 
som begge benytter en lignende tilnærming.

`Latest` brukes for å alltid ha en oppdatert versjon tilgjengelig, noe som i et real-life scenario gjør det enklere for et team å finne den nyeste utgaven uten for mye søk. Commit-hash (`sha`) gir hver versjon en unik identifikator, 
noe som gjør det enkelt å spore og feilsøke spesifikke builds. Ved å bruke begge, balanserer vi enkel tilgang til den siste versjonen med muligheten for nøyaktig sporbarhet.

**GitHub Actions Workflow:**

GitHub Actions workflow som bygger og publiserer Docker-imaget til Docker Hub hver gang det gjøres en push til main-branchen:
[https://github.com/danaithb/PGR301-DevOps/actions/runs/11952574026/job/33318589804](https://github.com/danaithb/PGR301-DevOps/actions/runs/11952574026/job/33318589804)

#### Verifisering

- **Docker Hub image:** Navnet på Docker-imaget som ble pushet til Docker Hub er `daha025/java-sqs-client`.
- **SQS URL:** Containeren kan kjøre og sende meldinger til SQS-køen på: 
    ```
    https://sqs.eu-west-1.amazonaws.com/244530008913/104-image-queue
    ```