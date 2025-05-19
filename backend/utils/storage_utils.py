import os
import boto3
from botocore.exceptions import ClientError
import logging
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configure logging
logger = logging.getLogger(__name__)

class StorageManager:
    """
    Utility class for managing file storage operations with Hetzner Storage Box
    """
    def __init__(self):
        self.endpoint_url = os.getenv('HETZNER_ENDPOINT_URL')
        self.access_key = os.getenv('HETZNER_ACCESS_KEY')
        self.secret_key = os.getenv('HETZNER_SECRET_KEY')
        self.bucket_name = os.getenv('HETZNER_BUCKET_NAME')
        
        # Initialize the S3 client
        self.s3_client = boto3.client(
            's3',
            endpoint_url=self.endpoint_url,
            aws_access_key_id=self.access_key,
            aws_secret_access_key=self.secret_key
        )
    
    def upload_file(self, file_data, object_name, content_type=None):
        """
        Upload a file to the storage bucket
        
        Args:
            file_data (bytes): Binary data of the file
            object_name (str): Name to give the object in the bucket
            content_type (str, optional): MIME type of the file
            
        Returns:
            str: Public URL of the uploaded file or None if upload failed
        """
        try:
            # Set up extra arguments for the upload
            extra_args = {}
            if content_type:
                extra_args['ContentType'] = content_type
            
            # Upload the file
            self.s3_client.put_object(
                Bucket=self.bucket_name,
                Key=object_name,
                Body=file_data,
                **extra_args
            )
            
            # Generate the URL for the uploaded file
            url = f"{self.endpoint_url}/{self.bucket_name}/{object_name}"
            return url
        
        except ClientError as e:
            logger.error(f"Error uploading file to Hetzner Storage: {e}")
            return None
    
    def download_file(self, object_name):
        """
        Download a file from the storage bucket
        
        Args:
            object_name (str): Name of the object in the bucket
            
        Returns:
            tuple: (file_data, content_type) or (None, None) if download failed
        """
        try:
            response = self.s3_client.get_object(
                Bucket=self.bucket_name,
                Key=object_name
            )
            
            # Get the file data and content type
            file_data = response['Body'].read()
            content_type = response.get('ContentType')
            
            return file_data, content_type
        
        except ClientError as e:
            logger.error(f"Error downloading file from Hetzner Storage: {e}")
            return None, None
    
    def delete_file(self, object_name):
        """
        Delete a file from the storage bucket
        
        Args:
            object_name (str): Name of the object in the bucket
            
        Returns:
            bool: True if deletion was successful, False otherwise
        """
        try:
            self.s3_client.delete_object(
                Bucket=self.bucket_name,
                Key=object_name
            )
            return True
        
        except ClientError as e:
            logger.error(f"Error deleting file from Hetzner Storage: {e}")
            return False
