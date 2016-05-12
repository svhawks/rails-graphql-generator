# Rails Graph Generator

*A GraphQL Relay schema created by reflection over a Rails models*

## Usage
Add your Gemfile:

```bash
gem 'rails-graphql-generator'
bundle install
```

and then just run it!

```bash
rails g graphql:init

rails g graphql:create_all

# or

rails g model User name:string email:string
rake db:migrate
rails g graphql User
```

and start server [http://localhost:3000/graphiql](http://localhost:3000/graphiql)

Check out the **[example](https://github.com/movielala/rails-graphql-generator-demo)** for a demo of Rails GraphQL Generator in action.

## Road Map

* Add test
* Add without relay option
