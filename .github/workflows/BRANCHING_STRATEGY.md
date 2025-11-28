# Branching Strategy Visualization

## Git Flow với Auto-Publish

```mermaid
gitGraph
    commit id: "v3.1.6"
    branch develop
    checkout develop
    commit id: "feat: new icons"
    commit id: "v3.1.7-beta.1" tag: "beta.1"

    branch feature/weather-icons
    checkout feature/weather-icons
    commit id: "add weather icons"
    checkout develop
    merge feature/weather-icons
    commit id: "v3.1.7-beta.2" tag: "beta.2"

    commit id: "fix: icon size"
    commit id: "v3.1.7-beta.3" tag: "beta.3"

    checkout main
    merge develop id: "Merge to main"
    commit id: "v3.2.0 (stable)" tag: "v3.2.0"

    checkout develop
    commit id: "fix: minor bug"
    commit id: "v3.2.1-beta.1" tag: "beta.1"
```

## Workflow Trigger Flow

```mermaid
flowchart TB
    Start([Developer]) --> Feature[Create feature branch]
    Feature --> Code[Write code]
    Code --> PR1{Create PR to<br/>develop?}

    PR1 -->|Yes| Merge1[Merge to develop]
    Merge1 --> Beta[🧪 auto_publish_beta.yml]
    Beta --> BetaVer[Version: 3.1.7-beta.X]
    BetaVer --> PubBeta[📦 Publish to pub.dev<br/>as pre-release]

    PubBeta --> Test[Test beta version]
    Test --> Bug{Found bugs?}
    Bug -->|Yes| Code
    Bug -->|No| PR2{Create PR to<br/>main?}

    PR2 -->|Yes| Merge2[Merge to main]
    Merge2 --> Prod[🚀 auto_publish.yml]
    Prod --> StableVer[Version: 3.2.0]
    StableVer --> PubStable[📦 Publish to pub.dev<br/>as stable]

    PubStable --> End([✅ Done])

    style Beta fill:#ffd43b
    style Prod fill:#4caf50
    style BetaVer fill:#fff3cd
    style StableVer fill:#d4edda
```

## Version Progression Timeline

```mermaid
timeline
    title Version Release Timeline

    section Week 1
        Day 1 : develop: 3.1.7-beta.1
              : feat: add weather icons
        Day 2 : develop: 3.1.7-beta.2
              : fix: icon alignment
        Day 3 : develop: 3.1.7-beta.3
              : feat: add animation icons

    section Week 2
        Day 5 : Testing completed
        Day 6 : main: 3.2.0 (STABLE)
              : Merge develop → main

    section Week 3
        Day 8 : develop: 3.2.1-beta.1
              : fix: minor bug
        Day 9 : main: 3.2.1 (HOTFIX)
              : Critical bugfix
```

## State Diagram: Package Version States

```mermaid
stateDiagram-v2
    [*] --> Development
    Development --> BetaTesting: Push to develop

    state BetaTesting {
        [*] --> Beta1: auto_publish_beta.yml
        Beta1 --> Beta2: Fix & Push
        Beta2 --> Beta3: More changes
        Beta3 --> BetaN: ...
    }

    BetaTesting --> StableRelease: Merge to main

    state StableRelease {
        [*] --> BuildAndTest: auto_publish.yml
        BuildAndTest --> Publish: Tests pass
        Publish --> Live: Available on pub.dev
    }

    StableRelease --> [*]
    StableRelease --> Development: New features

    note right of BetaTesting
        Pre-release versions
        Hidden by default on pub.dev
        For testing only
    end note

    note right of StableRelease
        Production version
        Visible to all users
        Recommended for use
    end note
```

## Comparison: Beta vs Stable

```mermaid
flowchart LR
    subgraph Beta["🧪 Beta Release (develop)"]
        direction TB
        B1[Trigger: Push to develop]
        B2[Version: X.Y.Z-beta.N]
        B3[GitHub: Pre-release]
        B4[pub.dev: Hidden by default]
        B5[Usage: Testing only]
        B1 --> B2 --> B3 --> B4 --> B5
    end

    subgraph Stable["🚀 Stable Release (main)"]
        direction TB
        S1[Trigger: Merge to main]
        S2[Version: X.Y.Z]
        S3[GitHub: Release]
        S4[pub.dev: Visible to all]
        S5[Usage: Production ready]
        S1 --> S2 --> S3 --> S4 --> S5
    end

    Beta -.->|After testing| Stable

    style Beta fill:#fff3cd,stroke:#ffc107
    style Stable fill:#d4edda,stroke:#28a745
```

## Decision Tree: Which Branch to Use?

```mermaid
flowchart TD
    Start{What are you doing?}

    Start -->|New feature| Feature[Work on feature branch]
    Start -->|Bug fix| BugType{Critical bug in production?}
    Start -->|Release| Release[Merge develop → main]

    BugType -->|Yes| Hotfix[Hotfix branch from main]
    BugType -->|No| BugFix[Fix on develop]

    Feature --> FeatureDone{Feature complete?}
    FeatureDone -->|Yes| MergeDev[Merge to develop]
    FeatureDone -->|No| Feature

    MergeDev --> AutoBeta[🤖 Auto: beta.X published]
    AutoBeta --> TestBeta{Tests pass?}
    TestBeta -->|No| BugFix
    TestBeta -->|Yes| ReadyProd{Ready for production?}

    ReadyProd -->|No| Feature
    ReadyProd -->|Yes| Release

    Release --> AutoStable[🤖 Auto: stable published]

    BugFix --> AutoBeta
    Hotfix --> AutoStable

    AutoStable --> Done([✅ Done])

    style AutoBeta fill:#ffd43b
    style AutoStable fill:#4caf50
```

---

## 📝 Giải thích các trạng thái

### 🏗️ Development (Feature Branch)

- Làm việc trên các tính năng mới
- Không trigger workflow
- Tạo PR vào `develop` khi hoàn thành

### 🧪 Beta Testing (Develop Branch)

- Mỗi push → tạo version beta mới
- Version format: `X.Y.Z-beta.N`
- Tự động publish lên pub.dev (pre-release)
- Dùng để testing trước khi release chính thức

### 🚀 Stable Release (Main Branch)

- Merge từ develop sau khi testing thành công
- Version format: `X.Y.Z`
- Tự động publish lên pub.dev (stable)
- Production-ready

### 🔥 Hotfix

- Fix urgent bugs trên production
- Branch từ `main`, merge trực tiếp về `main`
- Trigger workflow stable release
- Nhớ merge lại vào `develop` sau đó

---

**Tip**: Lưu lại các diagrams này để hiểu rõ flow! 📊
