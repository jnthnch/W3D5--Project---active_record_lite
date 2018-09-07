require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns
    result = []
    array = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    array.first.each do |name|
      result << name.to_sym
    end
    @columns = result
  end

  def self.finalize!
    #class
    @columns = self.columns
    @columns.each do |column|

      define_method(column) do
        #instance of SQL Object
        attributes[column]
      end
    end

    @columns.each do |column|
      define_method("#{column}=") do |value|
        attributes[column] = value
      end
    end

  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.name.underscore.pluralize
                  #SQLObject => sql_objects
  end

  def self.all
    result = DBConnection.execute(<<-SQL)
    SELECT
      #{table_name}.*
    FROM
      #{table_name}
    SQL

    self.parse_all(result)
  end

  def self.parse_all(results)
    results.each do |result|
      self.new(result)
    end
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})

    params.each do |attr_name, value|
      if !self.class.columns.include?(attr_name.to_sym)
        raise "unknown attribute '#{attr_name}'"
      else
        self.send("#{attr_name}=", value)
      end
    end

  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    @attributes[self]
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
