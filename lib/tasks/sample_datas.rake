namespace :db do
  desc "Fill database with sample datas"
  task populate: :environment do
    make_user
    make_books
  end
end

# generate user
def make_user
  me = User.create!(name: "zxiao",
                    email: "zxiao@successfactors.com",
                    cate: "管理员",
                    team: "Mobile",
                    password: "sf1234",
                    password_confirmation: "sf1234")
  12.times do
    name  = Faker::Name.name
    email = Faker::Name.name+"@successfactors.com"
    cate = "读者"
    team = Faker::Name.name
    pwd = "sf1234"
    
    User.create!(name: name,
                        email: email,
                        cate: cate,
                        team: team,
                        password: pwd,
                        password_confirmation: pwd)
  end
    
end

# generate books
def make_books
  20.times do
    name  = Faker::Name.name
    picture = Faker::Internet.url
    intro = Faker::Lorem.characters
    author = Faker::Name.name
    isbn = Faker::Number.number(5)
    press = Faker::Name.name
    publish_date = Time.new
    price = Faker::Number.digit
    total = 1
    store = 1
    status = "已买"
    provider = Faker::Name.name
    
    Book.create!(name: name,
                 picture: picture,
                 intro: intro,
                 author: author,
                 isbn: isbn,
                 press: press,
                 publish_date: publish_date,
                 price: price,
                 total: total,
                 store: store,
                 status: status,
                 provider: provider)
  end
  8.times do
    name  = Faker::Name.name
    picture = Faker::Internet.url
    intro = Faker::Lorem.characters
    author = Faker::Name.name
    isbn = Faker::Number.number(5)
    press = Faker::Name.name
    publish_date = Time.new
    price = Faker::Number.digit
    total = 0
    store = 0
    point = 0
    status = "推荐"
    recommender = Faker::Name.name
    
    Book.create!(name: name,
                 picture: picture,
                 intro: intro,
                 author: author,
                 isbn: isbn,
                 press: press,
                 publish_date: publish_date,
                 price: price,
                 total: total,
                 store: store,
                 point: point,
                 status: status,
                 recommender: recommender)
  end
end