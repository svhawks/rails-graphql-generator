# Rails GraphQL Generator

# This project is not maintained anymore. You can use [graphql-ruby](https://github.com/rmosolgo/graphql-ruby)'s generators.

[![Code Climate](https://codeclimate.com/github/movielala/rails-graphql-generator/badges/gpa.svg)](https://codeclimate.com/github/movielala/rails-graphql-generator)

*A GraphQL Relay schema created by reflection over a Rails models*

## Demo
Check out the **[example](https://github.com/movielala/rails-graphql-generator-demo)** for a demo of Rails GraphQL Generator in action.

## Usage
Add your Gemfile:

```bash
gem 'rails-graphql-generator', '~> 0.1.0'
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

## Road Map

* Add test
* Add without relay option
