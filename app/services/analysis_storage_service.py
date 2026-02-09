"""
Analysis Storage Service for TrustLens (Imagine Cup)

This service stores analysis results in Azure Cosmos DB using cryptographic hashes.

    Privacy & Responsible AI Design:
    - Only hash values are stored as document IDs; no raw images or text are persisted.
    - This approach protects user privacy by ensuring that raw sensitive content never leaves the ephemeral memory of the server for long-term storage.
    - By using cryptographic hashes (SHA-256), we can detect duplicates without knowing the original content.
    - We do not infer location, authorship, or personally identifiable information, adhering to Imagine Cup ethical standards.

"""

from datetime import datetime, timezone
from azure.cosmos import CosmosClient, PartitionKey, exceptions
from app.config.settings import Config


_cosmos_client = None
_container = None


def _get_container():
    """
    Lazily initialize and return the Cosmos DB container.
    Uses hash as the partition key for efficient lookups.
    """
    global _cosmos_client, _container
    
    if _container is not None:
        return _container
    
    if not Config.COSMOS_ENDPOINT or not Config.COSMOS_KEY:
        print("⚠️ Cosmos DB credentials not configured. Storage disabled.")
        return None
    
    try:
        _cosmos_client = CosmosClient(Config.COSMOS_ENDPOINT, Config.COSMOS_KEY)
        
        database = _cosmos_client.create_database_if_not_exists(id=Config.COSMOS_DATABASE)
        
        _container = database.create_container_if_not_exists(
            id=Config.COSMOS_CONTAINER,
            partition_key=PartitionKey(path="/hash")
        )
        
        print(f"✅ Connected to Cosmos DB: {Config.COSMOS_DATABASE}/{Config.COSMOS_CONTAINER}")
        return _container
    except Exception as e:
        print(f"❌ Cosmos DB connection failed: {str(e)}")
        return None


def store_analysis(hash_value: str, data_type: str, analysis_result: dict) -> dict:
    """
    Store an analysis result in Cosmos DB.
    
    Args:
        hash_value: SHA-256 hash of the content (used as document id and partition key)
        data_type: "image" or "text"
        analysis_result: The analysis result object (no raw content)
    
    Returns:
        The stored document or error info
    
    Privacy Note: Only the hash is stored as the identifier.
    Raw user content is never persisted to protect privacy.
    """
    container = _get_container()
    if container is None:
        return {"success": False, "error": "Cosmos DB not configured"}
    
    document = {
        "id": hash_value,
        "hash": hash_value,
        "type": data_type,
        "analysis": analysis_result,
        "createdAt": datetime.now(timezone.utc).isoformat()
    }
    
    try:
        container.upsert_item(document)
        print(f"✅ Stored analysis for hash: {hash_value[:16]}...")
        return {"success": True, "document": document}
    except exceptions.CosmosHttpResponseError as e:
        print(f"❌ Failed to store analysis: {str(e)}")
        return {"success": False, "error": str(e)}


def get_analysis_by_hash(hash_value: str) -> dict:
    """
    Retrieve a previously stored analysis by its hash.
    
    Args:
        hash_value: SHA-256 hash of the content
    
    Returns:
        The stored document if found, None otherwise
    
    This enables efficient deduplication: if we've seen this content before,
    we return the cached analysis instead of re-processing.
    """
    container = _get_container()
    if container is None:
        return None
    
    try:
        item = container.read_item(item=hash_value, partition_key=hash_value)
        print(f"✅ Found existing analysis for hash: {hash_value[:16]}...")
        return item
    except exceptions.CosmosResourceNotFoundError:
        return None
    except exceptions.CosmosHttpResponseError as e:
        print(f"⚠️ Error retrieving analysis: {str(e)}")
        return None
