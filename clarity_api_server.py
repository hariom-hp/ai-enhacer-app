from flask import Flask, request, jsonify, send_file
import os
import sys
import subprocess
import uuid
import tempfile
from PIL import Image
import io
import base64

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
    
    # Check file size
    file_content = file.read()
    if len(file_content) > 10 * 1024 * 1024:  # 10MB limit
        return jsonify({'error': 'Image size too large. Please choose a smaller image.'}), 413
    
    # Save the uploaded file
    unique_id = str(uuid.uuid4())
    input_path = os.path.join(UPLOAD_FOLDER, f"{unique_id}.{extension}")
    output_path = os.path.join(RESULT_FOLDER, f"{unique_id}_enhanced.png")
    
    with open(input_path, 'wb') as f:
        f.write(file_content)
    
    try:
        # Get parameters from request
        scale_factor = request.form.get('scale_factor', '2')
        creativity = request.form.get('creativity', '0.35')
        resemblance = request.form.get('resemblance', '0.6')
        
        # Run the Clarity upscaler
        clarity_dir = os.path.join(os.getcwd(), 'clarity-upscaler')
        
        # Change to the Clarity directory
        os.chdir(clarity_dir)
        
        # Run the prediction
        cmd = [
            'python', '-m', 'cog.server.http', 'predict', 
            '-i', f'image=@{os.path.abspath(input_path)}',
            '-i', f'scale_factor={scale_factor}',
            '-i', f'creativity={creativity}',
            '-i', f'resemblance={resemblance}'
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        # Change back to original directory
        os.chdir(os.path.dirname(clarity_dir))
        
        if result.returncode != 0:
            return jsonify({'error': f'Upscaling failed: {result.stderr}'}), 500
        
        # Parse the output to get the enhanced image path
        output_lines = result.stdout.strip().split('\n')
        enhanced_image_path = None
        
        for line in output_lines:
            if line.startswith('output:'):
                enhanced_image_path = line.split(':', 1)[1].strip()
                break
        
        if not enhanced_image_path or not os.path.exists(enhanced_image_path):
            return jsonify({'error': 'Failed to get enhanced image'}), 500
        
        # Copy the enhanced image to our results folder
        img = Image.open(enhanced_image_path)
        img.save(output_path)
        
        # Return the URL to the enhanced image
        host_url = request.host_url.rstrip('/')
        enhanced_image_url = f"{host_url}/results/{os.path.basename(output_path)}"
        
        return jsonify({
            'enhanced_image_url': enhanced_image_url,
            'message': 'Image enhanced successfully'
        })
    
    except Exception as e:
        return jsonify({'error': f'An error occurred: {str(e)}'}), 500
    
    finally:
        # Clean up the input file
        if os.path.exists(input_path):
            os.remove(input_path)

@app.route('/results/<filename>', methods=['GET'])
def get_result(filename):
    return send_file(os.path.join(RESULT_FOLDER, filename))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True) 