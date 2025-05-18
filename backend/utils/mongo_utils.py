from bson import ObjectId
from datetime import datetime
import json
from flask import Response

def json_response(data, status_code=200):
    """
    Convert MongoDB documents to JSON serializable format and return a Flask response
    
    Args:
        data: Data to be serialized (can contain MongoDB types like ObjectId)
        status_code: HTTP status code for the response
        
    Returns:
        Flask Response object with properly serialized JSON
    """
    class MongoJSONEncoder(json.JSONEncoder):
        def default(self, obj):
            if isinstance(obj, ObjectId):
                return str(obj)
            if isinstance(obj, datetime):
                return obj.isoformat()
            return super(MongoJSONEncoder, self).default(obj)
    
    # Serialize the data to JSON using our custom encoder
    json_data = json.dumps(data, cls=MongoJSONEncoder)
    
    # Create and return a Flask response
    return Response(json_data, mimetype='application/json', status=status_code)
