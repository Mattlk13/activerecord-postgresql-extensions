
require 'active_record/connection_adapters/postgresql_adapter'

module ActiveRecord
  module PostgreSQLExtensions
    class << self
      def SERVER_VERSION
        return @SERVER_VERSION if defined?(@SERVER_VERSION)

        @SERVER_VERSION = if (version_string = ::ActiveRecord::Base.connection.select_rows("SELECT pg_catalog.version()").flatten.first).present?
          version_string =~ /^\s*PostgreSQL\s+([^\s]+)/
          $1
        end
      end
    end
  end
end

dirname = File.join(File.dirname(__FILE__), *%w{ active_record postgresql_extensions })

%w{
  features
  adapter_extensions
  constraints
  tables
  tablespaces
  indexes
  permissions
  schemas
  languages
  rules
  functions
  sequences
  triggers
  views
  geometry
  types
  roles
  text_search
  extensions
  foreign_key_associations
  vacuum
}.each do |file|
  require File.join(dirname, file)
end

ActiveRecord::Base.send(:include, ActiveRecord::PostgreSQLExtensions::ForeignKeyAssociations)
