-- Oracle Vector Search RAG Toolkit Installation Script

SET DEFINE OFF;

PROMPT Installing Tables...
@@../src/tables/ai_sys_sec_readlog_errors.sql
@@../src/tables/ai_sec_rag_system_l_help_ai_documents.sql
@@../src/tables/ai_sec_rag_system_l_help_ai_document_chunks.sql
@@../src/tables/ai_sec_rag_system_l_event.sql

PROMPT Installing Views...
@@../src/views/ai_sec_sys_view_patient_full_history_lookup.sql

PROMPT Installing Packages (Order Matters)...
@@../src/packages/ai_sec_rag_system_all_sub_err_handler_pkg.sql
@@../src/packages/ai_sec_rag_system_all_sub_util_pkg.sql
@@../src/packages/ai_sec_rag_system_all_sub_embed_pkg.sql
@@../src/packages/ai_sec_rag_system_all_sub_dao_pkg.sql
@@../src/packages/ai_sec_rag_system_all_sub_search_pkg.sql
@@../src/packages/ai_sec_rag_system_all_sub_sync_pkg.sql
@@../src/packages/ai_sec_rag_system_all_sub_admin_pkg.sql
@@../src/packages/ai_sec_rag_system_all.sql

PROMPT Installing Triggers...
@@../src/triggers/audit_triggers.sql
@@../src/triggers/event_triggers.sql
@@../src/triggers/cleanup_triggers.sql

PROMPT Installing Vector Indexes...
@@../src/indexes/vector_indexes.sql

PROMPT Installation Complete.
