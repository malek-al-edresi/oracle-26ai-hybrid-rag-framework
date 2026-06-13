# API Documentation

The toolkit exposes a primary facade package: `AI_SEC_RAG_SYSTEM_ALL`. It acts as the central interface for all core operations, delegating to specialized sub-packages.

## Package: `AI_SEC_RAG_SYSTEM_ALL`

### `sync_ai_document`
Synchronizes a document with the RAG system. Used primarily by the background event processor.
**Parameters:**
- `p_patient_id (NUMBER)`: Identifier for relational filtering.
- `p_source_type (VARCHAR2)`: String identifying the origin table.
- `p_source_id (NUMBER)`: Primary key of the source record.
- `p_doc_text (CLOB)`: The text content of the document.
- `p_doc_date (DATE)`: Timestamp.
- `p_file (BLOB)`: (Optional) Binary file payload (PDF, DOCX).
- `p_mimetype (VARCHAR2)`: (Optional) MIME type of the file.
- `p_filename (VARCHAR2)`: (Optional) File name.

### `search_documents`
Performs a hybrid vector search restricted to a specific patient/entity.
**Parameters:**
- `p_patient_id (NUMBER)`: Restricts search to this ID.
- `p_question (VARCHAR2)`: The natural language search query.
- `p_top_k (NUMBER)`: Default `5`. The maximum number of relevant chunks to return.
**Returns:**
- `CLOB`: A concatenated string of the most relevant document chunks.

### `validate_ai_integration`
Runs a diagnostic test to ensure the search and embedding workflows are functional for a specific entity.
**Parameters:**
- `p_patient_id (NUMBER)`: Entity ID to validate.
- `o_status (OUT VARCHAR2)`: Returns `SUCCESS` or `WARNING`.
- `o_message (OUT VARCHAR2)`: Detailed diagnostic message.

### `refresh_missing_embeddings`
Admin utility to scan the entire document and chunk database and retroactively generate embeddings for any records that missed them (e.g., due to AI service downtime).

## Sub-Packages Overview
For advanced customization, you can directly interface with:
- `AI_SEC_RAG_SYSTEM_ALL_SUB_DAO_PKG`: Direct Data Access Object manipulations.
- `AI_SEC_RAG_SYSTEM_ALL_SUB_EMBED_PKG`: Vector arithmetic and embedding generation logic.
- `AI_SEC_RAG_SYSTEM_ALL_SUB_SEARCH_PKG`: Advanced search heuristics (e.g., searching across all patients).
- `AI_SEC_RAG_SYSTEM_ALL_SUB_SYNC_PKG`: Queue management and processing configuration.
- `AI_SEC_RAG_SYSTEM_ALL_SUB_ADMIN_PKG`: System health reporting and global population tasks.
