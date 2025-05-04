module Api
  module Pagination
    extend ActiveSupport::Concern

    def jsonapi_pagination(resources)
      {
        first: url_for(page: 1),
        last: url_for(page: resources.total_pages),
        prev: resources.prev_page ? url_for(page: resources.prev_page) : nil,
        next: resources.next_page ? url_for(page: resources.next_page) : nil
      }
    end
  end
end
