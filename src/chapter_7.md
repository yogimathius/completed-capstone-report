# Chapter 7: System Architecture and Design

With Nexus Flow implemented and running, this chapter provides a comprehensive look at the system architecture that emerged from months of iteration and learning. The final design represents not just a working application, but a case study in how distributed systems can simplify complex development while enabling sophisticated functionality.

## System Overview

Nexus Flow consists of three main components working together to provide AI-powered dream interpretation:

```
┌─────────────────┐        ┌─────────────────┐
│    Nexus Web    │◄──────►│    Nexus Core   │
│    (Frontend)   │        │    (Backend)    │
└─────────────────┘        └─────────────────┘
        ▲                          ▲
        │                          │
        ▼                          ▼
┌─────────────────┐        ┌─────────────────┐        ┌─────────────────┐
│  User Interface │        │  Database (PG)  │        │  Symbol Data    │
│  Dream Input    │        │  Dream Storage  │        │  Repository (PG)│
└─────────────────┘        └─────────────────┘        └─────────────────┘
                                    ▲                           ▲
                                    │                           │
                                    ▼                           ▼
                           ┌─────────────────┐        ┌─────────────────┐
                           │  AI Services    │        │   MCP Symbol    │
                           │  OpenRouter/    │◄──────►│   Lookup        │
                           │  Azure          │        │   Service       │
                           └─────────────────┘        └─────────────────┘
```

## Data Flow Architecture

### Dream Interpretation Flow

1. **User Input**: Dream text submitted via Nexus Web interface
2. **Symbol Extraction**: Nexus Core identifies potential symbols in the dream
3. **Symbol Enhancement**: MCP client queries Symbol Ontology for meanings
4. **AI Processing**: Enhanced prompt sent to AI providers (OpenRouter/Azure)
5. **Response Assembly**: Interpreted dream returned with symbolic context
6. **User Experience**: Rich interpretation displayed with option to save

### Persistence Flow

1. **Local Storage**: Frontend saves dreams locally for offline access
2. **Database Storage**: Dreams persisted to PostgreSQL via Nexus Core API
3. **Retrieval**: Dreams can be browsed, searched, and filtered
4. **Synchronization**: Local and remote storage kept in sync

## Component Deep Dive

### Nexus Core (Backend API)

**Technology Stack**

- **Framework**: Axum for high-performance async HTTP handling
- **Database**: PostgreSQL with SQLx for type-safe queries
- **AI Integration**: Multiple provider support with fallback mechanisms
- **Protocol**: MCP client for symbolic reasoning integration

**Core API Endpoints**

| Endpoint               | Method | Purpose                         |
| ---------------------- | ------ | ------------------------------- |
| `/health`              | GET    | Service health monitoring       |
| `/api/interpret_dream` | POST   | AI-powered dream interpretation |
| `/api/dreams`          | POST   | Save dream and interpretation   |
| `/api/dreams`          | GET    | List dreams with pagination     |
| `/api/dreams/:id`      | GET    | Retrieve specific dream         |

**Database Schema**

```sql
CREATE TABLE dreams (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  text TEXT NOT NULL,
  interpretation TEXT NOT NULL,
  symbols JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Full-text search index
CREATE INDEX dreams_text_search_idx ON dreams
USING gin(to_tsvector('english', text));
```

**AI Integration Architecture**

```rust
#[async_trait]
pub trait AiClientTrait {
    async fn interpret_dream(&self, text: &str, symbols: Vec<Symbol>) -> Result<String>;
    async fn extract_symbols(&self, text: &str) -> Result<Vec<String>>;
}

// Multi-provider implementation with fallback
pub struct MultiProviderAiClient {
    primary: Arc<dyn AiClientTrait>,
    fallback: Arc<dyn AiClientTrait>,
}
```

### Nexus Web (Frontend)

**Technology Stack**

- **Framework**: Leptos for reactive WebAssembly development
- **Compilation**: Rust to WebAssembly via trunk
- **Styling**: Custom CSS with responsive design patterns
- **Storage**: Browser localStorage for offline capabilities

**Component Architecture**

```rust
// Main application routes
#[component]
pub fn App() -> impl IntoView {
    Router(|cx| {
        Routes(cx, |cx| {
            Route(cx, "/", Home)
            Route(cx, "/interpret", DreamInterpreter)
            Route(cx, "/journal", Journal)
        })
    })
}
```

**Platform-Aware Configuration**

```rust
#[cfg(target_arch = "wasm32")]
fn get_api_base_url() -> String {
    // Runtime environment detection
    match web_sys::window()
        .and_then(|w| w.location().hostname().ok())
    {
        Some(hostname) if hostname.contains("localhost") =>
            "http://localhost:3003".to_string(),
        _ => "https://api.nexusflow.com".to_string(),
    }
}
```

**Offline-First Architecture**

```rust
// Local storage integration for offline functionality
pub async fn save_dream_locally(dream: &Dream) -> Result<()> {
    if let Some(storage) = web_sys::window()
        .and_then(|w| w.local_storage().ok())
        .flatten()
    {
        let dream_json = serde_json::to_string(dream)?;
        storage.set_item(&format!("dream_{}", dream.id), &dream_json)?;
    }
    Ok(())
}
```

### Symbol Ontology MCP Server

**Technology Stack**

- **Protocol**: Model Context Protocol (MCP) implementation
- **Transport**: Server-Sent Events (SSE) for real-time communication
- **Storage**: PostgreSQL for production, SQLite for development
- **Pattern**: Repository pattern for flexible storage backends

**Domain Models**

