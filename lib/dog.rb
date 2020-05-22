# frozen_string_literal: true

require 'pry'
class Dog
  attr_accessor :name, :breed, :id
  def initialize(name:, breed:, id: nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs
      (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute('DROP TABLE dogs')
  end

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
    dog
  end

  def self.find_by_name(name)
    sql = 'SELECT * FROM dogs WHERE name = ?'
    dog_data = DB[:conn].execute(sql, name).first
    new_from_db(dog_data)
  end

  def self.find_or_create_by(name:, breed:)
    sql = 'SELECT * FROM dogs WHERE name = ? AND breed = ?'
    dog = DB[:conn].execute(sql, name, breed).first
    if !dog.nil?
      new_from_db(dog)
    else
      dog = Dog.create({ name: name, breed: breed })
      dog
    end
  end

  def self.new_from_db(row)
    Dog.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_id(id)
    sql = 'SELECT * FROM dogs WHERE id = ?'
    dog_data = DB[:conn].execute(sql, id).first
    new_from_db(dog_data)
  end

  def save
    if id
      update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, name, breed)
      @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
      self
    end
  end

  def update
    sql = 'UPDATE dogs SET name = ?, breed = ? WHERE id = ?'
    DB[:conn].execute(sql, name, breed, id)
  end
end
