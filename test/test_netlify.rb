require 'minitest/autorun'
require 'minitest/unit'
require 'shoulda'
require 'mocha/mini_test'
require 'jekyll'
require 'jekyll-netlify'

def jekyll_test_site
  File.join(File.dirname(__FILE__), 'test_site')
end

def get_about_page(site)
  site.pages[0]
end

class Jekyll::NetlifyTest < Minitest::Test
  context 'normal build' do
    setup do
      Jekyll.instance_variable_set(
        :@logger, Jekyll::LogAdapter.new(Jekyll::Stevenson.new, :error)
      )

      ENV.clear

      config = Jekyll.configuration(
        source: jekyll_test_site,
        destination: File.join(jekyll_test_site, '_site'),
        plugins: nil,
      )
      @site = Jekyll::Site.new(config)
      @site.read
      @site.generate
      @site.render
      @about_page = get_about_page(@site)
    end

    context 'netlify info' do
      setup do
        @netlify = @site.config['netlify']
      end

      should 'be false' do
        assert_equal false, @netlify
      end
    end

    context 'site.url' do
      should 'be from _config.yml' do
        assert_equal 'http://fake.com', @site.config['url']
        assert_operator @about_page.output, :include?, 'http://fake.com'
      end
    end
  end

  context 'netlify production context' do
    setup do
      Jekyll.instance_variable_set(
        :@logger, Jekyll::LogAdapter.new(Jekyll::Stevenson.new, :error)
      )

      ENV.clear

      ENV['URL'] = 'https://example.com'
      ENV['BRANCH'] = 'master'
      ENV['CONTEXT'] = 'production'
      ENV['PULL_REQUEST'] = 'false'
      ENV['DEPLOY_URL'] = 'https://578ab634d5d5cf960d620--open-api.netlify.com'
      ENV['DEPLOY_PRIME_URL'] = 'https://beta--open-api.netlify.com'

      config = Jekyll.configuration(
        source: jekyll_test_site,
        destination: File.join(jekyll_test_site, '_site'),
      )
      @site = Jekyll::Site.new(config)
      @site.read
      @site.generate
      @site.render
      @about_page = get_about_page(@site)
    end

    context 'info' do
      setup do
        @netlify = @site.config['netlify']
      end

      should 'be a Hash' do
        assert_instance_of Hash, @netlify
      end

      should 'include URLs' do
        assert_operator @netlify, :has_key?, 'url'
        assert_equal 'https://example.com', @netlify['url']
      end

      should 'be production' do
        assert_equal 'production', @site.config['environment']
        assert_equal 'production', @netlify['environment']
      end

      should 'not be a pull request' do
        assert_operator @netlify, :has_key?, 'pull_request'
        assert_equal false, @netlify['pull_request']
      end

      should 'not include webhook data' do
        assert_operator @netlify, :has_key?, 'webhook'
        assert_equal false, @netlify['webhook']
      end
    end

    context 'site.url' do
      should 'be netlify production url' do
        assert_equal 'https://example.com', @site.config['url']
      end
      should 'be expanded in about.md' do
        assert_operator @about_page.output, :include?, 'https://example.com'
      end
    end
  end

  context 'netlify deploy-preview context' do
    setup do
      Jekyll.instance_variable_set(
        :@logger, Jekyll::LogAdapter.new(Jekyll::Stevenson.new, :error)
      )

      ENV.clear
      ENV['URL'] = 'https://example.com'
      ENV['CONTEXT'] = 'deploy-preview'
      ENV['JEKYLL_ENV'] = 'staging'

      ENV['PULL_REQUEST'] = 'false'
      ENV['DEPLOY_URL'] = 'https://578ab634d5d5cf960d620--open-api.netlify.com'
      ENV['DEPLOY_PRIME_URL'] = 'https://beta--open-api.netlify.com'

      config = Jekyll.configuration(
        source: jekyll_test_site,
        destination: File.join(jekyll_test_site, '_site'),
      )
      @site = Jekyll::Site.new(config)
      @site.read
      @site.generate
      @site.render
      @about_page = get_about_page(@site)
    end

    context 'info' do
      setup do
        @netlify = @site.config['netlify']
      end
      should 'be staging-deploy-preview' do
        assert_equal 'staging', @site.config['environment']
        assert_equal 'staging-deploy-preview', @netlify['environment']
      end
    end

    context 'site.url' do
      should 'be netlify deploy-preview url' do
        assert_equal ENV['DEPLOY_URL'], @site.config['url']
      end
      should 'be expanded in about.md' do
        assert_operator @about_page.output, :include?, ENV['DEPLOY_URL']
      end
    end
  end

  context 'netlify unrecognised pull request' do
    setup do
      Jekyll.instance_variable_set(
        :@logger, Jekyll::LogAdapter.new(Jekyll::Stevenson.new, :error)
      )

      ENV.clear

      ENV['URL'] = 'https://example.com'
      ENV['BRANCH'] = 'foo/bar'
      ENV['CONTEXT'] = 'deploy-preview'
      ENV['PULL_REQUEST'] = 'true'
      ENV['DEPLOY_URL'] = 'https://578ab634d5d5cf960d620--open-api.netlify.com'
      ENV['DEPLOY_PRIME_URL'] = 'https://beta--open-api.netlify.com'

      config = Jekyll.configuration(
        source: jekyll_test_site,
        destination: File.join(jekyll_test_site, '_site'),
      )
      @site = Jekyll::Site.new(config)
      @site.read
      @site.generate
    end

    context 'info' do
      setup do
        @netlify = @site.config['netlify']
      end

      should 'be a Hash' do
        assert_instance_of Hash, @netlify
      end

      should 'include URLs' do
        assert_operator @netlify, :has_key?, 'url'
        assert_equal 'https://example.com', @netlify['url']
      end

      should 'be production' do
        assert_equal 'production', @site.config['environment']
        assert_equal 'production-deploy-preview', @netlify['environment']
      end

      should 'be a pull request' do
        assert_operator @netlify, :has_key?, 'pull_request'
        assert_equal true, @netlify['pull_request']
      end

      should 'not include webhook data' do
        assert_operator @netlify, :has_key?, 'webhook'
        assert_equal false, @netlify['webhook']
      end
    end
  end

  context 'netlify github pull request' do
    setup do
      Jekyll.instance_variable_set(
        :@logger, Jekyll::LogAdapter.new(Jekyll::Stevenson.new, :error)
      )

      ENV.clear

      ENV['REPOSITORY_URL'] = 'https://github.com/foo/bar'
      ENV['URL'] = 'https://example.com'
      ENV['BRANCH'] = 'pull/23/head'
      ENV['CONTEXT'] = 'deploy-preview'
      ENV['PULL_REQUEST'] = 'true'
      ENV['DEPLOY_URL'] = 'https://578ab634d5d5cf960d620--open-api.netlify.com'
      ENV['DEPLOY_PRIME_URL'] = 'https://beta--open-api.netlify.com'

      config = Jekyll.configuration(
        source: jekyll_test_site,
        destination: File.join(jekyll_test_site, '_site'),
      )
      @site = Jekyll::Site.new(config)
      @site.read
      @site.generate
    end

    context 'info' do
      setup do
        @netlify = @site.config['netlify']
      end

      should 'be a pull request' do
        assert_operator @netlify, :has_key?, 'pull_request'
        assert_instance_of Hash, @netlify['pull_request']
      end

      should 'have a pull request id' do
        assert_instance_of Integer, @netlify['pull_request']['id']
        assert @netlify['pull_request']['id'].eql? 23
      end

      should 'have a pull request url' do
        assert_instance_of String, @netlify['pull_request']['url']
        assert_equal 'https://github.com/foo/bar/pulls/23',
                     @netlify['pull_request']['url']
      end
    end
  end

  context 'netlify gitlab pull request' do
    setup do
      Jekyll.instance_variable_set(
        :@logger, Jekyll::LogAdapter.new(Jekyll::Stevenson.new, :error)
      )

      ENV.clear

      ENV['REPOSITORY_URL'] = 'git@gitlab.com:foo/bar'
      ENV['URL'] = 'https://example.com'
      ENV['BRANCH'] = 'merge-requests/23/head'
      ENV['CONTEXT'] = 'deploy-preview'
      ENV['PULL_REQUEST'] = 'true'
      ENV['DEPLOY_URL'] = 'https://578ab634d5d5cf960d620--open-api.netlify.com'
      ENV['DEPLOY_PRIME_URL'] = 'https://beta--open-api.netlify.com'

      config = Jekyll.configuration(
        source: jekyll_test_site,
        destination: File.join(jekyll_test_site, '_site'),
      )
      @site = Jekyll::Site.new(config)
      @site.read
      @site.generate
    end

    context 'info' do
      setup do
        @netlify = @site.config['netlify']
      end

      should 'be a pull request' do
        assert_operator @netlify, :has_key?, 'pull_request'
        assert_instance_of Hash, @netlify['pull_request']
      end

      should 'have a pull request id' do
        assert_instance_of Integer, @netlify['pull_request']['id']
        assert @netlify['pull_request']['id'].eql? 23
      end

      should 'have a pull request url' do
        assert_instance_of String, @netlify['pull_request']['url']
        assert_equal 'https://gitlab.com/foo/bar/merge_requests/23',
                     @netlify['pull_request']['url']
      end
    end
  end

  context 'netlify webhook deploy' do
    setup do
      Jekyll.instance_variable_set(
        :@logger, Jekyll::LogAdapter.new(Jekyll::Stevenson.new, :error)
      )

      ENV.clear

      ENV['URL'] = 'https://example.com'
      ENV['DEPLOY_URL'] = 'https://578ab634d5d5cf960d620--open-api.netlify.com'
      ENV['DEPLOY_PRIME_URL'] = 'https://beta--open-api.netlify.com'
      ENV['PULL_REQUEST'] = 'false'
      ENV['WEBHOOK_TITLE'] = 'Title'
      ENV['WEBHOOK_URL'] = 'http://webtask.io/foo'
      ENV['WEBHOOK_BODY'] = '{}'

      config = Jekyll.configuration(
        source: jekyll_test_site,
        destination: File.join(jekyll_test_site, '_site'),
      )
      @site = Jekyll::Site.new(config)
      @site.read
      @site.generate
    end

    context 'info' do
      setup do
        @netlify = @site.config['netlify']
      end

      should 'be a Hash' do
        assert_operator @netlify, :has_key?, 'webhook'
        assert_instance_of Hash, @netlify['webhook']
      end

      should 'include webhook data' do
        assert_equal 'Title', @netlify['webhook']['title']
        assert_equal '{}', @netlify['webhook']['body']
        assert_equal 'http://webtask.io/foo', @netlify['webhook']['url']
      end
    end
  end
end
