namespace :db do
  desc "Fill database with sample datas"
  task populate: :environment do
    make_user
    make_books
    
    # make_borrows
  end
end

# generate user
def make_user
  me = User.create!(name: "zxiao",
                    email: "zxiao@successfactors.com",
                    password: "sf1234",
                    password_confirmation: "sf1234")
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
    available = 1
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
                 available: available,
                 provider: provider)
  end
end

# generate borrows
def make_borrows
  5.times do |n|
    srtime = Time.new
    status = '使用中'
    flag = 1
    book_id = n+1
    user_id = 1
    
    Borrow.create!(user_id: user_id,
                   book_id: book_id,
                   should_return_date: srtime,
                   status: status,
                   is_expired: flag)
  end
end