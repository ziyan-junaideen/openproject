#-- encoding: UTF-8
#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2014 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

module ChiliProject

  # This module provides some information about the currently used database
  # adapter. It can be used to write code specific to certain database
  # vendors which, while not not encouraged, is sometimes necessary due to
  # syntax differences.

  module Database

    # This method returns a hash which maps the identifier of the supported
    # adapter to a regex matching the adapter_name.
    def self.supported_adapters
      @adapters ||= ({
        :mysql => /mysql/i,
        :postgresql => /postgres/i,
        :sqlite => /sqlite/i
      })
    end

    # Get the raw name of the currently used database adapter.
    # This string is set by the used adapter gem.
    def self.adapter_name
      ActiveRecord::Base.connection.adapter_name
    end

    # returns the identifier of the currently used database type
    def self.name
      supported_adapters.find(proc{ [:unknown, //] }) { |adapter, regex|
        self.adapter_name =~ regex
      }[0]
    end

    # Provide helper methods to quickly check the database type
    # ChiliProject::Database.mysql? returns true, if we have a MySQL DB
    supported_adapters.keys.each do |adapter|
      (class << self; self; end).class_eval do
        define_method(:"#{adapter.to_s}?"){ send(:name) == adapter }
      end
    end

    # Return the version of the underlying database engine.
    # Set the +raw+ argument to true to return the unmangled string
    # from the database.
    def self.version(raw = false)
      case self.name
      when :mysql
        version = ActiveRecord::Base.connection.select_value('SELECT VERSION()')
      when :postgresql
        version = ActiveRecord::Base.connection.select_value('SELECT version()')
        raw ? version : version.match(/\APostgreSQL (\S+)/i)[1]
      when :sqlite
        if Object.const_defined?('RUBY_ENGINE') && ::RUBY_ENGINE == 'jruby'
          Jdbc::SQLite3::VERSION
        else
          if SQLite3.const_defined? 'SQLITE_VERSION'
            SQLite3::SQLITE_VERSION
          else
            SQLite3::Driver::Native::API.sqlite3_libversion
          end
        end
      end
    end

  end
end
