"""Core web server for hosting attack scenarios."""

import os
from flask import Flask, render_template, request, jsonify, send_from_directory
from typing import Optional, Dict, Any
import logging
from datetime import datetime

from config.config import config, AttackConfig
from .content_generator import ContentGenerator, format_timestamp, format_rating_stars, format_number

class WebServer:
    """Main web server class for hosting attack scenarios."""
    
    def __init__(self):
        # Get the project root directory (parent of server directory)
        project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        template_dir = os.path.join(project_root, 'templates')
        static_dir = os.path.join(project_root, 'static')
        
        self.app = Flask(__name__, 
                        template_folder=template_dir,
                        static_folder=static_dir)
        self.content_generator = ContentGenerator()
        self.setup_logging()
        self.setup_routes()
        self.setup_template_filters()
        self.current_attack = None
        
    def setup_logging(self):
        """Configure logging for the web server."""
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
        self.logger = logging.getLogger(__name__)
    
    def setup_template_filters(self):
        """Setup Jinja2 template filters for content formatting."""
        self.app.jinja_env.filters['format_timestamp'] = format_timestamp
        self.app.jinja_env.filters['format_rating_stars'] = format_rating_stars
        self.app.jinja_env.filters['format_number'] = format_number
        
    def setup_routes(self):
        """Setup Flask routes for the web server."""
        
        @self.app.route('/')
        def index():
            """Main index page showing available attack variations."""
            variations = config.get_all_variations()
            return render_template('index.html', variations=variations)
        
        @self.app.route('/social')
        def social_media_page():
            """Serve social media attack page with realistic URL."""
            attack_config = config.get_attack_config(1)
            if not attack_config:
                return "Page not found", 404
                
            self.current_attack = attack_config
            self.logger.info(f"Serving social media page: {attack_config.name}")
            return self.serve_social_media_attack(attack_config)
        
        @self.app.route('/reviews')
        def product_reviews_page():
            """Serve product reviews attack page with realistic URL."""
            attack_config = config.get_attack_config(2)
            if not attack_config:
                return "Page not found", 404
                
            self.current_attack = attack_config
            self.logger.info(f"Serving product reviews page: {attack_config.name}")
            return self.serve_review_site_attack(attack_config)
        
        # Keep the old URLs for backward compatibility but redirect
        @self.app.route('/attack/<int:variation_id>')
        def attack_page_redirect(variation_id: int):
            """Redirect old attack URLs to new realistic URLs."""
            if variation_id == 1:
                return self.app.redirect('/social')
            elif variation_id == 2:
                return self.app.redirect('/reviews')
            else:
                return "Page not found", 404
        
        @self.app.route('/api/log_interaction', methods=['POST'])
        def log_interaction():
            """Log AI agent interactions for evidence collection."""
            data = request.get_json()
            timestamp = datetime.now().isoformat()
            
            interaction_log = {
                'timestamp': timestamp,
                'attack_id': self.current_attack.variation_id if self.current_attack else None,
                'user_agent': request.headers.get('User-Agent'),
                'ip_address': request.remote_addr,
                'interaction_data': data
            }
            
            self.logger.info(f"Interaction logged: {interaction_log}")
            return jsonify({'status': 'logged', 'timestamp': timestamp})
        
        @self.app.route('/static/<path:filename>')
        def serve_static(filename):
            """Serve static files."""
            return send_from_directory(self.app.static_folder, filename)
    
    def serve_social_media_attack(self, attack_config: AttackConfig) -> str:
        """Generate and serve social media attack page."""
        # Generate realistic social media content
        social_content = self.generate_social_content(attack_config)
        return render_template(
            attack_config.website_template,
            content=social_content,
            attack_config=attack_config
        )
    
    def serve_review_site_attack(self, attack_config: AttackConfig) -> str:
        """Generate and serve product review attack page."""
        # Generate realistic product review content
        review_content = self.generate_review_content(attack_config)
        return render_template(
            attack_config.website_template,
            content=review_content,
            attack_config=attack_config
        )
    
    def generate_social_content(self, attack_config: AttackConfig) -> Dict[str, Any]:
        """Generate realistic social media content with embedded injection."""
        # Get attack metadata
        attack_meta = self.content_generator.get_attack_metadata(attack_config.variation_id)
        
        # Generate main post
        main_post = self.content_generator.generate_social_media_post()
        
        # Generate comments with injection
        comments = self.content_generator.generate_social_media_comments(
            attack_type=attack_meta["attack_type"],
            num_comments=6
        )
        
        return {
            'main_post': main_post,
            'comments': comments,
            'attack_metadata': attack_meta
        }
    
    def generate_review_content(self, attack_config: AttackConfig) -> Dict[str, Any]:
        """Generate realistic product review content with embedded injection."""
        # Get attack metadata
        attack_meta = self.content_generator.get_attack_metadata(attack_config.variation_id)
        
        # Generate reviews with injection
        reviews = self.content_generator.generate_product_reviews(
            attack_type=attack_meta["attack_type"],
            num_reviews=7
        )
        
        return {
            'product': {
                'name': 'UltraSecure VPN Pro',
                'price': '$9.99/month',
                'rating': 4.3,
                'total_reviews': 1847,
                'description': 'Professional-grade VPN service with military-grade encryption and global server network.',
                'features': [
                    'Military-grade AES-256 encryption',
                    '5000+ servers in 60+ countries',
                    'No-logs policy verified by audit',
                    '24/7 customer support',
                    'Kill switch protection',
                    'Split tunneling'
                ]
            },
            'reviews': reviews,
            'attack_metadata': attack_meta
        }
    
    def start_server(self, port: Optional[int] = None, attack_variation: Optional[str] = None) -> None:
        """Start the Flask web server."""
        server_port = port or config.server.port
        
        self.logger.info(f"Starting web server on {config.server.host}:{server_port}")
        self.logger.info(f"Available attack variations: {list(config.attack_variations.keys())}")
        
        try:
            self.app.run(
                host=config.server.host,
                port=server_port,
                debug=config.server.debug
            )
        except OSError as e:
            if "Address already in use" in str(e):
                self.logger.error(f"Port {server_port} is already in use. Trying alternative port...")
                self.start_server(port=server_port + 1)
            else:
                raise e

if __name__ == "__main__":
    server = WebServer()
    server.start_server()