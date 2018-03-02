require_relative 'environment'
module Jekyll
  module Netlify
    # Netlify plugin generator
    class Generator < Jekyll::Generator
      safe true

      def generate(site)
        env = Environment.new
        if netlify?
          ENV['JEKYLL_ENV'] = env.jekyll_env
          site.config['environment'] = env.jekyll_env
          site.config['netlify'] = load_netlify_env
          site.config['netlify']['environment'] = env.prefixed_env
          if production?
            site.config['url'] = site.config['netlify']['url']
          else
            site.config['url'] = site.config['netlify']['deploy_url']
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

      def pull_request_id(env = ENV)
        branch = env['BRANCH']
        return false unless branch =~ /^(pull|merge-requests)/

        parts = branch.split(%r{\/})
        Integer(parts[1])
      end

      def pull_request_url(env = ENV)
        repository_url = env['REPOSITORY_URL']
        if repository_url.start_with? 'git@'
          repository_url = repository_url.tr(':', '/')
          repository_url = repository_url.gsub('git@', 'https://')
        end
        if repository_url.include? 'gitlab'
          return repository_url + '/merge_requests/' + pull_request_id.to_s
        elsif repository_url.include? 'github'
          return repository_url + '/pulls/' + pull_request_id.to_s
        end
      end

      def webhook?
        ENV.key?('WEBHOOK_URL')
      end

      def load_netlify_env(env = ENV)
        data = {
          'repository_url' => env['REPOSITORY_URL'],
          'branch' => env['BRANCH'],
          'head' => env['HEAD'],
          'commit' => env['COMMIT_REF'],
          'context' => env['CONTEXT'],
          'deploy_url' => env['DEPLOY_URL'],
          'url' => ENV['URL'],
          'deploy_prime_url' => env['DEPLOY_PRIME_URL'],
        }
        if pull_request?
          id = pull_request_id
          if id
            data['pull_request'] = {
              'id' => id,
              'url' => pull_request_url,
            }
          else
            data['pull_request'] = true
          end
        else
          data['pull_request'] = false
        end
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
