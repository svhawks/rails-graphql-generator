require 'generators/graphql/graphql_helpers'

module Graphql
  module Generators
    class CreateAllGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      include Graphql::Generators::GraphqlHelpers

      def create
        models.each { |model| create_type(model) }
        models.each { |model| add_fields(model) }
        models.each { |model| add_methods(model) }
        models.each { |model| add_connections(model) }
        models.each { |model| add_connection_query(model) }
        models.each { |model| create_mutation(model) }
        models.each { |model| add_fields_to_mutation(model) }
        models.each { |model| add_mutation_query(model) }
      end

    end
  end
end
