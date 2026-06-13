# Data Flow Diagrams

This document contains Mermaid sequence and flow diagrams detailing how data moves through the RAG Toolkit.

## Data Ingestion & Background Sync Sequence

```mermaid
sequenceDiagram
    autonumber
    actor Developer
    participant APEX as APEX Application
    participant Source as Source Tables
    participant Trg as Event Triggers
    participant EventQ as Event Queue (Table)
    participant SyncJob as Background Sync Job
    participant API as RAG Package API
    participant AI as Oracle Vector Engine
    participant VectorDB as Vector Tables & Indexes

    Developer->>APEX: Creates new record
    APEX->>Source: INSERT/UPDATE Data
    Source->>Trg: Fires AFTER ROW Trigger
    Trg->>EventQ: Insert Event (Status: NEW)
    
    Note over EventQ, SyncJob: Asynchronous Boundary
    
    SyncJob->>EventQ: Polling: SELECT WHERE Status = 'NEW'
    EventQ-->>SyncJob: Return Batch of Events
    SyncJob->>API: process_rag_events(batch_size)
    
    API->>Source: Fetch Full CLOB/BLOB via Lookup View
    Source-->>API: Return Document Payload
    
    API->>AI: Extract Text & Generate Chunks
    AI-->>API: Return Text Chunks
    
    API->>AI: Generate Vector Embeddings (E5_SMALL)
    AI-->>API: Return VECTOR(384, FLOAT32)
    
    API->>VectorDB: Upsert Document & Chunks + Vectors
    VectorDB-->>API: Success
    
    API->>EventQ: UPDATE Status = 'PROCESSED'
```

## Hybrid Search Flow

```mermaid
graph TD
    A[User Query String] --> B[Generate Query Embedding]
    B --> C{Search Strategy}
    
    C -->|Semantic Search| D[HNSW Vector Index Lookup]
    C -->|Metadata Filters| E[Relational WHERE Clauses]
    
    D --> F[Vector Distance Calculation]
    E --> F
    
    F --> G[Merge & Rank Results]
    G --> H[Return Top K CLOBs]
    H --> I[LLM Context Injection / UI Display]
```
