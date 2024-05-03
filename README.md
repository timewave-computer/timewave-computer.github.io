# Timewave website
Powered by Jekyll. Some components imported from jekyll [minima](https://github.com/jekyll/minima theme)

## Local environment
1. follow [jekyll set up instructions](https://jekyllrb.com/docs/)
2. install additional dependencies
```bash
bundle install
```
## Development
Run development server. Catches majority of updates live, command + R to see code changes reflect in UI. Sometimes you may need to rebuild.
```bash
bundle exec jekyll serve
```

## Add a post
- Follow [these guidelines](https://stackoverflow.com/questions/30625044/jekyll-post-not-generated)
- Build to generate files in `_site` folder
```bash
bundle exec jekyll build --verbose  
```

## Preview Deployment
- Make a netlify account (or whatever static site deployment platform you prefer)
- Build site
```bash
bundle exec jekyll build --verbose  
```
- Paste `_site` folder manually into deployment platform

## Production deployment
- Happens automatically via github pages + git workflows