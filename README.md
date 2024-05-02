# Timewave website
Powered by Jekyll. Some components imported from jekyll [minima](https://github.com/jekyll/minima theme)


## Developing
1. follow [jekyll set up instructions](https://jekyllrb.com/docs/)
2. install additional dependencies
```bash
bundle install
```
2. run dev server
```bash
bundle exec jekyll serve
```

## Adding posts
- Follow [these style guidelines](https://stackoverflow.com/questions/30625044/jekyll-post-not-generated)
- Build to generate folders in `_site`
```bash
bundle exec jekyll build --verbose  
```

## Preview Deployments with Netlify
- Build files `_site`
```bash
bundle exec jekyll build --verbose  
```
- Paste folder manually into netlify