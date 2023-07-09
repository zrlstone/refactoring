require 'rspec/autorun'

module DefaultPrice
  def frequent_renter_points(days_rented)
    1
  end
end

class Movie
  REGULAR = 0
  NEW_RELEASE = 1
  CHILDRENS = 2

  attr_reader :title
  attr_writer :price

  def price_code=(value)
    @price = value
  end

  def initialize(title, price)
    @title, @price = title, price
  end

  def charge(days_rented)
    @price.charge(days_rented)
  end

  def frequent_renter_points(days_rented)
    @price.frequent_renter_points(days_rented)
  end
end

class RegularPrice
  include DefaultPrice

  def charge(days_rented)
    result = 2
    result += (days_rented - 2) * 1.5 if days_rented > 2
    result
  end
end

class NewReleasePrice
  def charge(days_rented)
    days_rented * 3
  end

  def frequent_renter_points(days_rented)
    days_rented > 1 ? 2 : 1
  end
end

class ChildrensPrice
  include DefaultPrice

  def charge(days_rented)
    result = 1.5
    result += (days_rented - 3) * 1.5 if days_rented > 3
    result
  end
end

class Rental
  attr_reader :movie, :days_rented

  def initialize(movie, days_rented)
    @movie, @days_rented = movie, days_rented
  end

  def charge
    @movie.charge(days_rented)
  end

  def frequent_renter_points
    @movie.frequent_renter_points(days_rented)
  end
end

class Customer
  attr_reader :name

  def initialize(name)
    @name = name
    @rentals = []
  end

  def add_rental(arg)
    @rentals << arg
  end

  def statement
    result = "Rental Record for #{@name}\n"
    @rentals.each do |element|
      # show figures for this rental
      result += "\t" + element.movie.title + "\t" + element.charge.to_s + "\n"
    end
    # add footer lines
    result += "Amount owed is #{total_charge}\n"
    result += "You earned #{total_frequent_renter_points} frequent renter points"
    result
  end

  def html_statement
    result = "<h1>Rentals for <em>#{@name}</em></h1><p>\n"
    @rentals.each do |element|
      # show figures for this rental
      result += "\t" + element.movie.title + ": " + element.charge.to_s + "<br>\n"
    end
    # add footer lines
    result += "<p>You owe <em>#{total_charge}</em></p>\n"
    result += "On this rental you earned " +
           "<em>#{total_frequent_renter_points}</em> " +
           "frequent renter points</p>"
    result
  end

  private

  def total_charge
    @rentals.inject(0) { |sum, rental| sum + rental.charge }
  end

  def total_frequent_renter_points
    @rentals.inject(0) { |sum, rental| sum + rental.frequent_renter_points }
  end
end

RSpec.describe 'Customer' do
  before do
    # Movies
    regular = Movie.new('The Mask', RegularPrice.new)
    new_release = Movie.new('Avatar', NewReleasePrice.new)
    childrens = Movie.new('Encanto', ChildrensPrice.new)

    # Rentals
    rental_1 = Rental.new(regular, 10)
    rental_2 = Rental.new(regular, 1)
    rental_3 = Rental.new(regular, 5)
    rental_4 = Rental.new(new_release, 134)
    rental_5 = Rental.new(new_release, 1)
    rental_6 = Rental.new(new_release, 0)
    rental_7 = Rental.new(childrens, 1)
    rental_8 = Rental.new(childrens, 2)
    rental_9 = Rental.new(childrens, -19)

    # Customer
    @customer_one = Customer.new('Zak')
    @customer_one.add_rental(rental_1)
    @customer_one.add_rental(rental_4)
    @customer_one.add_rental(rental_7)

    # Customer with regular movie over 2 days
    @customer_two = Customer.new('Tom')
    @customer_two.add_rental(rental_2)
    @customer_two.add_rental(rental_5)
    @customer_two.add_rental(rental_8)

    # Customer with childrens movie over 2 days
    @customer_three = Customer.new('Amy')
    @customer_three.add_rental(rental_3)
    @customer_three.add_rental(rental_6)
    @customer_three.add_rental(rental_9)
  end

  describe '#statement' do
    it 'prints for Zak' do
      expected =
        "Rental Record for Zak\n" +
        "\tThe Mask\t14.0\n" +
        "\tAvatar\t402\n" +
        "\tEncanto\t1.5\n" +
        "Amount owed is 417.5\n" +
        "You earned 4 frequent renter points"
      expect(@customer_one.statement).to eql(expected)
    end

    it 'prints for Tom' do
      expected =
        "Rental Record for Tom\n" +
        "\tThe Mask\t2\n" +
        "\tAvatar\t3\n" +
        "\tEncanto\t1.5\n" +
        "Amount owed is 6.5\n" +
        "You earned 3 frequent renter points"
      expect(@customer_two.statement).to eql(expected)
    end

    it 'prints for Amy' do
      expected =
        "Rental Record for Amy\n" +
        "\tThe Mask\t6.5\n" +
        "\tAvatar\t0\n" +
        "\tEncanto\t1.5\n" +
        "Amount owed is 8.0\n" +
        "You earned 3 frequent renter points"
      expect(@customer_three.statement).to eql(expected)
    end
  end

  describe '#html_statement' do
    it 'returns html rental record' do
      expected =
        "<h1>Rentals for <em>Zak</em></h1><p>\n" +
        "\tThe Mask: 14.0<br>\n" +
        "\tAvatar: 402<br>\n" +
        "\tEncanto: 1.5<br>\n" +
        "<p>You owe <em>417.5</em></p>\n" +
        "On this rental you earned <em>4</em> frequent renter points</p>"
      expect(@customer_one.html_statement).to eql(expected)
    end
  end
end