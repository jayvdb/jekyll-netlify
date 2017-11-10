require 'minitest/autorun'
require 'minitest/unit'
require 'shoulda'
require 'mocha/mini_test'
require 'jekyll'
require 'jekyll-netlify'

def jekyll_test_site
  File.join(File.dirname(__FILE__), 'test_site')
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
    end

    context 'netlify info' do
      setup do
        @netlify = @site.config['netlify']
      end

      should 'be false' do
        assert_equal false, @netlify
      end
    end
  end

  context 'netlify production deploy' do
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
  end

  context 'netlify pull request' do
    setup do
      Jekyll.instance_variable_set(
        :@logger, Jekyll::LogAdapter.new(Jekyll::Stevenson.new, :error)
      )

      ENV.clear

      ENV['URL'] = 'https://example.com'
      ENV['BRANCH'] = 'master'
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

      should 'not be production' do
        assert_operator @site.config['environment'], :!=, 'production'
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
