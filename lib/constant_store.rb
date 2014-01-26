module ConstantStore

  module InstanceMethods
    def when_valid *args, &block
      self.class.send :when_valid, *args, &block
    end
  end

  def self.extended base
    base.send :include, InstanceMethods
  end

  def constant_stores constant_name, options = {}
    constant_name = constant_name.to_s.upcase
    ConstantStore.const_set 'STORED_CONSTANT_NAME', constant_name
    ConstantStore.instance_variable_set '@constant_class', options[ :as ]

    const_set constant_name, ConstantStore.initialized_constant_value
  end

  def import_constant endpoints
    when_valid endpoints do
      new_endpoints = append_new endpoints

      const_set stored_constant_name, new_endpoints
    end
  end

private

  def when_valid endpoints
    if endpoints
      raise UnprocessableEndpoints unless endpoints.is_a? valid_endpoint_class
      yield
    end
  end

  def append_new endpoints
    existing_endpoints = const_get stored_constant_name

    case constant_class
      when :hash   then existing_endpoints.merge( endpoints )
      when :string then existing_endpoints + endpoints
      else nil
    end
  end

  class UnprocessableEndpoints < StandardError; end

module_function

  def stored_constant_name
    ConstantStore::STORED_CONSTANT_NAME
  end

  def constant_class
    ConstantStore.instance_variable_get '@constant_class'
  end

  def valid_endpoint_class
    case constant_class
      when :hash   then Hash
      when :string then String
      else Object
    end
  end

  def initialized_constant_value
    case constant_class
      when :hash   then Hash.new
      when :string then ''
      else nil
    end
  end

end