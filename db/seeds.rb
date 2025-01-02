user = Qubit.user_class.constantize.create!

unlaunched_test = Qubit::Test.create!(
  owner: user,
  name: "Basic Example Test",
  description: "This is an example test with 2 variants",
  condition: "!paid? && (dau? || beta_tester?)",
  subject_type: "Qubit::User",
)

Qubit::Variant.create!(
  name: 'control',
  description: 'The control variant for the basic test',
  test: unlaunched_test,
  parameters: {
    cta: 'Sign Up Now',
    color: 'green',
  },
)

unlaunched_test.update_attribute(:control, unlaunched_test.variants[0])

Qubit::Variant.create!(
  name: 'variant',
  description: 'The variant for the basic test',
  test: unlaunched_test,
  parameters: {
    cta: 'Learn More',
    color: 'blue',
  },
)

unlaunched_test.create_census!

launched_test = Qubit::Test.create!(
  owner: user,
  name: "Launched Example Test",
  description: "This is an example test that has been launched",
)

control = Qubit::Variant.create!(
  name: 'control',
  description: 'The control variant for the launched test',
  test: launched_test,
)

launched_test.update_attribute(:control, control)

variant = Qubit::Variant.create!(
  name: 'variant', 
  description: 'The variant for the launched test',
  test: launched_test,
)

# Launch with default 50/50 split
launched_test.launch!

three_pronged_test = Qubit::Test.create!(
  owner: user,
  name: "Three Variant Test",
  description: "This is an example test with three variants",
)

control = Qubit::Variant.create!(
  name: 'control',
  description: 'The control variant for the three variant test',
  test: three_pronged_test,
)

three_pronged_test.update_attribute(:control, control)

variant_1 = Qubit::Variant.create!(
  name: 'variant_1',
  description: 'The first variant for the three variant test',
  test: three_pronged_test,
)

variant_2 = Qubit::Variant.create!(
  name: 'variant_2', 
  description: 'The second variant for the three variant test',
  test: three_pronged_test,
)

# Launch with 10% canary traffic split evenly between variants
three_pronged_test.launch!(rollout: 10)
