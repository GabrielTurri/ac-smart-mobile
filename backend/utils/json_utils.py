from bson import ObjectId
from datetime import datetime

def serialize_mongo_doc(doc):
    """
    Convert MongoDB document to JSON serializable dictionary
    
    Args:
        doc: MongoDB document or dictionary containing MongoDB types
        
    Returns:
        dict: JSON serializable dictionary
    """
    if doc is None:
        return None
        
    if isinstance(doc, list):
        return [serialize_mongo_doc(item) for item in doc]
        
    if not isinstance(doc, dict):
        return doc
        
    result = {}
    for key, value in doc.items():
        if isinstance(value, ObjectId):
            # Convert ObjectId to string
            result[key] = str(value)
        elif isinstance(value, datetime):
            # Convert datetime to ISO format string
            result[key] = value.isoformat()
        elif isinstance(value, dict):
            # Recursively convert nested dictionaries
            result[key] = serialize_mongo_doc(value)
        elif isinstance(value, list):
            # Recursively convert items in lists
            result[key] = [serialize_mongo_doc(item) for item in value]
        else:
            # Keep other types as is
            result[key] = value
            
    return result
