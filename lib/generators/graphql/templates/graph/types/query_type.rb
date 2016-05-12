# ...and a query root
QueryType = GraphQL::ObjectType.define do
  name "Query"
  description "The query root of this schema"

  field :node, field: NodeIdentification.field

  field :root, RootLevelType do
    resolve -> (obj, args, ctx) { RootLevel::STATIC }
  end

  # End Of Queries
end
