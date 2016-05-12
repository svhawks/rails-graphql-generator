module Graphql
  module Generators
    class InitGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def add_gems
        gem 'graphql'
        gem 'graphql-relay'
        gem 'graphiql-rails'
        gem 'graphql-formatter'
      end

      def routes
        route "post 'graphql' => 'graph_ql#execute'"
        route "mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql'"
      end

      def autoload_paths
        application do <<-'RUBY'
  config.autoload_paths += Dir["#{config.root}/app/graphql/**/"]
        RUBY
        end
      end

      def copy_templates
        copy_file 'controllers/graph_ql_controller.rb', 'app/controllers/graph_ql_controller.rb'
        copy_file 'models/root_level.rb', 'app/models/root_level.rb'
        copy_file 'graph/relay_schema.rb', 'app/graphql/relay_schema.rb'
        copy_file 'graph/node_identification.rb', 'app/graphql/node_identification.rb'
        copy_file 'graph/types/root_level_type.rb', 'app/graphql/types/root_level_type.rb'
        copy_file 'graph/types/query_type.rb', 'app/graphql/types/query_type.rb'
        copy_file 'graph/types/mutation_type.rb', 'app/graphql/types/mutation_type.rb'

        copy_file 'config/graphiql.rb', 'config/initializers/graphiql.rb'
      end
    end
  end
end

