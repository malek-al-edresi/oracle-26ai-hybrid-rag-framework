# Developer Guide

Welcome to the Oracle Vector Search RAG Toolkit! This guide covers the essential workflows and teaches developers how to leverage the architecture.

## Workflow Deep-Dives

### 1. The Ingestion Workflow
When a new document (e.g., Medical Report, Contract, Knowledge Base Article) is created in your APEX application, you do **not** want to generate embeddings synchronously. Why? Because large AI models take time, and user interfaces should be snappy.

**How it works here:**
1. You perform a standard `INSERT INTO MY_SOURCE_TABLE`.
2. A database Trigger (e.g., `TRG_AI_RAG_MEDICAL_REPORT`) fires and inserts a tiny record into `AI_SEC_RAG_SYSTEM_L_EVENT` with status `NEW`.
3. A background DBMS_SCHEDULER job (which you can configure) calls `AI_SEC_RAG_SYSTEM_ALL_SUB_SYNC_PKG.process_rag_events(50)`.
4. The background job processes the event, extracts the payload, and does the heavy AI lifting.

### 2. The Chunking Workflow
Sending a 100-page PDF to an LLM context window usually results in failure (Token Limits) or hallucinations. The toolkit solves this with **Chunking**.

Inside `AI_SEC_RAG_SYSTEM_ALL_SUB_DAO_PKG.process_document_chunks`, the system uses `DBMS_VECTOR_CHAIN.UTL_TO_CHUNKS`:
- **Parameters**: `{"by":"words","max":"500","overlap":"50"}`
- **Logic**: It parses the BLOB/CLOB and splits the text into 500-word segments, overlapping by 50 words to maintain context between chunks.
- **Storage**: These chunks are stored in `AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENT_CHUNKS`.

### 3. The Embedding Workflow
Embeddings represent text as high-dimensional arrays of floating-point numbers.
Inside `AI_SEC_RAG_SYSTEM_ALL_SUB_EMBED_PKG`, the `generate_embedding_from_clob` function wraps `DBMS_VECTOR.UTL_TO_EMBEDDING`.
- The text is passed.
- The `E5_SMALL` model processes the text.
- A `VECTOR(384, FLOAT32)` is returned and saved to the database.

### 4. The Search Workflow
When a user types "What are the side effects of Aspirin?" into your application:
1. `AI_SEC_RAG_SYSTEM_ALL_SUB_SEARCH_PKG.search_documents` is called.
2. The user's query is converted into a Vector Embedding.
3. An Oracle `VECTOR_DISTANCE(..., COSINE)` SQL query compares the query embedding against all millions of chunk embeddings natively using the HNSW index.
4. The top *K* results are returned instantly.

## Customizing the Toolkit

### Modifying the Chunking Strategy
If your documents are code snippets, you might prefer chunking by lines instead of words. Modify the JSON parameter in the DAO package:
```sql
-- Change this:
v_json_params := JSON('{"by":"words","max":"500","overlap":"50"}');
-- To this:
v_json_params := JSON('{"by":"lines","max":"50","overlap":"5"}');
```

### Adding New Source Tables
To integrate a new table into the RAG pipeline:
1. Create a trigger on your new table that inserts into `AI_SEC_RAG_SYSTEM_L_EVENT`.
2. Update the `AI_SEC_SYS_VIEW_PATIENT_FULL_HISTORY_LOOKUP` view to `UNION ALL` your new table data.
