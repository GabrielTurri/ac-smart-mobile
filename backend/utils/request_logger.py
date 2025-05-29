import time
import json
import logging
from flask import request, g

class RequestLoggerMiddleware:
    """
    Middleware to log all requests and responses
    """
    def __init__(self, app, request_logger):
        self.app = app
        self.request_logger = request_logger

    def __call__(self, environ, start_response):
        # Start timer for request processing time
        request_start_time = time.time()
        
        # Store the original start_response function
        original_start_response = start_response
        
        # Create a list to store the response status
        response_status = [None]
        response_headers = [None]
        
        # Override start_response to capture status and headers
        def custom_start_response(status, headers, exc_info=None):
            response_status[0] = status
            response_headers[0] = headers
            return original_start_response(status, headers, exc_info)
        
        # Process the request
        response = self.app(environ, custom_start_response)
        
        # Calculate request processing time
        request_duration = time.time() - request_start_time
        
        # Log the request details
        self._log_request(environ, response_status[0], request_duration)
        
        # Return the response
        return response
    
    def _log_request(self, environ, status, duration):
        """
        Log request details
        """
        # Extract request information
        request_method = environ.get('REQUEST_METHOD', '-')
        path = environ.get('PATH_INFO', '-')
        query_string = environ.get('QUERY_STRING', '')
        if query_string:
            path = f"{path}?{query_string}"
            
        remote_addr = environ.get('REMOTE_ADDR', '-')
        user_agent = environ.get('HTTP_USER_AGENT', '-')
        
        # Format log message
        log_data = {
            'remote_addr': remote_addr,
            'method': request_method,
            'path': path,
            'status': status,
            'duration': f"{duration:.6f}s",
            'user_agent': user_agent
        }
        
        # Log as JSON for easier parsing
        self.request_logger.info(json.dumps(log_data))


def init_request_logger(app, request_logger):
    """
    Initialize the request logger middleware
    
    Args:
        app: Flask application instance
        request_logger: Logger instance for requests
    """
    app.wsgi_app = RequestLoggerMiddleware(app.wsgi_app, request_logger)
    
    # Add before_request handler to log request body when appropriate
    @app.before_request
    def log_request_body():
        # Skip logging for large requests or file uploads
        content_length = request.content_length or 0
        content_type = request.headers.get('Content-Type', '')
        
        # Only log JSON request bodies and not too large
        if (content_length < 10000 and 
            request.method in ['POST', 'PUT', 'PATCH'] and 
            'application/json' in content_type):
            try:
                body = request.get_json(silent=True)
                if body:
                    # Mask sensitive data if needed
                    if 'password' in body:
                        body['password'] = '******'
                    if 'token' in body:
                        body['token'] = '******'
                    
                    request_logger.info(f"Request Body: {json.dumps(body)}")
            except Exception as e:
                request_logger.error(f"Error logging request body: {str(e)}")
        
        # Store start time for response timing
        g.start_time = time.time()
    
    # Add after_request handler to log response
    @app.after_request
    def log_response(response):
        # Calculate duration
        duration = time.time() - getattr(g, 'start_time', time.time())
        
        # Log response info
        log_data = {
            'status_code': response.status_code,
            'response_time': f"{duration:.6f}s",
            'content_length': response.content_length,
            'content_type': response.content_type
        }
        
        # Log response body for JSON responses (if not too large)
        if (response.content_length and 
            response.content_length < 10000 and 
            response.content_type and 
            'application/json' in response.content_type):
            try:
                # Get response data as string
                response_data = response.get_data(as_text=True)
                # Try to parse as JSON
                json_data = json.loads(response_data)
                # Mask sensitive data if needed
                if isinstance(json_data, dict):
                    if 'token' in json_data:
                        json_data['token'] = '******'
                    if 'password' in json_data:
                        json_data['password'] = '******'
                
                log_data['response_body'] = json_data
            except Exception as e:
                request_logger.error(f"Error logging response body: {str(e)}")
        
        request_logger.info(f"Response: {json.dumps(log_data)}")
        return response
