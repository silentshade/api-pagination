module Grape
  module Pagination
    def self.included(base)
      Grape::Endpoint.class_eval do
        def paginate(collection)
          options = {
            :page     => params[:page],
            :per_page => (params[:per_page] || settings[:per_page])
          }
          collection = ApiPagination.paginate(collection, options)

          header 'X-Pagination', { 'Total-Entries' => ApiPagination.total_from(collection),
                                   'Total-Pages' => collection.total_pages.to_s,
                                   'Per-Page' => options[:per_page].to_s,
                                   'Limit-Value' => options[:per_page].to_s,
                                   'Current-Page' => collection.current_page.to_s,
                                   'Next-Page' => collection.next_page.to_s,
                                   'Previous-Page' => collection.previous_page.to_s
          }.to_json

          return collection
        end
      end

      base.class_eval do
        def self.paginate(options = {})
          set :per_page, (options[:per_page] || 25)
          params do
            optional :page,     :type => Integer, :default => 1,
                                :desc => 'Page of results to fetch.'
            optional :per_page, :type => Integer,
                                :desc => 'Number of results to return per page.'
          end
        end
      end
    end
  end
end
