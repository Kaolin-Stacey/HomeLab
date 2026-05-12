# Self-Hosted Homelab Infrastructure
A modular, self-hosted homelab built with Docker Compose, focused on automation, media pipelines, networking, and smart home integration.

This project serves as a hands-on environment to explore DevOps practices, containerised infrastructure, and real-world system design.

Designed to simulate a production-like environment for deploying and managing interconnected services using modern DevOps practices.

---

## Overview

The homelab is organised into independent stacks, each responsible for a specific domain (media, networking, development, monitoring, etc.).  

This modular architecture improves maintainability, scalability, and isolation between services while allowing individual components to be developed and deployed independently.

---

## Key Features
- Modular stack-based architecture for service isolation and scalability  
- Automated media pipeline with integrated downloaders and indexers  
- Reverse proxy with SSL for secure service exposure  
- Centralised CI/CD workflow using GitHub Actions and a self-hosted runner  
- Secure secret management with no credentials stored in the repository  
- Self-hosted development and monitoring environments  
---

## Purpose

This homelab is used to:
- experiment with DevOps and infrastructure design  
- build and manage containerised systems  
- explore automation and orchestration  
- simulate real-world deployment environments  
---

## Project Structure

```bash
HomeLab/
├─ stacks/
│  ├─ database/        # MySQL
│  ├─ dev/             # Containerised development environment (Ubuntu)
│  ├─ downloaders/     # Transmission, Deluge
│  ├─ games/           # Crafty (Minecraft server management)
│  ├─ home_assistant/  # Home Assistant
│  ├─ media/           # Sonarr, Radarr, Prowlarr, FlareSolverr
│  ├─ metrics/         # Glances (monitoring)
│  ├─ networking/      # Nginx Proxy Manager, Pi-hole
│  ├─ plex/            # Plex media server
│  └─ voice/           # Murmur (Mumble server)
└─ README.md
````
---

## CI/CD & Secrets Management

- Implemented CI/CD-style deployments using GitHub Actions with a self-hosted runner

- Managed sensitive configuration using GitHub Secrets, securely injecting environment variables at runtime

- Automated stack deployments via GitHub Actions triggering `docker compose up`

- Ensured no credentials or sensitive data are stored in the repository
  
---

## Tech Stack

- Docker / Docker Compose

- Linux (self-hosted environment)

- Networking (reverse proxy, DNS filtering, segmentation)

- Git & GitHub Actions (CI/CD workflows)

- Secrets management (GitHub Secrets)

- Monitoring and observability (Glances, future Grafana)