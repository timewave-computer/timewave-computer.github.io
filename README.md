# Timewave website
Powered by Jekyll.

Some components imported from [jekyll minima theme](https://github.com/jekyll/minima/tree/2.5-stable).

 **Warning**, we are on minima 2.5. Make sure to use [this branch](https://github.com/jekyll/minima/tree/2.5-stable) for docs. Any files or variables not found in here can be found in the minima repository.

## Local environment

### Option 1: Nix (Recommended)
We provide a complete nix flake for reproducible development environments.

1. Enter the development shell:
```bash
nix develop
```

2. Install dependencies:
```bash
install-deps
```

3. Start development server:
```bash
serve-site
```

### Option 2: Traditional Ruby/Jekyll
1. follow [jekyll set up instructions](https://jekyllrb.com/docs/)
2. install additional dependencies
```bash
bundle install
```

## Development

### With Nix
```bash
# Start development server (auto-reloads on changes)
serve-site

# Or using nix run
nix run .#serve
```

### Traditional
```bash
bundle exec jekyll serve
```

## Available Nix Commands

All commands are available in the nix development shell (`nix develop`):

- `install-deps` - Install Ruby dependencies (bundle install)
- `update-deps` - Update Ruby dependencies (bundle update)  
- `serve-site` - Start development server (jekyll serve)
- `build-site` - Build static site (jekyll build --verbose)
- `clean-site` - Clean build artifacts
- `preview-deploy` - Build site for deployment preview
- `check-site` - Check site health (jekyll doctor)
- `new-post 'title'` - Create a new blog post

You can also run commands directly with nix:
```bash
nix run .#serve    # Start dev server
nix run .#build    # Build site
nix run .#install  # Install deps
nix run .#clean    # Clean artifacts
nix run .#preview  # Preview deployment
nix run .#check    # Check site health
```

## Add a post

### With Nix
```bash
new-post "My New Blog Post Title"
```

### Traditional
- Follow [these guidelines](https://stackoverflow.com/questions/30625044/jekyll-post-not-generated)
- Build to generate files in `_site` folder
```bash
bundle exec jekyll build --verbose  
```

## Preview Deployment

### With Nix
```bash
preview-deploy
```

### Traditional
- Make a netlify account (or whatever static site deployment platform you prefer)
- Build site
```bash
bundle exec jekyll build --verbose  
```
- Paste `_site` folder manually into deployment platform

## Production deployment
- Happens automatically via github pages + git workflows