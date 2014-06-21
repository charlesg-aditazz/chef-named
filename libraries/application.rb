# Copyright 2014, Charles Gardner
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

require 'chef/mash'
require 'chef'
require 'chef/dsl'
require 'chef/dsl/data_query'
require 'chef/dsl/platform_introspection'

class Named

  # Class representing a user of the system
  class Application
    # Raw user data bag item contents
    #
    # [+:username+] defaults to +:id+ if not found in original data.
    # [+:groups+] is made sure to be an array
    #
    # @return [Mash]
    attr_reader :data

    # @param [Data Bag Item] _item Data bag item of a user
    def initialize(_item)
      @item = _item
      @data = Mash::new(_item.to_hash)

      data[:username] ||= data[:id]
      data[:groups] = _ensure_array(data[:groups])
    end

    # Get value of user's attribute
    #
    # If user's data bag contains +attr+ key, its value is
    # returned. Otherwise, user's groups are iterated to find one,
    # whose +:user_attributes+ dictionary contains +attr+. If no such
    # group is found, +nil+ is returned.
    #
    # @return application's attribute
    def [](attr)
      return data[attr] if data.include?(attr)

      return nil
    end

    # Get all values for an attribute
    # @param [String, Symbol] attr Attribute name
    # @yield [a, b] Function used to flatten the list
    #               e.g. <tt>&:+</tt> to concatenate list, or <tt>&:|</tt>
    #               to get flat list of all values without repetitions
    # @return [Array] Array of attributes
    # @example
    #    application.get_all(:foo) => [[1], [2, 3], [1, 2, 4]]
    #    application.get_all(:foo, &:+) => [1, 2, 3, 1, 2, 4]
    #    application.get_all(:foo, &:|) => [1, 2, 3, 4]
    def get_all(attr, &block)
      rv = []
      rv << _ensure_array(data[attr]) if data.include?(attr)

      rv = rv.inject([], &block) if block_given?
      rv
    end

    # Pretty-print without too much screen noise
    def inspect
      self.to_s.sub('>', " #{data[:id]}>")
    end

    class << self
      include Chef::DSL::DataQuery
      include Chef::DSL::PlatformIntrospection

      # Get user by ID
      def get(application_id)
        Application.new(data_bag_item("applications", application_id))
      end

      # Get array of applications by Chef search query on +:applications+ data bag
      def search(q)
        rv = []
        Chef::Search::Query.new.search(:applications, q) do |a|
          rv << Application.new(a)
        end
        return rv
      end
    end

    private

    def _ensure_array(item)
      if item.kind_of? Array
      then item
      else [item]
      end
    end
  end

  class << self
    include Chef::DSL::DataQuery
    include Chef::DSL::PlatformIntrospection

    # Get group
    #
    # @param [String] application_id Name of group
    # @return [Mash] Mash containing application attributes; if
    # specified application does not exist, a Mash containing group id and
    # +:imaginary => true+ entry.
    def get_application(application_id)
      @@db_applications ||= data_bag('applications')
      @@applications ||= {}
      @@applications[application_id] ||= Mash::new(
        if @@db_applications.include?(application_id)
        then data_bag_item("applications", application_id).to_hash
        else {
            :id => application_id,
            :imaginary => true
          }
        end
        )
    end
  end
end
