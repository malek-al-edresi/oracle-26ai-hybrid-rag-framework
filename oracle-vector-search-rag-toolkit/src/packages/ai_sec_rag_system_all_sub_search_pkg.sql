create or replace PACKAGE "AI_SEC_RAG_SYSTEM_ALL_SUB_SEARCH_PKG" IS   
    /* ==================================================================   
       PACKAGE    :  AI_SEC_RAG_SYSTEM_ALL_SUB_SEARCH_PKG   
       GENERATED ON  :  2026-04-06   
       DESCRIPTION   :  Refactored package for AI_SEC_RAG_SYSTEM_ALL_SUB_SEARCH_PKG.   
                        Structural refactoring only - all business logic   
                        preserved exactly as in the original source.   
 
       CHANGE HISTORY :   
       DATE              AUTHOR                     DESCRIPTION   
       ----------       ----------------------     ---------------------------   
       2026-06-11       ENG. Malek Al-Edresi       Implemented Hybrid RAG Architecture, 
                                                    Document Chunking, and True 
                                                    Hybrid Vector Retrieval. 
       2026-04-06       ENG. Malek Al-Edresi       Structural refactoring:   
                                                    standardized headers,   
                                                    English documentation, and   
                                                    professional formatting   
       ================================================================== */   
    /************************************************************************   
     * Function  : search_documents   
     ************************************************************************/   
    FUNCTION search_documents (   
        p_patient_id IN NUMBER,   
        p_question   IN VARCHAR2,   
        p_top_k      IN NUMBER DEFAULT 5   
    ) RETURN CLOB;   
 
    /************************************************************************   
     * Function  : search_all_documents   
     ************************************************************************/   
    FUNCTION search_all_documents (   
        p_question IN VARCHAR2,   
        p_top_k    IN NUMBER DEFAULT 5   
    ) RETURN CLOB;   
 
    /************************************************************************   
     * Function  : find_similar_documents   
     ************************************************************************/   
    FUNCTION find_similar_documents (   
        p_patient_id       IN NUMBER DEFAULT NULL,   
        p_reference_text   IN VARCHAR2,   
        p_top_k            IN NUMBER DEFAULT 5   
    ) RETURN CLOB;   
END AI_SEC_RAG_SYSTEM_ALL_SUB_SEARCH_PKG;
/

