module SchemaPlus
  module ActiveRecord
    module ConnectionAdapters
      # 
      # SchemaPlus extends the IndexDefinition object to return information
      # about partial indexes and case sensitivity (i.e. Postgresql
      # support).
      module IndexDefinition
        def self.included(base)  #:nodoc:
          base.alias_method_chain :initialize, :schema_plus
        end
        
        attr_accessor :conditions
        attr_reader :expression
        attr_reader :kind
        attr_reader :operator_classes

        def case_sensitive?
          @case_sensitive
        end

        def initialize_with_schema_plus(*args) #:nodoc:
          # same args as add_index(table_name, column_names, options)
          if args.length == 3 and Hash === args.last
            table_name, column_names, options = args + [{}]
            initialize_without_schema_plus(table_name, options[:name], options[:unique], column_names, options[:length], options[:orders])
            @conditions = options[:conditions]
            @expression = options[:expression]
            @kind = options[:kind]
            @case_sensitive = options.include?(:case_sensitive) ? options[:case_sensitive] : true
            @operator_classes = options[:operator_classes] || {}
          else # backwards compatibility
            initialize_without_schema_plus(*args)
            @case_sensitive = true
            @operator_classes = {}
          end
        end

        # tests if the corresponding indexes would be the same
        def ==(other)
          return false if other.nil?
          return false unless self.name == other.name
          return false unless Array.wrap(self.columns).collect(&:to_s).sort == Array.wrap(other.columns).collect(&:to_s).sort
          return false unless !!self.unique == !!other.unique
          return false unless Array.wrap(self.lengths).compact.sort == Array.wrap(other.lengths).compact.sort
          return false unless self.conditions == other.conditions
          return false unless self.expression == other.expression
          return false unless self.kind == other.kind
          return false unless self.operator_classes == other.operator_classes
          return false unless !!self.case_sensitive? == !!other.case_sensitive?
          true
        end
      end
    end
  end
end
