import os
import logging
from logging.handlers import RotatingFileHandler
import sys

def configure_logging(app):
    """
    Configure logging for the Flask application
    
    Args:
        app: Flask application instance
    """
    # Ensure log directory exists
    log_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'logs')
    os.makedirs(log_dir, exist_ok=True)
    
    # Set up formatter
    formatter = logging.Formatter(
        '[%(asctime)s] %(levelname)s in %(module)s: %(message)s'
    )
    
    # Configure file handler for all logs
    file_handler = RotatingFileHandler(
        os.path.join(log_dir, 'app.log'),
        maxBytes=10485760,  # 10MB
        backupCount=10
    )
    file_handler.setFormatter(formatter)
    file_handler.setLevel(logging.INFO)
    
    # Configure stderr handler
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(formatter)
    console_handler.setLevel(logging.INFO)
    
    # Configure specific request logger
    request_file_handler = RotatingFileHandler(
        os.path.join(log_dir, 'requests.log'),
        maxBytes=10485760,  # 10MB
        backupCount=10
    )
    request_file_handler.setFormatter(formatter)
    
    # Get the Flask logger
    app.logger.handlers = []
    app.logger.propagate = False
    app.logger.setLevel(logging.INFO)
    app.logger.addHandler(file_handler)
    app.logger.addHandler(console_handler)
    
    # Create a request logger
    request_logger = logging.getLogger('request_logger')
    request_logger.setLevel(logging.INFO)
    request_logger.addHandler(request_file_handler)
    request_logger.addHandler(console_handler)
    
    return request_logger
