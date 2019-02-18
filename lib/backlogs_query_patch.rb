require_dependency 'query'

module Backlogs
  module QueryPatch
    # Returns a representation of the available filters for JSON serialization
    def available_filters_as_json
      json = {}
      available_filters.each do |field, filter|
        options = {:type => filter[:type], :name => filter[:name]}
        options[:remote] = true if filter.respond_to?('remote') && filter.remote

        if has_filter?(field) || !filter.respond_to?('remote') || !filter.remote
          options[:values] = filter.values
          if options[:values] && values_for(field)
            missing = Array(values_for(field)).select(&:present?) - options[:values].map(&:last)
            if missing.any? && respond_to?(method = "find_#{field}_filter_values")
              options[:values] += send(method, missing)
            end
          end
        end
        json[field] = options.stringify_keys
      end
      json
    end
  end
end

class Query
  prepend Backlogs::QueryPatch
end

