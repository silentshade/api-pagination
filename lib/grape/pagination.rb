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

          links = (header['Link'] || "").split(',').map(&:strip)
          url   = request.url.sub(/\?.*$/, '')
          pages = ApiPagination.pages_from(collection)

          pages.each do |k, v|
            old_params = Rack::Utils.parse_query(request.query_string)
            new_params = old_params.merge('page' => v)
            links << %(<#{url}?#{new_params.to_param}>; rel="#{k}")
          end

          header 'X-Link', links.join(', ') unless links.empty?
          header 'X-Total', ApiPagination.total_from(collection)
          header "X-Total-Pages", collection.total_pages
          header "X-Per-Page",    params[:per_page].to_s
          header "X-Page",        collection.current_page.to_s
          header "X-Next-Page",   collection.next_page.to_s
          header "X-Prev-Page",   collection.prev_page.to_s

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
