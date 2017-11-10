module Jekyll
  module Netlify
    # Netlify plugin generator
    class Generator < Jekyll::Generator
      safe true

      def generate(site)
        if netlify?
          site.config['netlify'] = load_netlify_env
          if production?
            ENV['JEKYLL_ENV'] = 'production'
            site.config['environment'] = 'production'
          end
        else
          site.config['netlify'] = false
        end
      end

      def netlify?
        return false unless ENV.key?('DEPLOY_URL')
        deploy_url = ENV['DEPLOY_URL']
        return false unless deploy_url.include? 'netlify'

        true
      end

      def production?
        ENV['CONTEXT'].eql?('production') ? true : false
      end

      def pull_request?
        ENV['PULL_REQUEST'].eql?('true') ? true : false
      end

      def webhook?
        ENV.key?('WEBHOOK_URL')
      end

      def load_netlify_env(env = ENV)
        data = {
          'repository_url' => env['REPOSITORY_URL'],
          'branch' => env['BRANCH'],
          'pull_request' => pull_request?,
          'head' => env['HEAD'],
          'commit' => env['COMMIT_REF'],
          'context' => env['CONTEXT'],
          'deploy_url' => env['DEPLOY_URL'],
          'url' => ENV['URL'],
          'deploy_prime_url' => env['DEPLOY_PRIME_URL'],
        }
        data['webhook'] = !webhook? ? false : {
          'title' => env['WEBHOOK_TITLE'],
          'body' => env['WEBHOOK_BODY'],
          'url' => env['WEBHOOK_URL'],
        }
        data
      end
    end
  end
end
