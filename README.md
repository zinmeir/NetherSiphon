# NetherSiphon: Automated Hostile Ingestion & Asynchronous Threat Neutralization Architecture
**NetherSiphon** is an enterprise-grade, containerized Cyber Counter-Intelligence (CI) Deception Fabric and Security Information and Event Management (SIEM) pipeline. The architecture is engineered to safely emulate a vulnerable Linux server, intercept brute-force SSH attacks, and systematically exfiltrate malicious keystrokes, credential combinations, and post-compromise commands in real time. 

By deploying an isolated, medium-interaction deception node, the system strips control away from foreign adversaries or automated bots and asynchronously siphons their tactical telemetry down a decoupled analytics pipeline for ingestion, normalization, indexing, and visualization.

---

## 🛠️ Tech Stack & Cyber Ecosystem

* **Deception Framework:** Cowrie (Medium-Interaction SSH/Telnet Adversary Emulation Node)
* **Log Shipping Broker:** Elastic Filebeat v7.17.10 (Lightweight JSON Log Harvester)
* **SIEM Storage & Indexing:** Elastic Elasticsearch v7.17.10 (Distributed Data Cluster Core)
* **Analytics Workspace:** Elastic Kibana v7.17.10 (Visual Threat Hunting Dashboard Interface)
* **Containerization & DevOps:** Docker, Docker Compose (Multi-Service Microservices Mesh)
* **Automation & Runtime:** Windows PowerShell, Linux Bash (POSIX Interface Shells via WSL2)

---

## 🏗️ Architectural Topology & Data Lifecycle

The engineering pipeline uses a modular microservices design pattern to securely isolate hostile traffic while maintaining an un-throttled, live security logging loop:

```
  [ External Threat / Malicious Client ] 
                    │
                    │ SSH Brute-Force Attempt (Port 2222)
                    ▼
┌────────────────────────────────────────────────────────┐
│  1. INGESTION CORE: NetherSiphon Deception Node       │
│     (Isolated Medium-Interaction Cowrie Honeypot)       │
│     └─ Streams raw session records to: cowrie.json     │
└───────────────────┬────────────────────────────────────┘
                    │
                    │ Shared Data Volume Mount Intercept
                    ▼
┌────────────────────────────────────────────────────────┐
│  2. PIPELINE BROKER: Filebeat Log Shipper              │
│     (Optimized with WSL2 POSIX Compliance Bypass)       │
│     └─ Continuous tail-reads; flattens JSON layers      │
└───────────────────┬────────────────────────────────────┘
                    │
                    │ Bulk Indexing Protocol
                    ▼
┌────────────────────────────────────────────────────────┐
│  3. DATABASE STORAGE: Elasticsearch Cluster            │
│     (Single-Node Mode w/ Hard-Capped Heap Allocations) │
│     └─ Implements Index Schema: `filebeat-7.17.10`     │
└───────────────────┬────────────────────────────────────┘
                    │
                    │ REST Query Reconciliation
                    ▼
┌────────────────────────────────────────────────────────┐
│  4. VISUALIZATION LAYER: Kibana SIEM Dashboard         │
│     (Interactive Threat Hunting Workspace)              │
│     └─ Aggregates live timelines & trace analytics     │
└────────────────────────────────────────────────────────┘
```

1. **Adversary Intercept (The Trap):** Hostile agents establish terminal authentication requests via exposed external port `2222`. The deception sandbox responds with a simulated Ubuntu shell, tricking the client into executing automated attacks while keeping your real host operating system hidden.
2. **Telemetry Siphoning (The Shipping Agent):** A lightweight Filebeat log shipper is linked to the honeypot's internal directory through a shared named Docker volume mount. Filebeat hooks the live text files and instantly ships events off to the backend.
3. **Structured Indexing (The Database Backend):** Elasticsearch ingests the raw telemetry streams, dynamically mapping unformatted string layers into strongly typed, structured database indices. 
4. **Operations Center (The Visual SIEM):** Kibana queries the data nodes to populate visual threat hunting workspaces, mapping live credential statistics, executed binaries, and connection logs.

