import requests
import os
from PIL import Image
import io
import webbrowser
import time

def test_api():
    print("Testing the API server...")
    
    # Check if the test image exists, if not create a simple one
    test_image_path = "test_image.jpg"
    if not os.path.exists(test_image_path):
        print("Creating a test image...")
        img = Image.new('RGB', (300, 200), color=(73, 109, 137))
        img.save(test_image_path)
    
    # Prepare the API request
    url = "http://localhost:5000/enhance"
    
    # Open the image file
    with open(test_image_path, "rb") as f:
        files = {"image": (test_image_path, f, "image/jpeg")}
        
        # Add parameters
        data = {
            "scale_factor": "2.0",
            "creativity": "0.5",
            "resemblance": "0.8"
        }
        
        print("Sending request to API server...")
        try:
            response = requests.post(url, files=files, data=data)
            
            if response.status_code == 200:
                result = response.json()
                enhanced_image_url = result["enhanced_image_url"]
                print(f"Image enhanced successfully!")
                print(f"Enhanced image URL: {enhanced_image_url}")
                
                # Open the enhanced image in a web browser
                print("Opening the enhanced image in your web browser...")
                webbrowser.open(enhanced_image_url)
                
                return True
            else:
                print(f"Error: {response.status_code}")
                print(response.text)
                return False
        except requests.exceptions.ConnectionError:
            print("Error: Could not connect to the API server. Make sure it's running on http://localhost:5000")
            return False
        except Exception as e:
            print(f"Error: {str(e)}")
            return False

if __name__ == "__main__":
    # Wait a moment for the server to start
    time.sleep(2)
    test_api() 