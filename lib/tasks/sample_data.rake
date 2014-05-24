namespace :db do
  desc "Fill database with sample data"
  task populate: :prooduction do
    Movie.create!(url: "http://example.com",
                 description: "examples")
    99.times do |n|
      url         = "http:/example-#{n+1}@rails.com"
      description = "example"
      Movie.create!(url: url,
                   description: description)
    end
  end
end