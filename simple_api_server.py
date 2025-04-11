from flask import Flask, request, jsonify, send_file
import os
import uuid
from PIL import Image, ImageEnhance, ImageFilter
import io

app = Flask(__name__)

# Configuration
UPLOAD_FOLDER = 'uploads'
RESULT_FOLDER = 'results'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(RESULT_FOLDER, exist_ok=True)

@app.route('/enhance', methods=['POST'])
def enhance_image():
    if 'image' not in request.files:
        return jsonify({'error': 'No image provided'}), 400
    
    file = request.files['image']
    
    # Validate file extension
    filename = file.filename
    if not filename or '.' not in filename:
        return jsonify({'error': 'Invalid filename'}), 400
    
    extension = filename.rsplit('.', 1)[1].lower()
    if extension not in ['jpg', 'jpeg', 'png']:
        return jsonify({'error': 'Unsupported image format. Please use JPG or PNG files.'}), 415
    
    try:
        # Get parameters from request
        scale_factor = float(request.form.get('scale_factor', '2'))
        creativity = float(request.form.get('creativity', '0.35'))
        resemblance = float(request.form.get('resemblance', '0.6'))
        
        # Save the uploaded file with a unique ID
        unique_id = str(uuid.uuid4())
        input_path = os.path.join(UPLOAD_FOLDER, f"{unique_id}.{extension}")
        output_path = os.path.join(RESULT_FOLDER, f"{unique_id}_enhanced.png")
        
        # Save the uploaded image
        img = Image.open(file)
        img.save(input_path)
        
        # Simulate enhancement process
        # 1. Resize the image based on scale factor
        width, height = img.size
        new_width = int(width * scale_factor)
        new_height = int(height * scale_factor)
        enhanced_img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
        
        # 2. Apply some enhancements based on creativity and resemblance
        # Higher creativity means more contrast and saturation
        contrast_enhancer = ImageEnhance.Contrast(enhanced_img)
        enhanced_img = contrast_enhancer.enhance(1.0 + creativity * 0.5)
        
        # Higher resemblance means more sharpness
        enhanced_img = enhanced_img.filter(ImageFilter.UnsharpMask(radius=2, percent=int(resemblance * 100), threshold=3))
        
        # Save the enhanced image
        enhanced_img.save(output_path, format='PNG')
        
        # Return the URL to the enhanced image
        host_url = request.host_url.rstrip('/')
        enhanced_image_url = f"{host_url}/results/{os.path.basename(output_path)}"
        
        return jsonify({
            'enhanced_image_url': enhanced_image_url,
            'message': 'Image enhanced successfully',
            'parameters': {
                'scale_factor': scale_factor,
                'creativity': creativity,
                'resemblance': resemblance
            }
        })
    
    except Exception as e:
        return jsonify({'error': f'An error occurred: {str(e)}'}), 500

@app.route('/results/<filename>', methods=['GET'])
def get_result(filename):
    return send_file(os.path.join(RESULT_FOLDER, filename))

if __name__ == '__main__':
    print("Starting API server on http://localhost:5000")
    print("You can test the API with your Flutter app")
    app.run(host='0.0.0.0', port=5000, debug=True) 