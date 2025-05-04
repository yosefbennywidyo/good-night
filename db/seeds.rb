# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require 'faker'

# Clear existing data to avoid duplication
User.destroy_all
Following.destroy_all
SleepRecord.destroy_all

# Reset primary keys (optional, for clean IDs in development)
ActiveRecord::Base.connection.reset_pk_sequence!('users')
ActiveRecord::Base.connection.reset_pk_sequence!('followings')
ActiveRecord::Base.connection.reset_pk_sequence!('sleep_records')

# Create 100 users
users = []
100.times do
  users << User.create!(
    name: Faker::Name.unique.name
  )
end

# Create 1,000 followings
1000.times do
  follower = users.sample
  followed = users.sample

  # Ensure a user cannot follow themselves and avoid duplicate followings
  next if follower == followed || follower.following?(followed)

  Following.create!(follower: follower, followed: followed)
end

# Create 10 sleep records for each user
users.each do |user|
  10.times do
    clock_in_at = Faker::Time.between(from: 10.days.ago, to: Time.current)
    clock_out_at = clock_in_at + rand(6..10).hours # Random sleep duration between 6 to 10 hours

    SleepRecord.create!(
      user: user,
      clock_in_at: clock_in_at,
      clock_out_at: clock_out_at
    )
  end
end

puts "Seed data created successfully!"
