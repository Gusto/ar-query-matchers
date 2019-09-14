## AR Query Matchers
![badge](https://action-badges.now.sh/gusto/ar-query-matchers?action=Run%20Tests)

These RSpec matchers allows guarding against N+1 queries by specifying
exactly how many queries you expect each of your ActiveRecord models to perform.

They also help us reason about the type of record interactions happening in a block of code.

This pattern is a based on how Rails itself tests queries:
https://github.com/rails/rails/blob/ac2bc00482c1cf47a57477edb6ab1426a3ba593c/activerecord/test/cases/test_case.rb#L104-L141

### Usage
Include it in your Gemfile:
```ruby
group :test do
  gem 'ar-query-matchers', '~> 0.1.0', require: false
end
```

Start using it: 
```ruby
require 'ar-query-matchers'

RSpec.describe Employee do
 it 'creating an employee creates exactly one record' do
  expect { 
    Employee.create!(first_name: 'John', last_name: 'Doe') 
  }.to only_create_models('Employee' => '1')
 end
end
```

### Matchers
This module defines a few categories of matchers:
- **Create**: Which models are created during a block
- **Load**: Which models are fetched during a block
- **Update**: Which models are updated during a block

Each matcher category includes 3 assertions, for example, for the Load category, you could use the following assertions:
- **only_load_models**: Strict assertion, not other query is allowed.
- **not_load_models**: No models are allowed to be loaded.
- **load_models**: Inclusion, other models are allowed to be loaded if not specified in the assertion.


**For example:** 

The following spec will pass only if there are exactly 4 SQL SELECTs that
load User records (and 1 for Address, 1 for Payroll) _and_ no other models
perform any SELECT queries.
```ruby
expect { some_code() }.to only_load_models(
  'User' => 4,
  'Address' => 1,
  'Payroll' => 1,
)
```

The following spec will pass only if there are exactly no select queries.
```ruby
expect { some_code() }.to not_load_models
```

The following spec will pass only if there are exactly 4 SQL SELECTs that
load User records (and 1 for Address, 1 for Payroll).
```ruby
expect { some_code() }.to load_models(
  'User' => 4,
  'Address' => 1,
  'Payroll' => 1,
)
```

This will show some helpful output on failure:

```
Expected to run queries to load models exactly {"Address"=>1, "Payroll"=>1, "User"=>4} queries, got {"Address"=>1, "Payroll"=>1, "User"=>5}
     Expectations that differed:
         User - expected: 4, got: 5 (+1)

     Source lines:
     User loaded from:
         4 call: /spec/controllers/employees_controller_spec.rb:128:in 'block (4 levels) in <top (required)>'
         1 call: /app/models/user.rb:299
```

### High Level Design:
The RSpec matcher delegates to the query counters, asserts expectations and formats error messages to provide meaningful failures.  
 
 
The matchers are pretty simple, and delegate instrumentation into specialized QueryCounter classes.
The QueryCounters are different classes instruments a ruby block by listening on all sql, parsing the queries and returning structured data describing the interactions.

```                
  ┌────────────────────────────────────────────────────────────────────────────────────────┐
┌─┤expect { Employee.create!() }.to only_create_models('Employee' => 1)                    │
│ └────────────────────────────────────────────────────────────────────────────────────────┘
└▶┌────────────────────────────────────────────────────────────────────────────────────────┐
┌─┤Queries::CreateCounter.instrument { Employee.create!() } => QueryStats                  │
│ └────────────────────────────────────────────────────────────────────────────────────────┘
└▶┌────────────────────────────────────────────────────────────────────────────────────────┐
  │QueryCounter.new(CreateQueryFilter.new).instrument { Employee.create!() } => QueryStats │
  └────────────────────────────────────────────────────────────────────────────────────────┘                                                                
```

For more information, see:
1. `ArQueryMatchers::Queries::QueryCounter`
2. `ArQueryMatchers::Queries::CreateCounter`
3. `ArQueryMatchers::Queries::LoadCounter`
4. `ArQueryMatchers::Queries::UpdateCounter`

### Known problems
- The Rails 4 `ActiveRecord::Base#pluck` method doesn't issue a
`Load` or `Exists` named query and therefore we don't capture the counts with
this tool. This may be fixed in Rails 5/6.
