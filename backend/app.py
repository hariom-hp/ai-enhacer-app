from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
from PIL import Image
import os
from datetime import datetime
import cv2
import numpy as np
from werkzeug.utils import secure_filename

app = Flask(__name__)
CORS(app)

# Configuration
UPLOAD_FOLDER = 'uploads'
ENHANCED_FOLDER = 'enhanced'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}
MAX_CONTENT_LENGTH = 10 * 1024 * 1024  # 10MB limit

# Create necessary folders
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(ENHANCED_FOLDER, exist_ok=True)

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def enhance_image(image_path):
    try:
        # Read the image
        img = cv2.imread(image_path)
        if img is None:
            raise Exception("Failed to read image")
        
        # Convert to LAB color space
        lab = cv2.cvtColor(img, cv2.COLOR_BGR2LAB)
        
        # Split the LAB image into L, A, and B channels
        l, a, b = cv2.split(lab)
        
        # Apply CLAHE to L channel
        clahe = cv2.createCLAHE(clipLimit=3.0, tileGridSize=(8,8))
        cl = clahe.apply(l)
        
        # Merge the CLAHE enhanced L channel with original A and B channels
        limg = cv2.merge((cl,a,b))
        
        # Convert back to BGR color space
        enhanced = cv2.cvtColor(limg, cv2.COLOR_LAB2BGR)
        
        # Additional enhancements
        # Increase sharpness
        kernel = np.array([[-1,-1,-1],
                         [-1, 9,-1],
                         [-1,-1,-1]])
        enhanced = cv2.filter2D(enhanced, -1, kernel)
        
        # Adjust contrast and brightness
        alpha = 1.2  # Contrast control
        beta = 10    # Brightness control
        enhanced = cv2.convertScaleAbs(enhanced, alpha=alpha, beta=beta)
        
        return enhanced
    except Exception as e:
        raise Exception(f"Enhancement failed: {str(e)}")

@app.route('/enhance', methods=['POST'])
def enhance():
    try:
        # Check if file was uploaded
        if 'image' not in request.files:
            return jsonify({'error': 'No image file provided'}), 400
        
        file = request.files['image']
        
        # Check if file was selected
        if file.filename == '':
            return jsonify({'error': 'No selected file'}), 400
        
        # Check file extension
        if not allowed_file(file.filename):
            return jsonify({'error': 'Invalid file format. Allowed formats: PNG, JPG, JPEG'}), 415
        
        # Secure the filename
        filename = secure_filename(file.filename)
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        original_filename = f'original_{timestamp}_{filename}'
        enhanced_filename = f'enhanced_{timestamp}_{filename}'
        
        original_path = os.path.join(UPLOAD_FOLDER, original_filename)
        enhanced_path = os.path.join(ENHANCED_FOLDER, enhanced_filename)
        
        # Save original image
        file.save(original_path)
        
        # Enhance image
        enhanced_image = enhance_image(original_path)
        cv2.imwrite(enhanced_path, enhanced_image)
        
        # Return the URL for the enhanced image
        return jsonify({
            'enhanced_image_url': f'http://localhost:5000/enhanced/{enhanced_filename}',
            'message': 'Image enhanced successfully'
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/enhanced/<filename>')
def serve_enhanced_image(filename):
    """Serve enhanced images"""
    return send_from_directory(ENHANCED_FOLDER, filename)

@app.route('/health')
def health_check():
    """Health check endpoint"""
    return jsonify({'status': 'healthy', 'message': 'Service is running'}), 200

# Error handlers
@app.errorhandler(413)
def too_large(e):
    return jsonify({'error': 'File is too large. Maximum size is 10MB'}), 413

@app.errorhandler(500)
def server_error(e):
    return jsonify({'error': 'Internal server error'}), 500

@app.errorhandler(404)
def not_found(e):
    return jsonify({'error': 'Resource not found'}), 404

if __name__ == '__main__':
    # Configure maximum content length
    app.config['MAX_CONTENT_LENGTH'] = MAX_CONTENT_LENGTH
    
    # Run the app
    app.run(debug=True, host='0.0.0.0') 