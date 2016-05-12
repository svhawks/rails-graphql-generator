require 'generators/graphql/graphql_helpers'

module Graphql
  module Generators
    class GraphqlGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)
      namespace 'graphql'

      include Graphql::Generators::GraphqlHelpers

      def create
        model = name.classify.constantize
        create_type(model)
        add_fields(model)
        add_methods(model)
        add_connections(model)
        add_connection_query(model)
        create_mutation(model)
        add_fields_to_mutation(model)
        add_mutation_query(model)
      end
    end
  end
end
