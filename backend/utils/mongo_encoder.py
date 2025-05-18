from bson import ObjectId
from datetime import datetime
import json
from flask import json as flask_json

class MongoJSONEncoder(json.JSONEncoder):
    """
    Custom JSON encoder that can handle MongoDB ObjectId and datetime objects
    """
    def default(self, obj):
        if isinstance(obj, ObjectId):
            return str(obj)
        if isinstance(obj, datetime):
            return obj.isoformat()
        return super(MongoJSONEncoder, self).default(obj)
