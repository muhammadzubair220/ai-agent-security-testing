#!/usr/bin/env python3
"""
AI Agent Security Testing Framework
Main entry point for the security testing framework.
"""

import sys
import os
import argparse
from pathlib import Path

# Add project root to Python path
project_root = Path(__file__).parent
sys.path.insert(0, str(project_root))

from server.web_server import WebServer
from config.config import config

def main():
    """Main entry point for the application."""
    parser = argparse.ArgumentParser(
        description="AI Agent Security Testing Framework",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python main.py                    # Start server with default settings
  python main.py --port 9000        # Start server on port 9000
  python main.py --list-attacks     # List available attack variations
        """
    )
    
    parser.add_argument(
        "--port", "-p",
        type=int,
        default=config.server.port,
        help=f"Port to run the server on (default: {config.server.port})"
    )
    
    parser.add_argument(
        "--host",
        default=config.server.host,
        help=f"Host to bind the server to (default: {config.server.host})"
    )
    
    parser.add_argument(
        "--list-attacks", "-l",
        action="store_true",
        help="List available attack variations and exit"
    )
    
    parser.add_argument(
        "--debug",
        action="store_true",
        default=config.server.debug,
        help="Enable debug mode"
    )
    
    args = parser.parse_args()
    
    if args.list_attacks:
        print("Available Attack Variations:")
        print("=" * 50)
        for variation in config.get_all_variations():
            print(f"ID: {variation.variation_id}")
            print(f"Name: {variation.name}")
            print(f"Description: {variation.description}")
            print(f"Initial Prompt: {variation.initial_prompt}")
            print(f"Expected Outcome: {variation.expected_outcome}")
            print("-" * 30)
        return
    
    # Create necessary directories
    os.makedirs("evidence/screenshots", exist_ok=True)
    os.makedirs("evidence/logs", exist_ok=True)
    os.makedirs("evidence/reports", exist_ok=True)
    os.makedirs("evidence/videos", exist_ok=True)
    
    # Update config with command line arguments
    config.server.host = args.host
    config.server.port = args.port
    config.server.debug = args.debug
    
    print(f"AI Agent Security Testing Framework")
    print(f"Server starting on http://{args.host}:{args.port}")
    print(f"Available attack variations: {len(config.get_all_variations())}")
    print("Press Ctrl+C to stop the server")
    
    # Start the web server
    server = WebServer()
    try:
        server.start_server(port=args.port)
    except KeyboardInterrupt:
        print("\nServer stopped by user")
    except Exception as e:
        print(f"Error starting server: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()