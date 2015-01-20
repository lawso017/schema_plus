module SchemaPlus::ActiveRecord::ConnectionAdapters

  #
  # SchemaPlus adds several methods to TableDefinition, allowing indexes
  # and foreign key constraints to be defined within a
  # <tt>create_table</tt> block of a migration, allowing for better
  # encapsulation and more DRY definitions.
  #
  # For example, without SchemaPlus you might define a table like this:
  #
  #    create_table :widgets do |t|
  #       t.string :name
  #    end
  #    add_index :widgets, :name
  #
  # But with SchemaPlus, the index can be defined within the create_table
  # block, so you don't need to repeat the table name:
  #
  #    create_table :widgets do |t|
  #       t.string :name
  #       t.index :name
  #    end
  #
  # Even more DRY, you can define the index as part of the column
  # definition, via:
  #
  #   create_table :widgets do |t|
  #      t.string :name, :index => true
  #   end
  #
  # For details about the :index option (including unique and multi-column indexes), see the
  # documentation for Migration::ClassMethods#add_column
  #
  # SchemaPlus also supports creation of foreign key constraints analogously, using Migration::ClassMethods#add_foreign_key or TableDefinition#foreign_key or as part of the column definition, for example:
  #
  #    create_table :posts do |t|  # not DRY
  #       t.integer :author_id    
  #    end
  #    add_foreign_key :posts, :author_id, :references => :authors
  #
  #    create_table :posts do |t|  # DRYer
  #       t.integer :author_id
  #       t.foreign_key :author_id, :references => :authors
  #    end
  #
  #    create_table :posts do |t|  # Dryest
  #       t.integer :author_id, :foreign_key => true
  #    end
  #
  # <b>NOTE:</b> In the standard configuration, SchemaPlus automatically
  # creates foreign key constraints for columns whose names end in
  # <tt>_id</tt>.  So the above examples are redundant, unless automatic
  # creation was disabled at initialization in the global Config.
  #
  # SchemaPlus likewise by default automatically creates foreign key constraints for
  # columns defined via <tt>t.references</tt>.   However, SchemaPlus does not create
  # foreign key constraints if the <tt>:polymorphic</tt> option is true
  #
  # Finally, the configuration for foreign keys can be overriden on a per-table
  # basis by passing Config options to Migration::ClassMethods#create_table, such as
  #
  #      create_table :students, :foreign_keys => {:auto_create => false} do
  #         t.integer :student_id
  #      end
  #
  module TableDefinition

    attr_accessor :schema_plus_config #:nodoc:

    def foreign_keys
      @foreign_keys ||= []
    end

    def foreign_key(*args) # (column_names, references_table_name, references_column_names=nil, options=nil)
      options = args.extract_options!
      case args.length
      when 2
        column_names, references_table_name = args
      when 3
        ActiveSupport::Deprecation.warn "t.foreign_key positional arg for foreign primary key is deprecated, use :primary_key option instead"
        column_names, references_table_name, primary_key = args
        options.merge(:primary_key => primary_key)
      else
        raise ArgumentError, "wrong number of arguments (#{args.lengt}) for foreign_key(column_names, table_name, options)"
      end

      options.merge!(:column => column_names)
      options.reverse_merge!(:name => ForeignKeyDefinition.default_name(self.name, column_names))
      foreign_keys << ::ActiveRecord::ConnectionAdapters::ForeignKeyDefinition.new(self.name, AbstractAdapter.proper_table_name(references_table_name), options)
      self
    end

  end
end
