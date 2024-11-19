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

[https://github.com/danaithb/PGR301-DevOps/actions/runs/11860614668](https://github.com/danaithb/PGR301-DevOps/actions/runs/11860614668 )


