# Nix flake for Timewave Jekyll website development and deployment
{
  description = "Timewave Jekyll website - development environment and build tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Ruby environment with bundler
        rubyEnv = pkgs.ruby_3_1;

        # Jekyll site builder script
        buildSite = pkgs.writeShellScriptBin "build-site" ''
          export PATH="${rubyEnv}/bin:${pkgs.bundler}/bin:$PATH"
          echo "Building Jekyll site..."
          bundle exec jekyll build --verbose
          echo "Site built successfully in _site/"
        '';

        # Jekyll development server script
        serveSite = pkgs.writeShellScriptBin "serve-site" ''
          export PATH="${rubyEnv}/bin:${pkgs.bundler}/bin:$PATH"
          echo "Starting Jekyll development server..."
          echo "Site will be available at http://localhost:4000"
          bundle exec jekyll serve --host 0.0.0.0 --port 4000
        '';

        # Bundle install script
        installDeps = pkgs.writeShellScriptBin "install-deps" ''
          export PATH="${rubyEnv}/bin:${pkgs.bundler}/bin:$PATH"
          echo "Installing Ruby dependencies with Bundler..."
          bundle install --verbose
          echo "Dependencies installed successfully"
        '';

        # Bundle update script
        updateDeps = pkgs.writeShellScriptBin "update-deps" ''
          export PATH="${rubyEnv}/bin:${pkgs.bundler}/bin:$PATH"
          echo "Updating Ruby dependencies with Bundler..."
          bundle update --verbose
          echo "Dependencies updated successfully"
        '';

        # Clean build artifacts script
        cleanSite = pkgs.writeShellScriptBin "clean-site" ''
          echo "Cleaning Jekyll build artifacts..."
          rm -rf _site .sass-cache .jekyll-cache .jekyll-metadata
          echo "Clean complete"
        '';

        # Preview deployment script (builds and shows deployment info)
        previewDeploy = pkgs.writeShellScriptBin "preview-deploy" ''
          export PATH="${rubyEnv}/bin:${pkgs.bundler}/bin:$PATH"
          echo "Building site for deployment preview..."
          ${buildSite}/bin/build-site
          echo ""
          echo "Deployment preview ready!"
          echo "Upload the contents of the '_site' directory to your static hosting provider."
          echo "Site contents:"
          ls -la _site/
        '';

        # Check site health script
        checkSite = pkgs.writeShellScriptBin "check-site" ''
          export PATH="${rubyEnv}/bin:${pkgs.bundler}/bin:$PATH"
          echo "Checking Jekyll site configuration and health..."
          bundle exec jekyll doctor
          echo "Site check complete"
        '';

        # New post creation script
        newPost = pkgs.writeShellScriptBin "new-post" ''
          if [ -z "$1" ]; then
            echo "Usage: new-post 'Post Title'"
            echo "Example: new-post 'My New Blog Post'"
            exit 1
          fi
          
          POST_TITLE="$1"
          POST_DATE=$(date +%Y-%m-%d)
          POST_DATETIME=$(date +"%Y-%m-%d %H:%M:%S %z")
          POST_SLUG=$(echo "$POST_TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
          POST_FILE="_posts/$POST_DATE-$POST_SLUG.md"
          
          cat > "$POST_FILE" << EOF
---
layout: post
title: "$POST_TITLE"
date: $POST_DATETIME
published: true
---

Write your post content here...

EOF
          
          echo "New post created: $POST_FILE"
          echo "Edit the file to add your content."
        '';

      in
      {
        # Development shell with all tools
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Ruby and Jekyll environment
            rubyEnv
            bundler
            
            # Build dependencies for native gems
            libffi
            pkg-config
            
            # Additional useful tools
            git
            curl
            
            # Our custom scripts
            buildSite
            serveSite
            installDeps
            updateDeps
            cleanSite
            previewDeploy
            checkSite
            newPost
          ];

          shellHook = ''
            echo "🌊 Timewave Jekyll Development Environment"
            echo ""
            echo "Available commands:"
            echo "  install-deps     - Install Ruby dependencies (bundle install)"
            echo "  update-deps      - Update Ruby dependencies (bundle update)"
            echo "  serve-site       - Start development server (jekyll serve)"
            echo "  build-site       - Build static site (jekyll build)"
            echo "  clean-site       - Clean build artifacts"
            echo "  preview-deploy   - Build site for deployment preview"
            echo "  check-site       - Check site health (jekyll doctor)"
            echo "  new-post 'title' - Create a new blog post"
            echo ""
            echo "Quick start:"
            echo "  1. install-deps"
            echo "  2. serve-site"
            echo ""
            
            # Ensure we're in the right directory
            if [ ! -f "_config.yml" ]; then
              echo "⚠️  Warning: _config.yml not found. Make sure you're in the Jekyll site root."
            fi
          '';
        };

        # Individual packages for CI/CD or standalone use
        packages = {
          inherit buildSite serveSite installDeps updateDeps cleanSite previewDeploy checkSite newPost;
          
          # Default package is the build script
          default = buildSite;
        };

        # Apps for easy nix run usage
        apps = {
          # nix run .#serve
          serve = flake-utils.lib.mkApp {
            drv = serveSite;
          };
          
          # nix run .#build  
          build = flake-utils.lib.mkApp {
            drv = buildSite;
          };
          
          # nix run .#install
          install = flake-utils.lib.mkApp {
            drv = installDeps;
          };
          
          # nix run .#clean
          clean = flake-utils.lib.mkApp {
            drv = cleanSite;
          };
          
          # nix run .#preview
          preview = flake-utils.lib.mkApp {
            drv = previewDeploy;
          };
          
          # nix run .#check
          check = flake-utils.lib.mkApp {
            drv = checkSite;
          };

          # Default app is serve for development
          default = flake-utils.lib.mkApp {
            drv = serveSite;
          };
        };
      });
} 