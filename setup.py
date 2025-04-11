import os
import sys
import subprocess
import platform

def check_python_version():
    """Check if Python version is 3.8 or higher."""
    if sys.version_info < (3, 8):
        print("Error: Python 3.8 or higher is required.")
        sys.exit(1)

def check_pip():
    """Check if pip is installed."""
    try:
        subprocess.run([sys.executable, "-m", "pip", "--version"], check=True, stdout=subprocess.PIPE)
    except subprocess.CalledProcessError:
        print("Error: pip is not installed. Please install pip first.")
        sys.exit(1)

def install_requirements():
    """Install the required Python packages."""
    print("Installing required Python packages...")
    subprocess.run([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"], check=True)

def download_clarity_weights():
    """Download the Clarity AI upscaler weights."""
    print("Downloading Clarity AI upscaler weights...")
    os.chdir("clarity-upscaler")
    subprocess.run([sys.executable, "download_weights.py"], check=True)
    os.chdir("..")

def setup_directories():
    """Create necessary directories for the API server."""
    print("Setting up directories...")
    os.makedirs("uploads", exist_ok=True)
    os.makedirs("results", exist_ok=True)

def main():
    """Main setup function."""
    print("Setting up Clarity AI Upscaler API Server...")
    
    # Check Python version
    check_python_version()
    
    # Check if pip is installed
    check_pip()
    
    # Install requirements
    install_requirements()
    
    # Check if clarity-upscaler directory exists
    if not os.path.exists("clarity-upscaler"):
        print("Error: clarity-upscaler directory not found. Please clone the repository first.")
        print("Run: git clone https://github.com/philz1337x/clarity-upscaler.git")
        sys.exit(1)
    
    # Download Clarity weights
    download_clarity_weights()
    
    # Setup directories
    setup_directories()
    
    print("\nSetup completed successfully!")
    print("\nTo start the API server, run:")
    print("python clarity_api_server.py")
    
    print("\nTo use the Flutter app, make sure to run:")
    print("flutter pub get")
    print("flutter run")

if __name__ == "__main__":
    main() 