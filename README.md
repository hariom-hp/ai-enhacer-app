# Clarity AI Upscaler API Server

This is a simple Flask API server that integrates with the Clarity AI upscaler to enhance images.

## Prerequisites

- Python 3.8 or higher
- pip (Python package manager)
- Git

## Setup

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/clarity-upscaler-api.git
   cd clarity-upscaler-api
   ```

2. Install the required Python packages:
   ```
   pip install -r requirements.txt
   ```

3. Download the Clarity AI upscaler weights:
   ```
   cd clarity-upscaler
   python download_weights.py
   cd ..
   ```

## Running the API Server

Start the API server:
```
python clarity_api_server.py
```

The server will run on `http://localhost:5000`.

## API Endpoints

### Enhance Image

**URL**: `/enhance`

**Method**: `POST`

**Content-Type**: `multipart/form-data`

**Form Parameters**:
- `image`: The image file to enhance (JPG or PNG)
- `scale_factor` (optional): Scale factor for upscaling (default: 2)
- `creativity` (optional): Creativity level (default: 0.35)
- `resemblance` (optional): Resemblance level (default: 0.6)

**Response**:
```json
{
  "enhanced_image_url": "http://localhost:5000/results/uuid_enhanced.png",
  "message": "Image enhanced successfully"
}
```

**Error Responses**:
- 400: No image provided or invalid filename
- 413: Image size too large
- 415: Unsupported image format
- 500: Server error

### Get Enhanced Image

**URL**: `/results/<filename>`

**Method**: `GET`

**Response**: The enhanced image file

## Integration with Flutter

See the Flutter app code for how to integrate with this API server.
