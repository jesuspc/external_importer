require_relative 'base_importer'

class JsonImporter < BaseImporter

  class << self

    def import net_http_response, object, receiver, options = {}, &block
      data_for_new_entries = JSON.parse( net_http_response.body, options )
      key = object.to_s.singularize.underscore

      perform_import receiver, data_for_new_entries, key, options, &block
    end

  private

    def remap data, key, mapping
      data = data.with_indifferent_access
      mapping.each do |k, v|
        data[key][v.to_s] = data[key].delete( k ) if data[key][k]
      end

      data
    end

    def perform_import receiver, data_for_new_entries, key, options, &block
      data_for_new_entries.each do |data|
        data = remap( data, key, options[ :mapping ] ) if options[ :mapping ]
        create_new_entry_with data, receiver.to_s.classify, key, &block
      end
    end

    def create_new_entry_with data, receiver_name, key
      new_object = receiver_name.constantize.new( data[ key ] )
      yield new_object if block_given?

      log_helper_string = "#{receiver_name} with imported id #{data["id"] || data["legacy_id"]}"
      save_entry new_object, log_helper_string
    end

    def save_entry object, log_helper_string
      if object.save 
        Rails.logger.info "INFO: Successful import. Created a new #{log_helper_string}"
      else
        Rails.logger.warn "WARNING: Rollback happened during the import of a #{log_helper_string}"
      end
    end

  end

end
