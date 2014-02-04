require 'sinatra/base'
require 'sinatra/param/version'
require 'time'
require 'date'
require 'pry'
require 'pry-nav'

Boolean = :boolean
module Sinatra
  module Param

    class InvalidParameterError < StandardError; end

    module Helpers

      def param(name, type, options = {}, &block)
        name = name.to_s

        return unless params.member?(name) or present?(options[:default]) or options[:required]

        params[name] = coerce(params[name], type, options)
        params[name] = options[:default] if params[name].nil? and options[:default]
        params[name] = options[:transform].to_proc.call(params[name]) if options[:transform]
        validate!(params[name], name, options)

        if block_given?
          if type == Hash
            ParamContextProxy.new(self, params[name]).instance_eval(&block)
          elsif type == Array
            params[name].each do |p|
              ParamContextProxy.new(self, p).instance_eval(&block)
            end
          end
        end
      end

      def one_of(*names)
        count = 0
        names.each do |name|
          if params[name] and present?(params[name])
            count += 1
            next unless count > 1

            raise InvalidParameterError.new("Parameters #{names.join(', ')} are mutually exclusive")
          end
        end
      end

      private

      def coerce(param, type, options = {})
        return nil if param.nil?
        return param if (param.is_a?(type) rescue false)
        return Integer(param) if type == Integer
        return Float(param) if type == Float
        return String(param) if type == String
        return Time.parse(param) if type == Time
        return Date.parse(param) if type == Date
        return DateTime.parse(param) if type == DateTime
        return Array(param.split(options[:delimiter] || ",")) if type == Array
        return Hash[param.split(options[:delimiter] || ",").map{|c| c.split(options[:separator] || ":")}] if type == Hash
        return (/(false|f|no|n|0)$/i === param.to_s ? false : (/(true|t|yes|y|1)$/i === param.to_s ? true : nil)) if type == TrueClass || type == FalseClass || type == Boolean
        return nil
      end

      def validate!(param, param_key, options)
        options.each do |key, value|
          case key
          when :required
            raise InvalidParameterError.new("#{param_key} is required.") if value && param.nil?
          when :blank
            raise InvalidParameterError.new("#{param_key} cannot be blank") if !value && case param
                when String
                  !(/\S/ === param)
                when Array, Hash
                  param.empty?
                else
                  param.nil?
              end
          when :is
            raise InvalidParameterError.new("#{param_key} must be #{value}") unless value === param
          when :in, :within, :range
            raise InvalidParameterError.new("#{param_key} must be #{{:in => "one of", :within => "within", :between => "between"}[key]} #{value}") unless param.nil? || case value
                when Range
                  value.include?(param)
                else
                  Array(value).include?(param)
                end
          when :min
            raise InvalidParameterError.new("#{param_key} cannot be smaller than #{value}") unless param.nil? || value <= param
          when :max
            raise InvalidParameterError.new("#{param_key} cannot be greater than #{value}") unless param.nil? || value >= param
          when :min_length
            raise InvalidParameterError.new("#{param_key} cannot be shorter than #{value} characters") unless param.nil? || value <= param.length
          when :max_length
            raise InvalidParameterError.new("#{param_key} cannot be longer than #{value}") unless param.nil? || value >= param.length
          end
        end
      end

      # ActiveSupport #present? and #blank? without patching Object
      def present?(object)
        !blank?(object)
      end

      def blank?(object)
        object.respond_to?(:empty?) ? object.empty? : !object
      end
    end

    class ParamContextProxy < SimpleDelegator
      include Sinatra::Param::Helpers

      attr_accessor :params

      def initialize(object, params)
        super(object)
        @params = params
      end
    end

  end

  helpers Param::Helpers
end
