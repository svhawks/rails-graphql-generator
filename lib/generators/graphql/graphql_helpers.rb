module Graphql
  module Generators
    module GraphqlHelpers
      def models
        @models ||= ActiveRecord::Base.connection.tables.map{ |x| x.classify.safe_constantize }.compact
      end

      def type_mapper
        @type_mapper ||= {
            integer:  'Int',
            string:   'String',
            datetime: 'String',
            boolean:  'Boolean',
            float:    'Float',
            date:     'String',
            json:     'String',
            text:     'String',
            decimal:  'Float',
            '' =>     'String',
        }
      end

      def create_type(model)
        create_file "app/graphql/types/#{ActiveModel::Naming.singular_route_key(model)}_type.rb", <<-FILE
#{model.to_s}Type = GraphQL::ObjectType.define do
  name '#{model.to_s}'
  description '#{model.to_s} type'

  interfaces [NodeIdentification.interface]
  
  global_id_field :id
  # End of fields
end
        FILE
        add_fields(model)
      end

      def add_fields(model)
        columns = model.columns_hash
        columns.keys.each do |k|
          next if columns[k].name == 'id'

          if columns[k].type.present?
            inject_into_file type_path(model), after: "global_id_field :id\n" do <<-FILE
  field :#{columns[k].name}, types.#{type_mapper[columns[k].type]}
            FILE
            end
          end
        end
      end

      def add_methods(model)
        associations = model.reflect_on_all_associations(:belongs_to)

        associations.map(&:name).each do |ast|
          association_klass = model.reflect_on_association(ast).class_name

          begin
            if models.include? association_klass.classify.constantize
              inject_into_file type_path(model), before: "# End of fields\n" do <<-FILE
  field :#{ast.to_s} do
    type -> { #{model.reflect_on_association(ast).class_name}Type }

    resolve -> (#{singular_route_key(model)}, args, ctx) {
      #{singular_route_key(model)}.#{ast.to_s}
    }
  end

              FILE
              end
            end
          rescue => ex
            puts ex
          end
        end
      end

      def add_connections(model)
        associations = model.reflect_on_all_associations(:has_many)
        associations += model.reflect_on_all_associations(:has_and_belongs_to_many)

        associations.map(&:name).each do |ast|
          association_klass = model.reflect_on_association(ast).class_name
          begin
            if models.include? association_klass.classify.constantize
              if circular_finder[model.to_s].include? association_klass || association_klass == model.to_s
                inject_into_file type_path(model), before: "# End of fields\n" do <<-FILE
  connection :#{ast.to_s}, -> { #{model.reflect_on_association(ast).class_name}Type.connection_type } do
    resolve ->(#{singular_route_key(model)}, args, ctx) {
      #{singular_route_key(model)}.#{ast}
    }
  end

                FILE
                end
              else
                inject_into_file type_path(model), before: "# End of fields\n" do <<-FILE
  connection :#{ast.to_s}, #{model.reflect_on_association(ast).class_name}Type.connection_type do
    resolve -> (#{singular_route_key(model)}, args, ctx) {
      #{singular_route_key(model)}.#{ast}
    }
  end
                FILE
                end
              end
            end
          rescue => ex
            puts ex
          end
        end
      end

      def add_connection_query(model)
        inject_into_file 'app/graphql/types/root_level_type.rb', after: "field :id, field: GraphQL::Relay::GlobalIdField.new('RootLevel')\n" do <<-FILE
  connection :#{model.to_s.tableize}, #{model.to_s}Type.connection_type do
    resolve ->(object, args, ctx){
      #{model.to_s}.all
    }
  end
        FILE
        end
      end

      def create_mutation(model)
        create_file mutation_path(model), <<-FILE
module #{model.to_s}Mutations

  Create = GraphQL::Relay::Mutation.define do
    name 'Create#{model.to_s}'

    return_field :#{instance_name(model)}, #{model.to_s}Type

    resolve -> (inputs, ctx) {
      root = RootLevel::STATIC
      attr = inputs.keys.inject({}) do |memo, key|
        memo[key] = inputs[key] unless key == "clientMutationId"
        memo
      end

      #{instance_name(model)} = #{model.to_s}.create(attr)

      { #{instance_name(model)}: #{instance_name(model)} }
    }
  end

  Update = GraphQL::Relay::Mutation.define do
    name 'Update#{model.to_s}'

    input_field :id, !types.ID

    return_field :#{instance_name(model)}, #{model.to_s}Type

    resolve -> (inputs, ctx) {
      #{instance_name(model)} = NodeIdentification.object_from_id((inputs[:id]), ctx)
      attr = inputs.keys.inject({}) do |memo, key|
        memo[key] = inputs[key] unless key == "clientMutationId" || key == 'id'
        memo
      end

      #{instance_name(model)}.update(attr)
      { #{instance_name(model)}: #{instance_name(model)} }
    }
  end

  Destroy = GraphQL::Relay::Mutation.define do
    name "Destroy#{model.to_s}"

    input_field :id, !types.ID

    resolve -> (inputs, ctx) {
      #{instance_name(model)} = NodeIdentification.object_from_id((inputs[:id]), ctx)
      #{instance_name(model)}.destroy
      { }
    }
  end
end
        FILE
      end

      def add_fields_to_mutation(model)
        columns = model.columns_hash
        columns.keys.each do |k|
          next if %w(id created_at updated_at).include? columns[k].name
          if columns[k].type.present?
            inject_into_file mutation_path(model), after: "name 'Update#{model.to_s}'\n" do <<-FILE
    input_field :#{columns[k].name}, types.#{type_mapper[columns[k].type]}
            FILE
            end

            inject_into_file mutation_path(model), after: "name 'Create#{model.to_s}'\n", :force => true do <<-FILE
    input_field :#{columns[k].name}, !types.#{type_mapper[columns[k].type]}
            FILE
            end
          end
        end
      end

      def add_mutation_query(model)
        inject_into_file "app/graphql/types/mutation_type.rb", after: "name 'MutationType'\n" do <<-FILE
  field :create#{model.to_s}, field: #{model.to_s}Mutations::Create.field
  field :update#{model.to_s}, field: #{model.to_s}Mutations::Update.field
  field :destroy#{model.to_s}, field: #{model.to_s}Mutations::Destroy.field

        FILE
        end
      end

      def singular_route_key(model)
        ActiveModel::Naming.singular_route_key(model)
      end

      def mutation_path(model)
        "app/graphql/mutations/#{singular_route_key(model)}_mutations.rb"
      end

      def type_path(model)
        "app/graphql/types/#{singular_route_key(model)}_type.rb"
      end

      def instance_name(model)
        ActiveModel::Naming.singular_route_key(model)
      end

      def circular_finder
        circular_finder = {}

        models.each do |m|
          associations = m.reflect_on_all_associations.map(&:name)
          circular_finder[m.to_s] = [] unless circular_finder[m.to_s].present?

          associations.each do |k|
            association_klass = m.reflect_on_association(k).class_name
            circular_finder[association_klass] = [] unless circular_finder[association_klass].present?

            circular_finder[association_klass] << m.to_s
          end
        end

        @circular_finder ||= circular_finder
      end
    end
  end
end