---

## ⚙️ Deployment & Setup Guide

Follow these sequential steps to stand up the NetherSiphon architecture from scratch on your host environment.

### 1. Prerequisites
Ensure the following virtualization engines are installed and running on your host system:
* [Docker Desktop](https://www.docker.com/products/docker-desktop/)
* WSL2 (Windows Subsystem for Linux) backend enabled (if deploying on Windows OS).
* An SSH client terminal (OpenSSH, PuTTY, etc.)

### 2. Establish Workspace Directory Structure
Open your terminal (or PowerShell) and construct the project workspace along with the required sub-directories for configuration mounts:
```bash
mkdir -p my-honeypot/config
cd my-honeypot
```

### 3. Create Configuration Specifications
Populate your environment with the structural configuration code blocks provided in the **Production Configurations** section below.
1. Save the multi-service blueprint as `docker-compose.yml` in the root `my-honeypot/` directory.
2. Save the shipper ingestion properties as `filebeat.yml` inside the `config/` sub-folder (`my-honeypot/config/filebeat.yml`).

### 4. Initialize the Infrastructure Stack
Execute the orchestration command to pull the images down, map dependencies, provision the shared storage volumes, and spin up the microservices in a detached background state:
```bash
docker compose up -d
```
Verify all four containers are running flawlessly by auditing the operational process list:
```bash
docker compose ps
```

### 5. Simulate an Adversarial Intrusion Event
To test ingestion integrity, execute a mock brute-force SSH attack against your local deception node. Force your terminal to connect directly via port `2222`:
```bash
ssh root@localhost -p 2222
```
* Type `yes` when prompted to accept the host key authentication footprint.
* Input mock credentials (e.g., username: `admin`, password: `password123`).
* Execute standard reconnaissance terminal commands within the interactive sandbox (e.g., `uname -a`, `cat /etc/passwd`).
* Type `exit` to sever the session connection.

### 6. Map the Visual SIEM Index Configuration
1. Open your web browser and navigate to the Kibana interface at: **`http://localhost:5601`**
2. Expand the left-hand navigation sidebar, scroll down to the bottom, and select **Stack Management** ➔ **Index Patterns**.
3. Click **Create index pattern**.
4. In the Name matching text boundary, type exactly: `filebeat-*` (The interface will display a green verification message confirming it matches the stored indices).
5. Select **`@timestamp`** from the Timestamp field dropdown picker menu.
6. Click **Create index pattern** to finalize the mapping framework.
7. Click the top-left navigation menu icon and select **Discover**. You will instantly be presented with live, structured, interactive timelines tracking your captured attack telemetry!

---

## 🛠️ Production Configurations & Codebases

### 1. Multi-Container Infrastructure Framework (`docker-compose.yml`)
```yaml
version: '3.8'

services:
  cowrie:
    image: cowrie/cowrie:latest
    container_name: cowrie_honeypot
    restart: unless-stopped
    ports:
      - "2222:2222"
    volumes:
      - ./config/cowrie.cfg:/cowrie/cowrie-git/etc/cowrie.cfg:ro
      - cowrie_logs:/cowrie/cowrie-git/var/log/cowrie

  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.17.10
    container_name: elasticsearch_backend
    restart: unless-stopped
    environment:
      - discovery.type=single-node
      - ES_JAVA_OPTS=-Xms512m -Xmx512m
    volumes:
      - es_data:/usr/share/elasticsearch/data

  kibana:
    image: docker.elastic.co/kibana/kibana:7.17.10
    container_name: kibana_dashboard
    restart: unless-stopped
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    depends_on:
      - elasticsearch

  filebeat:
    image: docker.elastic.co/beats/filebeat:7.17.10
    container_name: filebeat_shipper
    restart: unless-stopped
    user: root
    command: filebeat -e -strict.perms=false
    volumes:
      - ./config/filebeat.yml:/usr/share/filebeat/filebeat.yml:ro
      - cowrie_logs:/var/log/cowrie:ro
    depends_on:
      - elasticsearch
      - cowrie

volumes:
  es_data:
  cowrie_logs:
```

### 2. Log Collection Profile Configuration (`config/filebeat.yml`)
```yaml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/cowrie/cowrie.json
  json.keys_under_root: true
  json.overwrite_keys: true

output.elasticsearch:
  hosts: ["http://elasticsearch:9200"]
  index: "cowrie-logs-%{+yyyy.MM.dd}"

setup.template.name: "cowrie"
setup.template.pattern: "cowrie-logs-*"
setup.template.settings:
  index.number_of_shards: 1
```

---

## 🔍 System Engineering Obstacles & Remediation Actions

### 💥 Challenge 1: JVM Memory Out-of-Bounds & Initialization Failures
* **Symptom:** The Elasticsearch database container repeatedly crashed on launch, emitting the error: `Error: Could not find or load main class "-Xms512m"`.
* **Root Cause:** Enclosing Java environment variables inside absolute string quotes (`"-Xms512m -Xmx512m"`) forced the container's compilation script to interpret the entire configuration string as a single unmapped execution file rather than discrete cluster parameters.
* **Remediation:** Removed the outer quote wrappers within the `ES_JAVA_OPTS` property block. This let the environment parse the boundaries natively, establishing a stable single-node database core.

### 💥 Challenge 2: Cross-Platform File System Permission Disconnects
* **Symptom:** The Filebeat shipping microservice crashed on initialization, outputting: `Exiting: error loading config file: config file ("filebeat.yml") can only be writable by the owner but the permissions are "-rwxrwxrwx"`.
* **Root Cause:** Elastic products enforce a hardcoded security compliance validation rejecting any execution files that have relaxed global read/write access. Because the project was hosted on a Windows filesystem mounting down into a Linux WSL2 container network, NTFS file translations default to global write permissions (`777`), breaking Linux container policy constraints.
* **Remediation:** Altered the orchestration engine initialization rules by appending an explicit execution flag override string: `command: filebeat -e -strict.perms=false`. This safely bypassed the permission strictness check while maintaining stable operational security.

### 💥 Challenge 3: Ingestion Directory Volume Desynchronization
* **Symptom:** Ingestion fields showed 0 matching results inside Kibana, even though manual connection tests on the honeypot were responding perfectly.
* **Root Cause:** The external shared mounting paths incorrectly linked down into `/home/cowrie/cowrie-git/var/log/cowrie`. In modern container distributions, the application logs directly to the root baseline directory `/cowrie/cowrie-git/var/log/cowrie/`. This path mismatch forced Filebeat to read an empty volume.
* **Remediation:** Rewrote the volume mounting maps inside the orchestration layer, connecting the log directory directly to the shipper core and unlocking index pattern resolution.

---

## 📈 Live Analytical Threat Intelligence Captured

Once the pipeline was resolved, simulated adversarial campaigns were run against the network, revealing telemetry indexing in Kibana:

* **Authentication Fingerprinting:** Intercepted active automated brute-force attacks, cataloging dictionary hacking metrics (`cowrie.username` and `cowrie.password`).
* **Operational Telemetry Tracing:** Logged source IP properties (`src_ip`) to isolate tactical vector paths.
* **Session Replay & Post-Exploitation Tracking:** Monitored session execution tables (`CMD`), logging internal binary calls (`uname -a`), password file sweeps (`cat /etc/passwd`), and remote malware execution scripts (`wget`).

---

## 📋 Administration Commands

To gracefully spin down the microservices architecture while protecting persistent local databases and data volumes:
```bash
docker compose down
```
To purge the environment completely, including caches and data history indices to clean state:
```bash
docker compose down -v
```

---

Built by [Muhammad Shaheer Akhtar](https://github.com/zinmeir)
