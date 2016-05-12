class GraphQlController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def execute
    puts '-' * 100, GraphQLFormatter.new(params[:query]).to_s, '-' * 100
    if params[:variables].present?
      variables = JSON.parse(params[:variables])
    else
      variables = params[:variables]
    end

    render json: GraphQL::Query.new(RelaySchema, params[:query], variables: variables, debug: true).result
  end

end
