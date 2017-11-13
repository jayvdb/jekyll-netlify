[![Build Status](https://travis-ci.org/jayvdb/jekyll-netlify.svg?branch=master)](https://travis-ci.org/jayvdb/jekyll-netlify)
[![Gem Version](https://badge.fury.io/rb/jekyll-netlify.svg)](https://badge.fury.io/rb/jekyll-netlify)

# Jekyll::Netlify

Expose Netlify deploy information to Jekyll templates
and set `site.environment=production`.

```
{{site.netlify.branch}} # => Will return the branch name
{{site.netlify.pull_request.url}} # => Will return http://github.com/foo/bar/pulls/23
```

## Installation

Add to your `Gemfile`:

```
group :jekyll_plugins do
  gem "jekyll-netlify"
end
```

For older versions of Jekyll, add to your `_config.yml`:

```yml
plugins:
  - jekyll-netlify
```

## Usage

This plugin adds hash of `site.netlify` containing
[Build Environment information](https://www.netlify.com/docs/continuous-deployment/#build-environment-variables):

- repository_url (`git@...`)
- branch
- pull_request: (false; true for BitBucket; or Hash for GitHub and GitLab)
  - id
  - url
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
