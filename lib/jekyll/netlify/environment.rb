module Jekyll
  module Netlify
    # :no_doc:
    class Environment
      attr_reader :jekyll_env

      def initialize
        @netlify_context = ENV['CONTEXT']
        if netlify?
          @jekyll_env = 'production'
        else
          @jekyll_env = Jekyll.env
        end
      end

      def prefixed_env
        if suffix_context?
          @jekyll_env
        else
          [@jekyll_env, @netlify_context].join('-')
        end
      end

      def netlify?
        ENV['DEPLOY_URL'] && (!ENV['JEKYLL_ENV'] || ENV['JEKYLL_ENV'].empty?)
      end

      private

      def production_context?
        @netlify_context == 'production'
      end

      def netlify_context_blank?
        (!@netlify_context || @netlify_context.empty?)
      end

      def suffix_context?
        @jekyll_env && ((@jekyll_env == @netlify_context) ||
            netlify_context_blank? ||
            production_context?)
      end
    end
  end
end
