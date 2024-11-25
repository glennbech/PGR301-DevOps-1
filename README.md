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

![Postman eks](/oppg1a.png)

**S3 Bucket:**

- Genererte bilder blir lagret i S3-bucketen `pgr301-couch-explorers` med kandidatnummer 104 som prefix.


#### ❣️ 1b

GitHub Actions Workflow:

Lenke til vellykket kjøring av GitHub Actions workflow som deployer SAM-applikasjonen

[https://github.com/danaithb/PGR301-DevOps/actions/runs/11860614668/job/33056242572](https://github.com/danaithb/PGR301-DevOps/actions/runs/11860614668/job/33056242572)

### Oppgave 2: Infrastruktur med Terraform og SQS

#### ❣️ 2b

Lenke til vellykket kjøring av GitHub Actions workflow, `terraform apply` på en push til `main`. Denne workflow linken er fra en merge da jeg tenkte dette matcher et real scenario:

[https://github.com/danaithb/PGR301-DevOps/actions/runs/11921001381/job/33224195509](https://github.com/danaithb/PGR301-DevOps/actions/runs/11921001381/job/33224195509)

Her er link til workflow der det har blitt pushet direkte til main:

[https://github.com/danaithb/PGR301-DevOps/actions/runs/11921235397](https://github.com/danaithb/PGR301-DevOps/actions/runs/11921235397)

Lenke til vellykket kjøring av GitHub Actions workflow, `terraform plan` (ikke `main`):

[https://github.com/danaithb/PGR301-DevOps/actions/runs/11901136522](https://github.com/danaithb/PGR301-DevOps/actions/runs/11901136522)

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

### Oppgave 4: Metrics og overvåkning

#### ❣️ 4a

**CloudWatch Alarm:**

CloudWatch-alarm `104_sqs_age_alarm` ble satt opp for å overvåke `ApproximateAgeOfOldestMessage` for SQS-køen. 

**Skript for å trigge alarm:**

For å simulere belastning og trigge alarmen, kan følgende skript brukt for å sende flere meldinger til køen:

```
for i in {1..110}; do  
  aws sqs send-message --queue-url https://sqs.eu-west-1.amazonaws.com/244530008913/104-image-queue \
  --message-body "Christmas in New York, version $i" \
  --region eu-west-1; 
  sleep 0.1;  
done
```

### Oppgave 5: Serverless, Function as a service vs Container-teknologi

#### ❣️ 5.1

Når vi ser på automatisering og kontinuerlig levering (CI/CD) i en serverless arkitektur sammenlignet med mikrotjenestearkitektur, er det flere viktige forskjeller å vurdere. Begge tilnærmingene har som mål å forbedre fleksibilitet og skalerbarhet, men de håndterer CI/CD på ulike måter. I mikrotjenestearkitektur er tjenestene vanligvis pakket inn i containere, noe som forenkler bygging, testing og distribusjon ved bruk av etablerte verktøy som Docker og Kubernetes. Dette gjør det mulig å standardisere CI/CD-pipelines, noe som reduserer kompleksiteten og gir bedre kontroll over applikasjonens livssyklus. Mikrotjenester kan derfor enklere håndtere utrullingsstrategier som blue-green deployment eller rolling updates ved hjelp av automatiseringsverktøy som Jenkins eller GitHub Actions, noe som gir en forutsigbar og effektiv utrullingsprosess.

Serverless-arkitektur, derimot, tilbyr fordeler som enkel skalerbarhet og redusert infrastrukturhåndtering, fordi infrastrukturen administreres av skyleverandøren. Imidlertid kan CI/CD-pipelines for serverless bli mer utfordrende fordi hver funksjon typisk må isoleres og bygges uavhengig. Dette innebærer at testing kan være vanskeligere, spesielt lokalt, da funksjoner kjøres i spesifikke skylignende miljøer. Automatisering krever ofte at vi definerer infrastrukturen som kode ved hjelp av verktøy som Terraform, men kompleksiteten øker når vi har mange små, individuelle komponenter med egne livssykluser. For utrullingsstrategier kan serverless-arkitektur også være mer krevende når man prøver å bruke strategier som gradvis utrulling, siden hver funksjon opererer uavhengig og ofte må koordineres nøye for å sikre en smidig oppgradering.

I serverless-tilnærmingen reduseres kompleksiteten knyttet til infrastruktur og ressursstyring, men det krever samtidig en annen type tilpasning av utviklings- og testprosesser enn mikrotjenester. Mikrotjenester tilbyr bedre kontroll og bruker etablerte metoder for automatisering og utrulling, mens serverless gir enkelhet og skalerbarhet, men kan kreve mer tilpasning i CI/CD og overvåkning for å håndtere flere små, selvstendige komponenter.

#### ❣️ 5.2

Når vi vurderer overvåkning og logging i en serverless arkitektur kontra en mikrotjenestearkitektur, blir det klart at hver tilnærming har unike implikasjoner på observability. I mikrotjenestearkitekturen har vi typisk flere containere, som hver representerer en uavhengig tjeneste. Dette gjør at logging og overvåkning er ganske standardisert, og verktøy som Prometheus og Grafana brukes ofte for å få innsikt i applikasjonens tilstand. Loggingen kan enkelt konfigureres via containere, og dataene kan aggregeres på tvers av tjenester, noe som gjør det enklere å feilsøke problemer som oppstår i komplekse sammenhenger. Mikrotjenester lar oss bruke tradisjonelle metoder som aggregerte logger og overvåkningsdashboards for å få en helhetlig oversikt over hele systemet.

I serverless-arkitektur, hvor vi for eksempel bruker AWS Lambda og SQS, endres dynamikken rundt observability betraktelig. Siden Lambda-funksjoner har en kort levetid og skalerer dynamisk, er det utfordrende å ha full oversikt over alle instanser av en funksjon. CloudWatch brukes ofte for å samle inn logging fra Lambda, men det krever en annen tilnærming enn å overvåke statiske containere. Logging og metrics blir distribuert på tvers av mange korte kjøringer, og det kan være vanskelig å få et samlet bilde av systemets ytelse. Dette gjør det mer utfordrende å feilsøke problemer, spesielt når de er resultatet av flere samtidige funksjoner som ikke er direkte koblet sammen, slik som nevnt i forelesningen om ‘CloudWatch og logging i serverless systemer’. Overvåkning krever ofte at man implementerer spesifikke verktøy som AWS X-Ray for å spore oppførselen til hver enkelt funksjon og få innsikt i latens eller feil som kan oppstå på tvers av flere tjenester.

I serverless er det også en utfordring med kostnader knyttet til logging. Hver invokasjon av en Lambda-funksjon genererer loggdata, og når funksjonene skalerer automatisk, kan loggmengden øke dramatisk. Dette var en utfordring nevnt i lab-oppgaven om CloudWatch hvor loggkostnadene kunne bli høyere hvis man ikke hadde konfigurert loggretensjon riktig. Et annet viktig aspekt er at feilsøking blir mer komplisert på grunn av at funksjonene ofte har egne livssykluser og opererer asynkront. Dette betyr at vi trenger gode strategier for distribuerte sporingssystemer for å kunne identifisere feilkilder.

Alt i alt er det slik at overvåkning i en serverless-arkitektur krever spesifikke verktøy og en tilpasset tilnærming for å håndtere distribuert logging og metrics, sammenlignet med mikrotjenester hvor man kan bruke mer tradisjonelle overvåkings- og loggeverktøy.

#### ❣️ 5.3

En serverless arkitektur som bruker AWS Lambda og Amazon SQS tilbyr unike fordeler når det gjelder skalerbarhet og kostnadskontroll. Når vi bruker serverless, trenger vi ikke å administrere infrastrukturen selv, og vi betaler bare for nøyaktig det vi bruker. Dette gir stor fleksibilitet, spesielt når trafikken er uforutsigbar. Skalerbarheten er nærmest ubegrenset siden funksjonene automatisk skaleres opp eller ned basert på etterspørselen uten at vi trenger å bekymre oss for kapasiteten. AWS Lambda aktiverer automatisk flere instanser når antall forespørsler øker, noe som gjør det enkelt å håndtere plutselige trafikkøkninger uten manuell inngripen. Kostnadene holdes lave siden vi kun betaler per kjøring og ikke for tomgangstider, noe som reduserer risikoen for overforbruk når etterspørselen er lav.

Men denne fleksibiliteten kommer også med noen utfordringer. Selv om kostnadene er lave ved lav bruk, kan det bli dyrt dersom funksjonene utløses ofte eller når mange samtidige forespørsler håndteres over lengre tid. Dette skyldes at hver Lambda-funksjon har en fast kostnad per kjøring, som kan akkumulere seg raskt. Et annet aspekt å vurdere er kaldstart-problematikken. Når funksjonene ikke har vært aktive en stund, må de "startes opp" igjen, noe som kan føre til økt responstid og gi en dårligere brukeropplevelse, spesielt for applikasjoner som krever lav latency.

På den andre siden, ved bruk av en mikrotjenestebasert arkitektur, har vi mer kontroll over ressursene. Hver mikrotjeneste kjører som en egen container, gjerne administrert av et orkestreringsverktøy som Kubernetes. Dette gir utviklingsteamet mulighet til å finjustere ressursbruken og dermed optimalisere kostnadene, spesielt når man har behov for langvarig og kontinuerlig tilgjengelige tjenester. Mikrotjenester tillater også bruk av skreddersydde autoskaleringsstrategier basert på spesifikke metrikker som CPU-bruk eller nettverksbelastning, noe som gir fleksibilitet når det gjelder hvordan og når vi skalerer.

Ulempen med mikrotjenester er at kostnadene for administrasjon og vedlikehold av infrastrukturen kan være høye. Dette gjelder både den menneskelige innsatsen og maskinressursene som kreves for å opprettholde kontinuerlig drift, feilretting, og oppdatering av tjenestene. I tillegg krever det at teamene har kompetanse innen containerteknologi og orkestrering, noe som kan øke kompleksiteten i prosjektene. Det krever også at vi har ressurser tilgjengelig selv når etterspørselen er lav, noe som kan føre til at vi betaler for ubrukt kapasitet.

Sammenfattende kan vi si at en serverless arkitektur tilbyr en mer kostnadseffektiv løsning for applikasjoner med uforutsigbar eller svært variabel trafikk, samtidig som skyleverandøren tar seg av infrastrukturen. Denne tilnærmingen gir stor fleksibilitet, men kan bli kostbar hvis bruken er høy eller ved behov for konstant tilgjengelighet. Mikrotjenester gir derimot større kontroll over ressursutnyttelsen og er bedre egnet for systemer med stabil trafikk eller komplekse avhengigheter mellom tjenestene, men krever mer innsats for å administrere infrastrukturen.

#### ❣️ 5.4

I en mikrotjenestebasert arkitektur har DevOps-teamet full kontroll over infrastrukturen og applikasjonens drift, noe som gir større eierskap over ytelse, pålitelighet og kostnader. Hvert aspekt av infrastrukturen, fra oppsett av containere til overvåkning og vedlikehold, ligger i hendene på teamet, noe som gir dem detaljert innsikt og kontroll over hvordan hver mikrotjeneste oppfører seg. Denne tilnærmingen gir mulighet for optimal ytelse og skreddersydde løsninger, men legger også større ansvar på teamet som må håndtere alt fra skalering til feilhåndtering, noe som kan være tidkrevende og komplekst. Som nevnt i kildene fra "DevOps i skyen"-forelesningen må DevOps-teamet administrere hele livssyklusen til containerbaserte tjenester, noe som betyr at de må være dyktige til å håndtere automatiseringsverktøy som Kubernetes for å sikre pålitelig drift og god ressursbruk.

Overgangen til en serverless arkitektur, som AWS Lambda og SQS, endrer dette ansvaret betydelig ved at mye av infrastrukturen og ressursstyringen håndteres av skyleverandøren. Dette betyr at DevOps-teamet får mindre kontroll over underliggende systemer, noe som kan være en fordel i form av redusert vedlikeholdsbyrde, men samtidig kan føre til redusert eierskap over hvordan infrastrukturen opererer. Funksjoner i en serverless arkitektur skaleres automatisk av skyleverandøren basert på etterspørsel, noe som gjør ressursstyringen mer fleksibel og forenkler administrasjonen, men det betyr også at utviklingsteamet må stole på at leverandørens verktøy sikrer god ytelse og optimal ressursutnyttelse. Dette ble tydelig fremhevet i forelesningen om "Serverless arkitektur og skytjenester," der det ble diskutert at automatisert skaleringslogikk gir fordeler for ujevn trafikk, men også kan føre til begrenset mulighet for spesialtilpasning av hvordan ressurser skal håndteres.

Når det gjelder kostnader, gjør serverless at utviklingsteamet i mindre grad trenger å bekymre seg for overflødige ressurser eller utnyttelse, siden kostnadene er direkte knyttet til antall kjøringer og brukte ressurser. Dette gir større fleksibilitet, men det kan også føre til uforutsigbare kostnader, spesielt hvis funksjonene utløses oftere enn forventet eller i lengre perioder, noe som ble påpekt i forelesningen om kostnadskontroll i serverless miljøer. I en mikrotjenestearkitektur er kostnadene mer forutsigbare, men man må betale for ressursene uansett om de er fullt utnyttet eller ikke, noe som kan føre til ineffektiv ressursbruk ved lavere trafikk.

Kort oppsummert, med en mikrotjenestetilnærming er det større grad av eierskap og ansvar for DevOps-teamet når det gjelder å sikre ytelse, pålitelighet og kostnadsstyring, noe som kan være krevende, men også gi større kontroll og fleksibilitet. En serverless tilnærming reduserer byrden ved å håndtere infrastruktur, noe som gjør at teamet kan fokusere mer på utviklingen av funksjonalitet fremfor vedlikehold, men det innebærer også en avhengighet av skyleverandørens verktøy og begrenset mulighet til å tilpasse hvordan infrastrukturen administreres, noe som kan utfordre teamets følelse av eierskap og ansvar for applikasjonens totale ytelse og kostnad.
