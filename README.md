# Oracle Vector Search RAG Toolkit 🚀

[![Oracle Database](https://img.shields.io/badge/Oracle-Database_26ai-red.svg?logo=oracle)](https://www.oracle.com/database/)
[![Oracle APEX](https://img.shields.io/badge/Oracle-APEX-lightgrey.svg?logo=oracle)](https://apex.oracle.com/)

A production-ready reference implementation and toolkit demonstrating how to build a complete **Hybrid Retrieval-Augmented Generation (RAG)** platform natively on **Oracle Database 26ai**.

## 📖 Overview

The **Oracle Vector Search RAG Toolkit** provides a complete, modular, and extensible architecture for ingesting, chunking, embedding, and searching enterprise data using Oracle's native AI capabilities. 

Built specifically for **Oracle Developers, Oracle APEX Developers, Oracle ACE Members, and Database Architects**, this toolkit serves as both an educational learning resource and a production-grade template for building AI-powered applications.

### 🌟 Key Features

*   **Native Oracle AI Vector Search**: Utilizes Oracle 26ai Vector data types (`VECTOR(384, FLOAT32)`) and Vector Indexes (HNSW).
*   **Intelligent Document Chunking**: Built-in automated chunking (`DBMS_VECTOR_CHAIN.UTL_TO_CHUNKS`) for processing large CLOBs and BLOBs (PDFs, Word Docs).
*   **Automated Embeddings**: Seamless generation of vector embeddings via `DBMS_VECTOR.UTL_TO_EMBEDDING` using the `E5_SMALL` model.
*   **Event-Driven Synchronization**: An asynchronous event queue (`AI_SEC_RAG_SYSTEM_L_EVENT`) guarantees background synchronization without blocking primary DML transactions.
*   **Hybrid Retrieval Engine**: A comprehensive search pipeline combining semantic vector distance (Cosine similarity) with structured metadata filters.
*   **Pluggable Architecture**: Modular PL/SQL packages with separated DAO, Search, Embedding, and Admin layers.

## 🏗️ Architecture Summary

Data flows from source tables through an asynchronous event queue. A background synchronization process then extracts the text, generates overlapping chunks, computes semantic embeddings, and stores them in vector-indexed tables for lightning-fast retrieval.

> For a deep dive into the architecture, view the [Architecture Documentation](docs/architecture.md) and [Data Flow Diagrams](docs/data_flow.md).

## 🚀 Getting Started

Deploying the toolkit is straightforward. All components are logically structured into tables, views, packages, triggers, and indexes.

1.  **Review Prerequisites**: Ensure you are running Oracle Database 23ai/26ai with Vector Search enabled.
2.  **Deploy**: Run the automated `install.sql` script.
3.  **Explore**: Use the API to index your first document.

> Detailed deployment instructions are available in the [Installation Guide](docs/installation_guide.md).

## 📚 Documentation Directory

Explore the detailed documentation to understand and extend the toolkit:

*   📘 [Architecture Details](docs/architecture.md) - System design, chunking strategy, and vector indexes.
*   📊 [Data Flow Diagrams](docs/data_flow.md) - Mermaid diagrams illustrating the ingestion and search pipelines.
*   🛠️ [Developer Guide](docs/developer_guide.md) - Onboarding guide, workflow explanations, and extensibility patterns.
*   🔌 [API Documentation](docs/api_documentation.md) - PL/SQL package specifications and usage examples.
*   ⚙️ [Installation Guide](docs/installation_guide.md) - Step-by-step setup and teardown instructions.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the issues page.

---
Built with Eng. Malek M. Al-Edresi ❤️.
