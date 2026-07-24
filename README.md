# DevOps Student Forum 🚀
> An interactive web-based community platform and collaboration hub designed for students and DevOps learners, featuring threaded discussions, gamification badges, leaderboards, and automated CI/CD deployment pipelines.

Built to foster peer-to-peer learning and technical collaboration, combining a robust forum engine with containerized workflows.

---

## What the Platform Offers

### Community & Discussions
* **Threaded Categories:** Organized spaces for general chat, technical questions, and troubleshooting.
* **Interactive Collaboration:** Real-time posting, replies, and community engagement.

### Gamification & Recognition
* **Badges System:** Earn achievement badges (like question sharks and milestone awards) for active participation.
* **Dynamic Leaderboard:** Real-time tracking of user points, best answers, and community rankings.

---

## Project Architecture & CI/CD Pipeline

```mermaid
flowchart TB
    classDef frontend fill:#333,stroke:#666,stroke-width:2px,color:#fff;
    classDef backend fill:#222,stroke:#444,stroke-width:2px,color:#fff;
    classDef engine fill:#8e44ad,stroke:#fff,stroke-width:2px,color:#fff;
    classDef external fill:#2980b9,stroke:#3498db,stroke-width:2px,color:#fff;
    classDef process fill:#16a085,stroke:#2ecc71,stroke-width:2px,color:#fff;

    subgraph GH [GitHub Repository]
        Code[Source Code & Frontend Assets]:::frontend
    end

    subgraph Jenkins [Jenkins CI/CD Server]
        Poll[Poll SCM / Webhook Trigger]:::process
        Build[Docker Image Build]:::backend
    end

    subgraph AWS [AWS Server Host]
        Container[Docker Container]:::engine
        Nginx[Nginx Web Server]:::external
    end

    GH -- Push Code --> Poll
    Poll --> Build
    Build --> Container
    Container --> Nginx