```rust
pub struct Symbol {
    pub id: String,
    pub name: String,
    pub category: String,
    pub description: String,
    pub interpretations: Vec<String>,
    pub related_symbols: Vec<String>,
}

pub struct SymbolSet {
    pub id: String,
    pub name: String,
    pub description: String,
    pub category: String,
    pub symbols: Vec<Symbol>,
}
```

**MCP Protocol Implementation**

```rust
// Core MCP methods
impl McpServer for SymbolOntologyServer {
    async fn get_symbols(&self, limit: Option<usize>) -> Result<Vec<Symbol>>;
    async fn search_symbols(&self, query: &str) -> Result<Vec<Symbol>>;
    async fn filter_by_category(&self, category: &str) -> Result<Vec<Symbol>>;
    async fn get_categories(&self) -> Result<Vec<String>>;
    async fn get_symbol_sets(&self) -> Result<Vec<SymbolSet>>;
}
```

## Design Principles and Patterns

### Trait-Based Architecture

Every major integration point uses traits for flexibility and testability:

```rust
// Dependency injection through traits
pub struct DreamService {
    ai_client: Arc<dyn AiClientTrait>,
    mcp_client: Arc<dyn McpClientTrait>,
    repository: Arc<dyn DreamRepository>,
}
```

### Error Handling Strategy

Comprehensive error handling with user-friendly messaging:

```rust
#[derive(Debug, thiserror::Error)]
pub enum AppError {
    #[error("AI service temporarily unavailable")]
    AiServiceUnavailable,

    #[error("Symbol lookup failed: {0}")]
    SymbolLookupFailed(String),

    #[error("Database operation failed")]
    DatabaseError(#[from] sqlx::Error),
}
```

### Configuration Management

Environment-based configuration for all services:

```rust
#[derive(Debug, Clone)]
pub struct Config {
    pub database_url: String,
    pub openrouter_api_key: Option<String>,
    pub github_token: Option<String>,
    pub mcp_server_url: Option<String>,
    pub enable_mcp: bool,
}
```

## Deployment Architecture

### Fly.io Platform Strategy

All services are deployed on Fly.io with automated containerization and deployment:

**Service Deployment**

- **Nexus Core**: Axum backend with Fly PostgreSQL database
- **Nexus Web**: Leptos WASM frontend served as static files
- **Symbol Ontology**: MCP server with Supabase database integration

**Database Architecture**

- **Dream Database**: Fly.io managed PostgreSQL for core application data
- **Symbol Ontology Database**: Supabase PostgreSQL for MCP symbol data

**Platform Benefits**

- Automated Docker builds and deployment via Fly.io
- Independent service scaling and geographic distribution
- Environment-specific configuration through fly.toml files
- Edge deployment capabilities for global performance

## Performance Characteristics

### Frontend Performance

- **WebAssembly Compilation**: Optimized builds with `opt-level = 'z'`
- **Bundle Size**: Selective feature inclusion for minimal payloads
- **Caching**: LocalStorage for offline functionality and performance
- **Responsive Loading**: Progressive enhancement with loading states

### Backend Performance

- **Async Architecture**: Tokio-based async throughout
- **Connection Pooling**: SQLx connection pools for database efficiency
- **Data Management**: Symbol lookup and storage optimization
- **AI Provider Fallbacks**: Multiple provider support for reliability

### Database Performance

- **Full-Text Search**: PostgreSQL native search capabilities
- **UUID Primary Keys**: Unique identifiers for distributed systems
- **JSONB Storage**: Flexible symbol metadata storage
- **Query Features**: Searches and pagination support

## Security Considerations

### API Security

- **Input Validation**: Request validation and error handling
- **Error Handling**: Clean error responses to users
- **CORS Configuration**: Cross-origin access configuration
- **Rate Limiting**: Protection against abuse (planned)

### Data Protection

- **Environment Variables**: No hardcoded secrets
- **Database Security**: Connection encryption and access controls
- **User Privacy**: No permanent user data storage without consent
- **AI Provider Security**: Secure API key handling and transmission

## Monitoring and Observability

### Logging Strategy

```rust
// Structured logging with correlation IDs
tracing::info!(
    dream_id = %dream.id,
    symbols_found = symbols.len(),
    "Dream interpretation completed"
);
```

### Health Monitoring

```rust
// Health check endpoints for each service
#[derive(Serialize)]
pub struct HealthStatus {
    status: String,
    timestamp: DateTime<Utc>,
    database: bool,
    ai_service: bool,
    mcp_service: bool,
}
```

## Architectural Lessons Learned

### What Worked Well

1. **Service Separation**: Clear boundaries simplified development and deployment
2. **Trait Abstractions**: Made testing and dependency injection straightforward
3. **Repository Pattern**: Enabled flexible storage backends for different environments
4. **MCP Integration**: Cutting-edge protocol integration demonstrated innovation

### What Would Be Done Differently

1. **Earlier API Versioning**: Plan for schema evolution from the start
2. **Better Monitoring**: Build observability in from day one
3. **Performance Baselines**: Establish performance metrics earlier in development
4. **Documentation Automation**: Generate API docs from code annotations

### Scalability Considerations

The current architecture provides potential scaling paths:

- **Horizontal Scaling**: Each service can be scaled independently
- **Database Partitioning**: Dreams could be partitioned if needed
- **Static Asset Distribution**: Frontend assets suitable for CDN serving

This architecture represents not just a working system, but a foundation for future growth and enhancement. The lessons learned from building it provide valuable insights for any complex system development.

---

_Next: Chapter 8 dives deep into the Rust and WebAssembly frontend development journey, including the specific challenges and solutions discovered._
