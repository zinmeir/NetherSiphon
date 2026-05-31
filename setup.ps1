# setup.ps1
Write-Host "===================================================="
Write-Host "🚀 Starting Threat Intel Honeypot Project Generator"
Write-Host "===================================================="

Write-Host "📁 Creating directories..."
New-Item -ItemType Directory -Force -Path "config", "data" | Out-Null
New-Item -ItemType File -Force -Path "data\.keep" | Out-Null

Write-Host "📝 Generating .env file..."
Set-Content -Path ".env" -Value @'
# ELK Stack Version
ELASTIC_VERSION=8.10.2

# Passwords (Change before deploying!)
ELASTIC_PASSWORD=SuperSecurePassword123!
KIBANA_PASSWORD=SuperSecurePassword123!

ES_JAVA_OPTS="-Xms512m -Xmx512m"
'@

Write-Host "📝 Generating docker-compose.yml..."
Set-Content -Path "docker-compose.yml" -Value @'
version: '3.8'

services:
  cowrie:
    image: cowrie/cowrie:latest
    container_name: cowrie_honeypot
    restart: unless-stopped
    ports:
      - "2222:2222"
    volumes:
      - ./config/cowrie.cfg:/home/cowrie/cowrie-git/etc/cowrie.cfg:ro
      - cowrie_logs:/home/cowrie/cowrie-git/var/log/cowrie
    networks:
      - honeypot_net

  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:${ELASTIC_VERSION}
    container_name: elasticsearch_backend
    restart: unless-stopped
    environment:
      - node.name=es-node-1
      - discovery.type=single-node
      - ELASTIC_PASSWORD=${ELASTIC_PASSWORD}
      - ES_JAVA_OPTS=${ES_JAVA_OPTS}
      - xpack.security.enabled=true
      - xpack.security.http.ssl.enabled=false
    volumes:
      - es_data:/usr/share/elasticsearch/data
    networks:
      - honeypot_net

  kibana:
    image: docker.elastic.co/kibana/kibana:${ELASTIC_VERSION}
    container_name: kibana_dashboard
    restart: unless-stopped
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
      - ELASTICSEARCH_USERNAME=elastic
      - ELASTICSEARCH_PASSWORD=${ELASTIC_PASSWORD}
    depends_on:
      - elasticsearch
    networks:
      - honeypot_net

  filebeat:
    image: docker.elastic.co/beats/filebeat:${ELASTIC_VERSION}
    container_name: filebeat_shipper
    restart: unless-stopped
    user: root
    command: filebeat -e -strict.perms=false
    volumes:
      - ./config/filebeat.yml:/usr/share/filebeat/filebeat.yml:ro
      - cowrie_logs:/var/log/cowrie:ro
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
      - ELASTIC_PASSWORD=${ELASTIC_PASSWORD}
    depends_on:
      - elasticsearch
      - cowrie
    networks:
      - honeypot_net

volumes:
  es_data:
  cowrie_logs:

networks:
  honeypot_net:
    driver: bridge
'@

Write-Host "📝 Generating config/cowrie.cfg..."
Set-Content -Path "config\cowrie.cfg" -Value @'
[honeypot]
hostname = svr-ubuntu-01

[output_jsonlog]
enabled = true
logfile = var/log/cowrie/cowrie.json
'@

Write-Host "📝 Generating config/filebeat.yml..."
Set-Content -Path "config\filebeat.yml" -Value @'
filebeat.inputs:
- type: filestream
  id: cowrie-json-logs
  enabled: true
  paths:
    - /var/log/cowrie/cowrie.json
  parsers:
    - ndjson:
        target: "cowrie"
        add_error_key: true

setup.template.settings:
  index.number_of_shards: 1

output.elasticsearch:
  hosts: ["http://elasticsearch:9200"]
  username: "elastic"
  password: "${ELASTIC_PASSWORD}"
  index: "cowrie-logs-%{+yyyy.MM.dd}"

setup.template.name: "cowrie"
setup.template.pattern: "cowrie-logs-*"

processors:
  - drop_fields:
      fields: ["agent", "ecs", "host", "mac", "hostname", "architecture", "os"]
      ignore_missing: true
'@

Write-Host "===================================================="
Write-Host "✅ Project setup complete successfully!"
Write-Host "===================================================="