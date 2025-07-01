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
          
          # Run Jekyll build and capture exit status
          if ! bundle exec jekyll build --verbose; then
            echo "Error: Jekyll build failed!"
            echo "Please check the error messages above and fix any issues."
            exit 1
          fi
          
          # Verify that the output directory exists
          if [ ! -d "_site" ]; then
            echo "Error: Expected output directory '_site' was not created!"
            echo "The Jekyll build may have failed silently."
            exit 1
          fi
          
          # Verify that the output directory is not empty
          if [ -z "$(ls -A _site 2>/dev/null)" ]; then
            echo "Error: Output directory '_site' exists but is empty!"
            echo "The Jekyll build may not have generated any files."
            exit 1
          fi
          
          echo "Site built successfully in _site/"
          echo "Generated files:"
          ls -la _site/ | head -10
          if [ $(ls -1 _site/ | wc -l) -gt 10 ]; then
            echo "   ... and $(( $(ls -1 _site/ | wc -l) - 10 )) more files"
          fi
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
        newPost = pkgs.writeShellScriptBin "new-post" (''
          export PATH="${pkgs.gnused}/bin:$PATH"
          set -euo pipefail
          
          # Input validation
          if [ $# -eq 0 ] || [ -z "$1" ]; then
            echo "Error: Post title is required"
            echo "Usage: new-post 'Post Title'"
            echo "Example: new-post 'My New Blog Post'"
            exit 1
          fi
          
          POST_TITLE="$1"
          
          # Validate title is not just whitespace
          if [ -z "$(echo "$POST_TITLE" | tr -d '[:space:]')" ]; then
            echo "Error: Post title cannot be empty or contain only whitespace"
            echo "Please provide a meaningful title"
            exit 1
          fi
          
          # Check title length (reasonable limits)
          if [ ''${#POST_TITLE} -gt 200 ]; then
            echo "Error: Post title is too long (maximum 200 characters)"
            echo "Current length: ''${#POST_TITLE} characters"
            exit 1
          fi
          
          # Generate slug using tr commands to avoid sed escaping issues
          POST_SLUG=$(echo "$POST_TITLE" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9' '-' | tr -s '-' | sed 's/^-*//' | sed 's/-*$//')
          
          if [ -z "$POST_SLUG" ]; then
            echo "Error: Post title contains no valid characters for URL slug"
            echo "Title must contain at least one alphanumeric character"
            echo "Invalid title: '$POST_TITLE'"
            exit 1
          fi
          
          # Validate slug length
          if [ ''${#POST_SLUG} -gt 100 ]; then
            echo "Error: Generated URL slug is too long (maximum 100 characters)"
            echo "Generated slug: '$POST_SLUG'"
            echo "Please use a shorter title"
            exit 1
          fi
          
          # Generate date and filename
          POST_DATE=$(date +%Y-%m-%d 2>/dev/null)
          if [ $? -ne 0 ]; then
            echo "Error: Failed to generate date"
            exit 1
          fi
          
          POST_DATETIME=$(date +"%Y-%m-%d %H:%M:%S %z" 2>/dev/null)
          if [ $? -ne 0 ]; then
            echo "Error: Failed to generate datetime"
            exit 1
          fi
          
          POST_FILE="_posts/$POST_DATE-$POST_SLUG.md"
          
          # Check if _posts directory exists, create if needed
          if [ ! -d "_posts" ]; then
            echo "Creating _posts directory..."
            if ! mkdir -p "_posts"; then
              echo "Error: Failed to create _posts directory"
              echo "Please check write permissions in the current directory"
              exit 1
            fi
          fi
          
          # Check if file already exists
          if [ -f "$POST_FILE" ]; then
            echo "Error: Post file already exists: $POST_FILE"
            echo "Please choose a different title or delete the existing file"
            exit 1
          fi
          
          # Escape special characters for YAML frontmatter (only escape quotes and backslashes)
          POST_TITLE_ESCAPED=$(printf '%s\n' "$POST_TITLE" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')
          
          # Attempt to create the post file
          if ! cat > "$POST_FILE" << EOF
---
layout: post
title: "$POST_TITLE_ESCAPED"
date: $POST_DATETIME
published: true
---

Write your post content here...

EOF
          then
            echo "Error: Failed to create post file: $POST_FILE"
            echo "Please check write permissions and available disk space"
            exit 1
          fi
          
          # Verify the file was created successfully
          if [ ! -f "$POST_FILE" ]; then
            echo "Error: Post file was not created successfully"
            exit 1
          fi
          
          # Check if file has content
          if [ ! -s "$POST_FILE" ]; then
            echo "Error: Post file was created but is empty"
            rm -f "$POST_FILE"
            exit 1
          fi
          
          echo "Success: New post created: $POST_FILE"
          echo "Generated slug: $POST_SLUG"
          echo "Edit the file to add your content."
        '');

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
            echo "Timewave Jekyll Development Environment"
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
              echo "Warning: _config.yml not found. Make sure you're in the Jekyll site root."
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