[![Build Status](https://travis-ci.org/jayvdb/jekyll-netlify.svg?branch=master)](https://travis-ci.org/jayvdb/jekyll-netlify)

# Jekyll::Netlify

Expose Netlify deploy information to Jekyll templates
and set `site.environment=production`.

```
{{site.netlify.branch}} # => Will return the branch name
```

## Installation

Add to your `Gemfile`:

```
gem 'jekyll-netlify'
```

Add to your `_config.yml`:

```yml
plugins:
  - jekyll-netlify
```

## Usage

This plugin adds hash of `site.netlify` containing
[Build Environment information](https://www.netlify.com/docs/continuous-deployment/#build-environment-variables):

- repository_url
- branch
- pull_request: bool (but the next release it will also be the pull_request number when available)
- head
- commit
- context
- deploy_url
- url
- deploy_prime_url
- webhook
  - title
  - url
  - body