create or replace PACKAGE BODY "AI_SEC_RAG_SYSTEM_ALL_SUB_SEARCH_PKG" IS   
    /* ==================================================================   
       PACKAGE BODY    :  AI_SEC_RAG_SYSTEM_ALL_SUB_SEARCH_PKG   
       GENERATED ON  :  2026-04-06   
       ================================================================== */   
    FUNCTION search_documents (   
        p_patient_id IN NUMBER,   
        p_question   IN VARCHAR2,   
        p_top_k      IN NUMBER DEFAULT 5   
    ) RETURN CLOB IS   
        l_result              CLOB;   
        l_question_embedding  VECTOR;   
    BEGIN   
        IF p_patient_id IS NULL OR p_question IS NULL THEN   
            RETURN 'Error: Patient ID or Question cannot be empty';   
        END IF;   
 
        l_question_embedding := AI_SEC_RAG_SYSTEM_ALL_SUB_EMBED_PKG.generate_embedding(p_question);   
 
        IF l_question_embedding IS NULL THEN   
            RETURN 'Error: Could not generate embedding for question';   
        END IF;   
 
        FOR c IN (   
            SELECT text 
            FROM ( 
                SELECT c.chunk_text AS text, VECTOR_DISTANCE(c.embedding, l_question_embedding, COSINE) AS dist 
                FROM AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENT_CHUNKS c 
                JOIN AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENTS d ON c.doc_id = d.doc_id 
                WHERE d.patient_id = p_patient_id AND c.embedding IS NOT NULL 
                UNION ALL 
                SELECT doc_text AS text, VECTOR_DISTANCE(embedding, l_question_embedding, COSINE) AS dist 
                FROM AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENTS 
                WHERE patient_id = p_patient_id AND embedding IS NOT NULL AND is_chunked = 0 
            ) 
            ORDER BY dist 
            FETCH FIRST p_top_k ROWS ONLY   
        ) LOOP   
            IF l_result IS NULL THEN   
                l_result := c.text;   
            ELSE   
                l_result := l_result || CHR(10) || '--' || CHR(10) || c.text;   
            END IF;   
        END LOOP;   
 
        IF l_result IS NULL THEN   
            RETURN 'No relevant documents found for the query: ' || p_question;   
        END IF;   
 
        RETURN l_result;   
    EXCEPTION   
        WHEN OTHERS THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'search_documents',   
                p_custom_message   => 'Error in searching documents'   
            );   
    END search_documents;   
 
    FUNCTION search_all_documents (   
        p_question IN VARCHAR2,   
        p_top_k    IN NUMBER DEFAULT 5   
    ) RETURN CLOB IS   
        l_result              CLOB;   
        l_question_embedding  VECTOR;   
    BEGIN   
        IF p_question IS NULL THEN   
            RETURN 'Error: Question cannot be empty';   
        END IF;   
 
        l_question_embedding := AI_SEC_RAG_SYSTEM_ALL_SUB_EMBED_PKG.generate_embedding(p_question);   
 
        IF l_question_embedding IS NULL THEN   
            RETURN 'Error: Could not generate embedding for question';   
        END IF;   
 
        FOR c IN (   
            SELECT text 
            FROM ( 
                SELECT chunk_text AS text, VECTOR_DISTANCE(embedding, l_question_embedding, COSINE) AS dist 
                FROM AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENT_CHUNKS 
                WHERE embedding IS NOT NULL 
                UNION ALL 
                SELECT doc_text AS text, VECTOR_DISTANCE(embedding, l_question_embedding, COSINE) AS dist 
                FROM AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENTS 
                WHERE embedding IS NOT NULL AND is_chunked = 0 
            ) 
            ORDER BY dist 
            FETCH FIRST p_top_k ROWS ONLY   
        ) LOOP   
            IF l_result IS NULL THEN   
                l_result := c.text;   
            ELSE   
                l_result := l_result || CHR(10) || '--' || CHR(10) || c.text;   
            END IF;   
        END LOOP;   
 
        IF l_result IS NULL THEN   
            RETURN 'No relevant documents found for the query: ' || p_question;   
        END IF;   
 
        RETURN l_result;   
    EXCEPTION   
        WHEN OTHERS THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'search_all_documents',   
                p_custom_message   => 'Error in searching all documents'   
            );   
    END search_all_documents;   
 
    FUNCTION find_similar_documents (   
        p_patient_id       IN NUMBER DEFAULT NULL,   
        p_reference_text   IN VARCHAR2,   
        p_top_k            IN NUMBER DEFAULT 5   
    ) RETURN CLOB IS   
        l_result              CLOB;   
        l_reference_embedding  VECTOR;   
    BEGIN   
        IF p_reference_text IS NULL THEN   
            RETURN 'Error: Reference text cannot be empty';   
        END IF;   
 
        l_reference_embedding := AI_SEC_RAG_SYSTEM_ALL_SUB_EMBED_PKG.generate_embedding(p_reference_text);   
 
        IF l_reference_embedding IS NULL THEN   
            RETURN 'Error: Could not generate embedding for reference text';   
        END IF;   
 
        IF p_patient_id IS NOT NULL THEN   
            FOR c IN (   
                SELECT text 
                FROM ( 
                    SELECT c.chunk_text AS text, VECTOR_DISTANCE(c.embedding, l_reference_embedding, COSINE) AS dist 
                    FROM AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENT_CHUNKS c 
                    JOIN AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENTS d ON c.doc_id = d.doc_id 
                    WHERE d.patient_id = p_patient_id AND c.embedding IS NOT NULL 
                    UNION ALL 
                    SELECT doc_text AS text, VECTOR_DISTANCE(embedding, l_reference_embedding, COSINE) AS dist 
                    FROM AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENTS 
                    WHERE patient_id = p_patient_id AND embedding IS NOT NULL AND is_chunked = 0 
                ) 
                ORDER BY dist 
                FETCH FIRST p_top_k ROWS ONLY   
            ) LOOP   
                IF l_result IS NULL THEN   
                    l_result := c.text;   
                ELSE   
                    l_result := l_result || CHR(10) || '--' || CHR(10) || c.text;   
                END IF;   
            END LOOP;   
        ELSE   
            FOR c IN (   
                SELECT text 
                FROM ( 
                    SELECT chunk_text AS text, VECTOR_DISTANCE(embedding, l_reference_embedding, COSINE) AS dist 
                    FROM AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENT_CHUNKS 
                    WHERE embedding IS NOT NULL 
                    UNION ALL 
                    SELECT doc_text AS text, VECTOR_DISTANCE(embedding, l_reference_embedding, COSINE) AS dist 
                    FROM AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENTS 
                    WHERE embedding IS NOT NULL AND is_chunked = 0 
                ) 
                ORDER BY dist 
                FETCH FIRST p_top_k ROWS ONLY   
            ) LOOP   
                IF l_result IS NULL THEN   
                    l_result := c.text;   
                ELSE   
                    l_result := l_result || CHR(10) || '--' || CHR(10) || c.text;   
                END IF;   
            END LOOP;   
        END IF;   
 
        IF l_result IS NULL THEN   
            RETURN 'No relevant documents found for the reference text.';   
        END IF;   
 
        RETURN l_result;   
    EXCEPTION   
        WHEN OTHERS THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'find_similar_documents',   
                p_custom_message   => 'Error in finding similar documents'   
            );   
    END find_similar_documents;   
END AI_SEC_RAG_SYSTEM_ALL_SUB_SEARCH_PKG;
/
